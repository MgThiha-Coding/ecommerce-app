import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/category/model/categories_detail_response.dart';
import 'package:picoshop_theme2/features/category/model/categories_list_response.dart';
import 'package:picoshop_theme2/features/category/local/category_data_hive.dart';

// Cate gory State
class CategoryListNotifier
    extends StateNotifier<AsyncValue<List<CategoryDataModel>>> {
  final Box<CategoryHiveModel> _localCache;
  final Dio _dio;

  final List<CategoryDataModel> _onlineCategories = [];
  int _currentPage = 1;
  bool _isNoMore = false;
  bool _isLoading = false;

  CategoryListNotifier(this._localCache)
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
        // if categories is empty noMore true
        _isNoMore = true;
      } else {
        // add online
        _onlineCategories.addAll(categories);
        // save 16 items in local
        for (var category in categories.take(16)) {
          _localCache.put(
            category.id,
            CategoryHiveModel.fromDataModel(category),
          );
        }
        _currentPage++;
      }

      final connectivityResult = await Connectivity().checkConnectivity();
      // ignore: unrelated_type_equality_checks
      final isOnline = connectivityResult != ConnectivityResult.none;

      if (isOnline) {
        state = AsyncValue.data(List.from(_onlineCategories));
      } else {
        // show offline data when offline
        final cached = _localCache.values.map((e) => e.toDataModel()).toList();
        state = AsyncValue.data(cached);
      }
    } on DioException catch (e, st) {
      // offline data
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

final categoryListNotifierProvider =
    StateNotifierProvider<
      CategoryListNotifier,
      AsyncValue<List<CategoryDataModel>>
    >((ref) {
      final offlineCategories = Hive.box<CategoryHiveModel>('category');
      return CategoryListNotifier(offlineCategories);
    });

// Category Details
class CategoryDetailNotifier
    extends StateNotifier<AsyncValue<CategoryDetailResponse?>> {
  final Dio _dio;

  CategoryDetailNotifier([Dio? dio])
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

  Future<void> getCategoryDetail(int id) async {
    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/ecommerce/categories/details/$id',
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
        final responseData = CategoryDetailResponse.fromJson(response.data);
        state = AsyncValue.data(responseData);
      } else {
        final message = response.data['message'] ?? 'Something went wrong';
        state = AsyncValue.error(message, StackTrace.current);
      }
    } on DioException catch (e, st) {
      final message = (e.response?.data is Map)
          ? e.response?.data['message']
          : 'Check your connection';
      state = AsyncValue.error(message, st);
    }
  }
}

final categoryDetailNotifierProvider =
    StateNotifierProvider<
      CategoryDetailNotifier,
      AsyncValue<CategoryDetailResponse?>
    >((ref) => CategoryDetailNotifier());
