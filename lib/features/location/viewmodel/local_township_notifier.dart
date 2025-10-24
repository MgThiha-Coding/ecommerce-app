import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/location/model/local_township_response.dart';

// Local State
class LocalTownshipNotifier
    extends StateNotifier<AsyncValue<List<TownshipData>>> {
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
        '${AppConfig.baseUrl}https://beta.picosbs.com/api/ecommerce/region/local/$regionId/township',

        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${AppConfig.accessToken}',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );

      final isSuccess =
          response.statusCode == 200 && response.data['success'] == true;

      if (!isSuccess) {
        final message =
            response.data['message'] ??
            'Something went wrong. Please try again.';
        state = AsyncValue.error(message, StackTrace.current);
        return;
      }

      final parsed = LocalTownshipResponse.fromJson(response.data);
      final townships = parsed.data ?? [];

      state = AsyncValue.data(townships);
    } on DioException catch (e, st) {
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

  void reset() {
    state = const AsyncValue.data([]);
  }
}

final localTownshipNotifierProvider =
    StateNotifierProvider<
      LocalTownshipNotifier,
      AsyncValue<List<TownshipData>>
    >((ref) => LocalTownshipNotifier());
