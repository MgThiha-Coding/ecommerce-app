import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/core/network/refresh_token_mixin.dart';
import 'package:picoshop_theme2/features/order/model/request/create_order_request.dart';
import 'package:picoshop_theme2/features/order/model/response/create_order_response.dart';

class CreateOrderNotifier
    extends StateNotifier<AsyncValue<CreateOrderResponse?>>
    with RefreshTokenMixin {
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

    Future<Response> sendRequest(String token) {
      final formData = params.toFormData();
      return dio.post(
        '${AppConfig.baseUrl}/ecommerce/order',
        data: formData,
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
            'X-API-Token': AppConfig.xApiToken,
            'Content-Type': 'multipart/form-data',
          },
        ),
        cancelToken: _cancelToken,
      );
    }

    try {
      Response response = await sendRequest(AppConfig.accessToken);

      if (response.statusCode == 401) {
        final refreshed = await refreshAndRetry(sendRequest);
        if (refreshed != null) response = refreshed;
      }

      final data = response.data;
      if (data['success'] == true) {
        state = AsyncValue.data(CreateOrderResponse.fromJson(data));
      } else {
        state = AsyncValue.error(
          data['message'] ?? "Failed to create order.",
          StackTrace.current,
        );
      }
    } on DioException catch (e, st) {
      if (e.type == DioExceptionType.cancel) return;
      state = AsyncValue.error(e.message ?? "Dio error occurred", st);
    } catch (e, st) {
      state = AsyncValue.error("Unexpected error occurred", st);
    }
  }

  void cancel() {
    _cancelToken?.cancel("Request cancelled");
  }
}

final createOrderNotifierProvider =
    StateNotifierProvider<
      CreateOrderNotifier,
      AsyncValue<CreateOrderResponse?>
    >((ref) => CreateOrderNotifier());
