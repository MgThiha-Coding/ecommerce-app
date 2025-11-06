import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/core/network/refresh_token_mixin.dart';
import 'package:picoshop_theme2/features/location/model/local_township_response.dart';

class LocalTownshipNotifier
    extends StateNotifier<AsyncValue<List<TownshipData>>>
    with RefreshTokenMixin {
  final Dio _dio;

  LocalTownshipNotifier()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),
        ),
      ),
      super(const AsyncValue.loading());

  Future<void> fetchByRegion(int regionId) async {
    state = const AsyncValue.loading();

    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/ecommerce/region/local/$regionId/township',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${AppConfig.accessToken}',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );

      await _handleResponse(response, regionId);
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 401) {
        final refreshed = await refreshAndRetry((token) async {
          return await _dio.get(
            '${AppConfig.baseUrl}/ecommerce/region/local/$regionId/township',
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
          await _handleResponse(refreshed, regionId);
          return;
        }
      }

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error(
          'Network error. Please check your connection.',
          st,
        );
      } else {
        final errorMsg = e.response?.data?['message'] ?? e.message;
        state = AsyncValue.error(errorMsg ?? 'Unknown error', st);
      }
    }
  }

  Future<void> _handleResponse(Response response, int regionId) async {
    final isSuccess =
        response.statusCode == 200 && response.data['success'] == true;

    if (!isSuccess) {
      final message =
          response.data['message'] ?? 'Something went wrong. Please try again.';
      state = AsyncValue.error(message, StackTrace.current);
      return;
    }

    final parsed = LocalTownshipResponse.fromJson(response.data);
    final townships = parsed.data ?? [];

    state = AsyncValue.data(townships);
  }

  void reset() {
    state = const AsyncValue.data([]);
  }

  Future<void> refresh(int regionId) async {
    await fetchByRegion(regionId);
  }
}

final localTownshipNotifierProvider =
    StateNotifierProvider<
      LocalTownshipNotifier,
      AsyncValue<List<TownshipData>>
    >((ref) => LocalTownshipNotifier());
