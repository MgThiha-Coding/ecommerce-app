import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';

abstract class BaseAuthNotifier<T> extends StateNotifier<AsyncValue<T?>> {
  final Dio _dio;
  final SecureStorage _storage;

  BaseAuthNotifier(this._storage, [Dio? dio])
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 10),
            ),
          ),
      super(const AsyncValue.data(null));

  Future<T?> request(Map<String, dynamic> data);

  Future<void> call(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      // first request
      final response = await request(data);
      if (response != null) {
        state = AsyncValue.data(response);
      } else {
        state = AsyncValue.error('Request failed', StackTrace.current);
      }
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 401) {
        final refreshed = await _refreshAndRetry(data);
        if (refreshed != null) {
          state = AsyncValue.data(refreshed);
          return;
        }
      }

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error('Check internet connection', st);
      } else {
        state = AsyncValue.error(
          e.response?.data?['message'] ?? 'Unexpected error',
          st,
        );
      }
    }
  }

  // refresh token
  Future<T?> _refreshAndRetry(Map<String, dynamic> data) async {
    final refreshToken = await _storage.getRefreshToken();

    if (refreshToken == null) return null;

    try {
      final refreshRes = await _dio.post(
        '${AppConfig.baseUrl}/v1/refresh-token',
        options: Options(headers: {'X-API-Token': AppConfig.xApiToken}),
        data: {"refresh_token": refreshToken},
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

      // return value
      return await request(data);
    } catch (_) {
      return null;
    }
  }
}
