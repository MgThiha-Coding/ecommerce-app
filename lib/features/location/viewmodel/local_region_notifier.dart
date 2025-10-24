import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/location/model/local_region_response.dart';

// Local Region State
class LocalRegionNotifier extends StateNotifier<AsyncValue<List<RegionItem>>> {
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

      final isSuccess =
          response.statusCode == 200 && response.data['success'] == true;

      if (!isSuccess) {
        final message =
            response.data['message'] ??
            'Something went wrong. Please try again.';
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
    } finally {
      _isLoading = false;
    }
  }
}

final localRegionNotifierProvider =
    StateNotifierProvider<LocalRegionNotifier, AsyncValue<List<RegionItem>>>(
      (ref) => LocalRegionNotifier(),
    );
