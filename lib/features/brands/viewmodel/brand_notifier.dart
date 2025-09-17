import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/brands/data/brand_api_service.dart';
import 'package:picoshop_theme2/features/brands/data/brand_local_service.dart';
import 'package:picoshop_theme2/features/brands/data/brand_repository.dart';
import 'package:picoshop_theme2/features/brands/model/response/brand_data_hive.dart';
import 'package:picoshop_theme2/features/brands/model/response/brand_detail_response.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/features/brands/model/response/brand_list_response.dart';

class BrandListNotifier
    extends StateNotifier<AsyncValue<List<BrandDataModel?>>> {
  final BrandRepository _repo;

  int _currentPage = 1;
  bool _isNoMore = false;
  bool _isLoading = false;
  final List<BrandDataModel> _onlineBrands = [];

  BrandListNotifier(this._repo) : super(const AsyncValue.loading()) {
    final cached = _repo.loadCached();
    if (cached.isNotEmpty) state = AsyncValue.data(cached);
    getNextPage();
  }

  bool get isNoMore => _isNoMore;

  Future<void> reset() async {
    _currentPage = 1;
    _isNoMore = false;
    _onlineBrands.clear();
    await getNextPage();
  }

  Future<void> getNextPage() async {
    if (_isNoMore || _isLoading) return;
    _isLoading = true;

    try {
      final brands = await _repo.fetchBrands(_currentPage);
      if (brands.isEmpty) _isNoMore = true;

      _onlineBrands.addAll(brands);
      state = AsyncValue.data(List.from(_onlineBrands));
      _currentPage++;
    } finally {
      _isLoading = false;
    }
  }
}

final brandListNotifierProvider =
    StateNotifierProvider<BrandListNotifier, AsyncValue<List<BrandDataModel?>>>(
      (ref) {
        final dio = Dio();
        final api = BrandApiService(dio);
        final local = BrandLocalService(Hive.box<BrandHiveModel>('brands'));
        final repo = BrandRepository(api, local);
        return BrandListNotifier(repo);
      },
    );

class BrandDetailNotifier
    extends StateNotifier<AsyncValue<BrandDetailResponse?>> {
  final Dio _dio;
  BrandDetailNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));

  Future<void> getBrandDetail(int id) async {
    final response = await _dio.get(
      'https://beta.picosbs.com/api/v1/ecommerce/brands/details/$id',
      options: Options(
        headers: {
          'Accept': 'application/json',
          'X-API-Token': AppConfig.xApiToken,
        },
      ),
    );

    final isSuccess =
        response.data != null &&
        response.data['success'] == true &&
        response.statusCode == 200;
    if (isSuccess) {
      final responseData = BrandDetailResponse.fromJson(response.data);
      state = AsyncValue.data(responseData);
    }
    try {} on DioException catch (e, st) {
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

final brandDetailNotifierProvider =
    StateNotifierProvider<
      BrandDetailNotifier,
      AsyncValue<BrandDetailResponse?>
    >((ref) => BrandDetailNotifier());
