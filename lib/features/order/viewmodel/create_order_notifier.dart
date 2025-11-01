import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/order/model/request/create_order_request.dart';
import 'package:picoshop_theme2/features/order/model/response/create_order_response.dart';


class CreateOrderNotifier extends StateNotifier<AsyncValue<CreateOrderResponse?>> {
  CreateOrderNotifier() : super(const AsyncValue.data(null));

  CancelToken? _cancelToken;

  Future<void> createOrder(CreateOrderRequest params) async {
    state = const AsyncValue.loading();

    _cancelToken?.cancel("New request started");
    _cancelToken = CancelToken();

    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    try {
      final formData = params.toFormData();

      final response = await dio.post(
        'https://beta.picosbs.com/api/ecommerce/order',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${AppConfig.accessToken}',
            'X-API-Token': AppConfig.xApiToken,
            'Content-Type': 'multipart/form-data',
          },
        ),
        cancelToken: _cancelToken,
      );

      final data = response.data;
      if (data['success'] == true) {
        state = AsyncValue.data(CreateOrderResponse.fromJson(data));
      } else {
        state = AsyncValue.error(data['message'] ?? "Failed to create order.",StackTrace.current);
      }
    } on DioException catch (e, st) {

      if (e.type == DioExceptionType.cancel) return;
      state = AsyncValue.error(e.message ?? "Dio error occurred", st);
      print(e.response);
    } catch (e, st) {
      print(e.toString());
      state = AsyncValue.error("Unexpected error occurred", st);
    }
  }

  void cancel() {
    _cancelToken?.cancel("Request cancelled");
  }
}

final createOrderNotifierProvider =
    StateNotifierProvider<CreateOrderNotifier, AsyncValue<CreateOrderResponse?>>(
        (ref) => CreateOrderNotifier());
