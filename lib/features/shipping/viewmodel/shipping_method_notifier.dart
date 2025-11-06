import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';
import 'package:picoshop_theme2/features/shipping/model/shipping_method_response.dart';

mixin RefreshTokenMixin {
  final Dio _refreshDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
    ),
  );
  final SecureStorage _storage = SecureStorage();

  Future<Response<dynamic>?> refreshAndRetry(
    Future<Response<dynamic>> Function(String accessToken) retryCallback,
  ) async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final refreshRes = await _refreshDio.post(
        '${AppConfig.baseUrl}/v1/refresh-token',
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'X-API-Token': AppConfig.xApiToken}),
      );

      final accessToken = refreshRes.data['data']['accessToken'];
      final newRefreshToken = refreshRes.data['data']['refreshToken'];
      final userId = refreshRes.data['data']['user']['id'].toString();

      AppConfig.updateAccessToken(accessToken);
      await _storage.saveAuthData(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
        userId: userId,
      );

      return await retryCallback(accessToken);
    } catch (_) {
      return null;
    }
  }
}

class ShippingMethodNotifier
    extends StateNotifier<AsyncValue<ShippingMethodResponse?>> with RefreshTokenMixin {
  final Dio _dio;

  ShippingMethodNotifier([Dio? dio])
      : _dio = dio ?? Dio(),
        super(const AsyncValue.data(null));

  Future<void> getShippingMethod() async {
    state = const AsyncValue.loading();

    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/ecommerce/shipping-methods',
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
            '${AppConfig.baseUrl}/ecommerce/shipping-methods',
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
        response.statusCode == 200 && response.data['success'] == true;

    if (isSuccess) {
      state = AsyncValue.data(ShippingMethodResponse.fromJson(response.data));
    } else {
      state = AsyncValue.error(
        response.data['message'] ?? 'Failed to fetch shipping methods',
        StackTrace.current,
      );
    }
  }

  Future<void> refresh() async {
    await getShippingMethod();
  }
}

final shippingMethodNotifierProvider =
    StateNotifierProvider<ShippingMethodNotifier, AsyncValue<ShippingMethodResponse?>>(
  (ref) => ShippingMethodNotifier(),
);
