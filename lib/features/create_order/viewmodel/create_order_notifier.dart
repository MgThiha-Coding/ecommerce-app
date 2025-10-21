import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/create_order/model/request/create_order_request.dart';
import 'package:picoshop_theme2/features/create_order/model/response/create_order_response.dart';

class CreateOrderNotifier
    extends StateNotifier<AsyncValue<CreateOrderResponse?>> {
  CreateOrderNotifier() : super(const AsyncValue.data(null));

  Future<void> createOrder(CreateOrderRequest params) async {
    state = const AsyncValue.loading();
    try {
      final dio = Dio();
      final response = await dio.post(
        'https://beta.picosbs.com/api/ecommerce/order',
        data: params.toFormData(), // Use FormData from request
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${AppConfig.accessToken}',
            'X-API-Token': AppConfig.xApiToken,
            // Remove Content-Type for FormData; Dio sets it automatically
          },
        ),
      );

      final success = response.data['success'] == true;

      if (success) {
        state = AsyncValue.data(CreateOrderResponse.fromJson(response.data));
      } else {
        state = AsyncValue.error(
          response.data['message'] ?? 'Unknown error',
          StackTrace.current,
        );
      }
    } on DioException catch (e, st) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout) {
        state = AsyncValue.error("Check your connection!", st);
      } else {
        state = AsyncValue.error(
          e.response?.data['message'] ?? e.message,
          st,
        );
      }
    }
  }
}

final createOrderNotifierProvider =
    StateNotifierProvider<CreateOrderNotifier, AsyncValue<CreateOrderResponse?>>(
        (ref) => CreateOrderNotifier());
