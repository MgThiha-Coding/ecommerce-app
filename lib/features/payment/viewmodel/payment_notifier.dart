import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/core/network/refresh_token_mixin.dart';
import 'package:picoshop_theme2/features/payment/model/response/payment_method_response.dart';

class PaymentMethodNotifier
    extends StateNotifier<AsyncValue<PaymentMethodResponse?>>
    with RefreshTokenMixin {
  final Dio _dio;

  PaymentMethodNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));

  Future<void> getPaymentMethod() async {
    state = const AsyncValue.loading();

    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/ecommerce/payment-methods',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${AppConfig.accessToken}',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );

      await _handleResponse(response);
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 401) {
        final refreshed = await refreshAndRetry((token) async {
          return await _dio.get(
            '${AppConfig.baseUrl}/ecommerce/payment-methods',
            options: Options(
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
                'X-API-Token': AppConfig.xApiToken,
              },
            ),
          );
        });

        if (refreshed != null) {
          await _handleResponse(refreshed);
          return;
        }
      }

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error('Check Internet', st);
      } else {
        final errorData = e.response?.data['message'];
        state = AsyncValue.error(errorData, st);
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> _handleResponse(Response response) async {
    final isSuccess =
        response.data != null &&
        response.statusCode == 200 &&
        response.data['success'] == true;

    if (isSuccess) {
      state = AsyncValue.data(PaymentMethodResponse.fromJson(response.data));
    } else {
      state = AsyncValue.error(
        response.data['message'] ?? 'Failed to fetch payment methods',
        StackTrace.current,
      );
    }
  }

  Future<void> refresh() async {
    await getPaymentMethod();
  }
}

final paymentMethodNotifierProvider =
    StateNotifierProvider<
      PaymentMethodNotifier,
      AsyncValue<PaymentMethodResponse?>
    >((ref) => PaymentMethodNotifier());
