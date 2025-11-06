import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';
import 'package:picoshop_theme2/features/create_address/model/address_response.dart';

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

class AddressListNotifier extends StateNotifier<AsyncValue<AddressResponse>>
    with RefreshTokenMixin {
  final Dio _dio;
  bool _isLoading = false;

  AddressListNotifier([Dio? dio])
      : _dio = dio ?? Dio(),
        super(const AsyncValue.loading()) {
    getAddresses();
  }

  Future<void> getAddresses() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/ecommerce/get/customer/addresses',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${AppConfig.accessToken}',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );

      _handleResponse(response);
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 401) {
        final refreshed = await refreshAndRetry((token) async {
          return await _dio.get(
            '${AppConfig.baseUrl}/ecommerce/get/customer/addresses',
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
          _handleResponse(refreshed);
          _isLoading = false;
          return;
        }
      }

      final error = e.response?.data?['message'] ??
          (e.type == DioExceptionType.connectionError ||
                  e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.unknown
              ? 'Check your connection'
              : 'Something went wrong');
      state = AsyncValue.error(error, st);
    } finally {
      _isLoading = false;
    }
  }

  void _handleResponse(Response response) {
    if (response.statusCode == 200 && response.data['success'] == true) {
      state = AsyncValue.data(AddressResponse.fromJson(response.data));
    } else {
      state = AsyncValue.error(
        response.data['message'] ?? 'Failed to fetch addresses',
        StackTrace.current,
      );
    }
  }

  Future<void> refresh() async {
    await getAddresses();
  }
}

final addressListNotifierProvider =
    StateNotifierProvider<AddressListNotifier, AsyncValue<AddressResponse>>(
  (ref) => AddressListNotifier(),
);
