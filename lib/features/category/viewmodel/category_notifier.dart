import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/category/model/categories_detail_response.dart';
import 'package:picoshop_theme2/features/category/model/categories_list_response.dart';
import 'package:picoshop_theme2/features/category/local/category_data_hive.dart';

// Category List Notifier Provider
class CategoryListNotifier
    extends StateNotifier<AsyncValue<List<CategoryDataModel>>> {
  final Box<CategoryHiveModel> _localCache;
  final Dio _dio;

  final List<CategoryDataModel> _onlineCategories = [];
  int _currentPage = 1;
  bool _isNoMore = false;
  bool _isLoading = false;

  CategoryListNotifier(this._localCache)
    : _dio = Dio(),
      super(const AsyncValue.loading()) {
    _init();
  }

  bool get isNoMore => _isNoMore;

  Future<void> _init() async {
    final cached = _localCache.values.map((e) => e.toDataModel()).toList();
    if (cached.isNotEmpty) {
      state = AsyncValue.data(cached);
    } else {
      await getNextPage();
    }
  }

  Future<void> reset() async {
    _onlineCategories.clear();
    _currentPage = 1;
    _isNoMore = false;
    await getNextPage();
  }

  Future<void> getNextPage() async {
    if (_isNoMore || _isLoading) return;
    _isLoading = true;

    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/ecommerce/categories',
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

      if (!isSuccess) {
        final message =
            response.data['message'] ??
            "Something went wrong\nPlease try again";
        state = AsyncValue.error(message, StackTrace.current);
        return;
      }

      final parsed = CategoriesListResponse.fromJson(response.data);
      final categories = parsed.data.data;

      if (categories.isEmpty) {
        _isNoMore = true;
      } else {
        _onlineCategories.addAll(categories);
        final limitedItems = categories.take(20).toList();
        for (var category in limitedItems) {
          if (_localCache.length >= 20) {
            _localCache.delete(_localCache.keys.first);
          }
          _localCache.put(
            category.id,
            CategoryHiveModel.fromDataModel(category),
          );
                }
        _currentPage++;
      }

      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        state = AsyncValue.data(List.from(_onlineCategories));
      } else {
        final cached = _localCache.values.map((e) => e.toDataModel()).toList();
        state = AsyncValue.data(cached);
      }
    } on DioException catch (e, st) {
      final cached = _localCache.values.map((e) => e.toDataModel()).toList();
      state = AsyncValue.data(cached);
      _isNoMore = true;
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error('Check Internet', st);
      }
    } finally {
      _isLoading = false;
    }
  }
}

final categoryListNotifierProvider =
    StateNotifierProvider<
      CategoryListNotifier,
      AsyncValue<List<CategoryDataModel>>
    >((ref) {
      final offlineCategories = Hive.box<CategoryHiveModel>('category');
      return CategoryListNotifier(offlineCategories);
    });

class CategoryDetailNotifier
    extends StateNotifier<AsyncValue<CategoryDetailResponse?>> {
  final Dio _dio;
  CategoryDetailNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));
  Future<void> getCagetoryDetail(int id) async {
    try {
      final response = await _dio.get(
        'https://beta.picosbs.com/api/v1/ecommerce/categories/details/$id',
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
        final responseData = CategoryDetailResponse.fromJson(response.data);
        state = AsyncValue.data(responseData);
      }
    } on DioException catch (e, st) {
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

final categoryDetailNotifierProvider =
    StateNotifierProvider<
      CategoryDetailNotifier,
      AsyncValue<CategoryDetailResponse?>
    >((ref) => CategoryDetailNotifier());
