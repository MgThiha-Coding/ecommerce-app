import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/brands/local/brand_data_hive.dart';
import 'package:picoshop_theme2/features/brands/model/brand_detail_response.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/features/brands/model/brand_list_response.dart';

// Brand List State ( Online and offline hybrid )
class BrandListNotifier
    extends StateNotifier<AsyncValue<List<BrandDataModel>>> {
  // Local Hive Model ( offline )
  final Box<BrandHiveModel> _localCache;
  final Dio _dio;
  // Brand Data Model ( online )
  final List<BrandDataModel> _onlineBrands = [];
  int _currentPage = 1;
  bool _isNoMore = false;
  bool _isLoading = false;

  BrandListNotifier(this._localCache)
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),
        ),
      ),
      super(const AsyncValue.loading()) {
    _init();
  }

  bool get isNoMore => _isNoMore;

  // emit local data from localCache
  Future<void> _init() async {
    final cached = _localCache.values.map((e) => e.toDataModel()).toList();
    if (cached.isNotEmpty) {
      state = AsyncValue.data(cached);
    } else {
      await getNextPage();
    }
  }

  // reset the pagination
  Future<void> reset() async {
    _onlineBrands.clear();
    _currentPage = 1;
    _isNoMore = false;
    await getNextPage();
  }

  // fetch brand list
  Future<void> getNextPage() async {
    if (_isNoMore || _isLoading) return;
    _isLoading = true;
    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/api/ecommerce/brands',
        queryParameters: {'page': _currentPage},
        options: Options(
          headers: {
            'Accept': 'application/json',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );

      final isSuccess =
          response.statusCode == 200 && response.data['success'] == true;

      // error state
      if (!isSuccess) {
        final message =
            response.data['message'] ??
            "Something went wrong\nPlease try again";
        state = AsyncValue.error(message, StackTrace.current);
        return;
      }

      final parsed = BrandListResponse.fromJson(response.data);
      final brands = parsed.data?.data ?? [];

      if (brands.isEmpty) {
        _isNoMore = true;
      } else {
        _onlineBrands.addAll(brands);
        // save 16 items to local ( purpose for UI consistentcy )
        for (var brand in brands.take(16)) {
          if (_localCache.length >= 16) {
            _localCache.delete(_localCache.keys.first);
          }
          _localCache.put(brand.id, BrandHiveModel.fromDataModel(brand));
        }
        _currentPage++;
      }

      final connectivityResult = await Connectivity().checkConnectivity();
      // ignore: unrelated_type_equality_checks
      final isOnline = connectivityResult != ConnectivityResult.none;

      // devide by connectivty
      if (isOnline) {
        state = AsyncValue.data(List.from(_onlineBrands));
      } else {
        final cached = _localCache.values.map((e) => e.toDataModel()).toList();
        state = AsyncValue.data(cached);
      }
    } on DioException catch (e, st) {
      final cached = _localCache.values.map((e) => e.toDataModel()).toList();
      if (cached.isNotEmpty) {
        state = AsyncValue.data(cached);
      } else {
        _isNoMore = true;
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.unknown) {
          state = AsyncValue.error('Check your connection”', st);
        } else {
          state = AsyncValue.error(e.response?.data['message'], st);
        }
      }
    } finally {
      _isLoading = false;
    }
  }
}

final brandListNotifierProvider =
    StateNotifierProvider<BrandListNotifier, AsyncValue<List<BrandDataModel>>>((
      ref,
    ) {
      final offlineBrands = Hive.box<BrandHiveModel>('brands');
      return BrandListNotifier(offlineBrands);
    });

// Brand Detail State ( online only )
class BrandDetailNotifier
    extends StateNotifier<AsyncValue<BrandDetailResponse?>> {
  final Dio _dio;
  BrandDetailNotifier([Dio? dio])
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

  Future<void> getBrandDetail(int id) async {
    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/ecommerce/brands/details/$id',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );

      final isSuccess =
          response.statusCode == 200 && response.data['success'] == true;
      if (isSuccess) {
        final responseData = BrandDetailResponse.fromJson(response.data);
        state = AsyncValue.data(responseData);
      }
    } on DioException catch (e, st) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error('Check your connection”', st);
      } else {
        state = AsyncValue.error(e.response?.data['message'], st);
      }
    }
  }
}

final brandDetailNotifierProvider =
    StateNotifierProvider<
      BrandDetailNotifier,
      AsyncValue<BrandDetailResponse?>
    >((ref) => BrandDetailNotifier());
