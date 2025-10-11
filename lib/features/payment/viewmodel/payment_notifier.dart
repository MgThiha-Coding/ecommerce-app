import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/payment/model/response/payment_method_response.dart';

class PaymentMethodNotifier
    extends StateNotifier<AsyncValue<PaymentMethodResponse?>> {
  final Dio _dio;
  PaymentMethodNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));

  Future<void> getPaymentMethod() async {
    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/v1/ecommerce/payment-methods',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${AppConfig.accessToken}',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );

      print("Payment method response test ${response.data}");
      final isSuccess =
          response.data != null &&
          response.statusCode == 200 &&
          response.data['success'] == true;
      if (isSuccess) {
        final responseData = PaymentMethodResponse.fromJson(response.data);
        state = AsyncValue.data(responseData);
      }
    } on DioException catch (e, st) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error('Check Internet', st);
      } else {
        final errorData = e.response?.data['message'];
        state = AsyncValue.error(errorData, st);
      }
    }
  }
}

final paymentMethodNotifierProvider =
    StateNotifierProvider<
      PaymentMethodNotifier,
      AsyncValue<PaymentMethodResponse?>
    >((ref) => PaymentMethodNotifier());
