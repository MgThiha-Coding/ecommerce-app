import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/core/network/refresh_token_mixin.dart';
import 'package:picoshop_theme2/features/location/model/local_region_response.dart';


class LocalRegionNotifier
    extends StateNotifier<AsyncValue<List<RegionItem>>>
    with RefreshTokenMixin {
  final Dio _dio;
  final List<RegionItem> _onlineRegions = [];

  int _currentPage = 1;
  bool _isNoMore = false;
  bool _isLoading = false;

  LocalRegionNotifier()
      : _dio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 10),
          ),
        ),
        super(const AsyncValue.loading()) {
    getNextPage();
  }

  bool get isNoMore => _isNoMore;
  bool get isLoading => _isLoading;

  Future<void> reset() async {
    _onlineRegions.clear();
    _currentPage = 1;
    _isNoMore = false;
    await getNextPage();
  }

  Future<void> getNextPage() async {
    if (_isNoMore || _isLoading) return;
    _isLoading = true;

    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/ecommerce/region/local',
        queryParameters: {'page': _currentPage},
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
            '${AppConfig.baseUrl}/ecommerce/region/local',
            queryParameters: {'page': _currentPage},
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
          _isLoading = false;
          return;
        }
      }

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error('Network error. Please check your connection.', st);
      } else {
        final errorMsg = e.response?.data?['message'] ?? e.message;
        state = AsyncValue.error(errorMsg ?? 'Unknown error', st);
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _handleResponse(Response response) async {
    final isSuccess = response.statusCode == 200 && response.data['success'] == true;

    if (!isSuccess) {
      final message = response.data['message'] ?? 'Something went wrong. Please try again.';
      state = AsyncValue.error(message, StackTrace.current);
      return;
    }

    final parsed = LocalRegionResponse.fromJson(response.data);
    final newRegions = parsed.data?.data ?? [];

    if (newRegions.isEmpty) {
      _isNoMore = true;
    } else {
      _onlineRegions.addAll(newRegions);
      _currentPage++;
    }

    state = AsyncValue.data(List.from(_onlineRegions));
  }

  Future<void> refresh() async {
    _onlineRegions.clear();
    _currentPage = 1;
    _isNoMore = false;
    await getNextPage();
  }
}

final localRegionNotifierProvider =
    StateNotifierProvider<LocalRegionNotifier, AsyncValue<List<RegionItem>>>(
  (ref) => LocalRegionNotifier(),
);
