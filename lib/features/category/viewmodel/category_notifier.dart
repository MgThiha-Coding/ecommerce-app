import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/category/data/category_api_service.dart';
import 'package:picoshop_theme2/features/category/data/category_local_service.dart';
import 'package:picoshop_theme2/features/category/data/category_repository.dart';
import 'package:picoshop_theme2/features/category/model/response/categories_detail_response.dart';
import 'package:picoshop_theme2/features/category/model/response/categories_list_response.dart';
import 'package:picoshop_theme2/features/category/model/response/category_data_hive.dart';

class CategoryListNotifier
    extends StateNotifier<AsyncValue<List<CategoryDataModel?>>> {
  final CategoryRepository _repo;

  int _currentPage = 1;
  bool _isNoMore = false;
  bool _isLoading = false;
  final List<CategoryDataModel> _onlineCategories = [];

  CategoryListNotifier(this._repo) : super(const AsyncValue.loading()) {
    final cached = _repo.loadCached();
    if (cached.isNotEmpty) state = AsyncValue.data(cached);
    getNextPage();
  }

  bool get isNoMore => _isNoMore;

  Future<void> reset() async {
    _currentPage = 1;
    _isNoMore = false;
    _onlineCategories.clear();
    await getNextPage();
  }

  Future<void> getNextPage() async {
    if (_isNoMore || _isLoading) return;
    _isLoading = true;

    try {
      final categories = await _repo.fetchCategories(_currentPage);
      if (categories.isEmpty) _isNoMore = true;

      _onlineCategories.addAll(categories);
      state = AsyncValue.data(List.from(_onlineCategories));
      _currentPage++;
    } finally {
      _isLoading = false;
    }
  }
}

final categoryListNotifierProvider =
    StateNotifierProvider<
      CategoryListNotifier,
      AsyncValue<List<CategoryDataModel?>>
    >((ref) {
      final dio = Dio();
      final api = CategoryApiService(dio);
      final local = CategoryLocalService(
        Hive.box<CategoryHiveModel>('category'),
      );
      final repo = CategoryRepository(api, local);
      return CategoryListNotifier(repo);
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
