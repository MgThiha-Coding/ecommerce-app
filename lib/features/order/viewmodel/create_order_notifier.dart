import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/order/model/request/create_order_request.dart';
import 'package:picoshop_theme2/features/order/model/response/create_order_response.dart';

class CreateOrderNotifier
    extends StateNotifier<AsyncValue<CreateOrderResponse?>> {
  CreateOrderNotifier() : super(const AsyncValue.data(null));

  // Keep a cancel token to allow safe cancellation
  CancelToken? _cancelToken;

  Future<void> createOrder(CreateOrderRequest params) async {
    // Start loading
    state = const AsyncValue.loading();

    // Cancel previous request if exists
    _cancelToken?.cancel("New order request started");
    _cancelToken = CancelToken();

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
      ),
    );

    try {
      final response = await dio.post(
        'https://beta.picosbs.com/api/ecommerce/order',
        data: params.toFormData(),
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${AppConfig.accessToken}',
            'Content-Type': 'application/json',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
        cancelToken: _cancelToken,
      );

      final success = response.data['success'] == true;

      if (success) {
        state = AsyncValue.data(CreateOrderResponse.fromJson(response.data));
      } else {
        state = AsyncValue.error(
          response.data['message'] ??
              'Failed to create order. Please try again.',
          StackTrace.current,
        );
      }
    } on DioException catch (e, st) {
      String message;

      if (e.type == DioExceptionType.cancel) {
        return;
      }

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message =
              "The request timed out. Please check your internet connection and try again.";
          break;
        case DioExceptionType.connectionError:
          message =
              "Unable to connect to the server. Please check your network.";
          break;
        case DioExceptionType.badResponse:
          message =
              e.response?.data['message'] ??
              "Server error occurred. Please contact support if the problem persists.";
          break;
        case DioExceptionType.unknown:
        default:
          message =
              e.message ?? "An unexpected error occurred. Please try again.";
      }

      state = AsyncValue.error(message, st);
    } catch (e, st) {
      state = AsyncValue.error(
        "An unexpected error occurred while creating the order. Please try again later.",
        st,
      );
    }
  }

  // Optional: cancel the current request if needed
  void cancel() {
    _cancelToken?.cancel("Request cancelled by user");
  }
}

final createOrderNotifierProvider =
    StateNotifierProvider<
      CreateOrderNotifier,
      AsyncValue<CreateOrderResponse?>
    >((ref) => CreateOrderNotifier());
