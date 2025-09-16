import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/category/model/response/categories_detail_response.dart';
import 'package:picoshop_theme2/features/category/model/response/categories_list_response.dart';
import 'package:picoshop_theme2/features/category/model/response/category_data_hive.dart';

class CategoryListNotifier
    extends StateNotifier<AsyncValue<List<CategoryDataModel?>>> {
  final Dio _dio;
  final Box<CategoryHiveModel> _box;
  late final StreamSubscription _hiveSub;

  int _currentPage = 1;
  bool _isNoMore = false;
  bool _isLoading = false;

  CategoryListNotifier(this._box, [Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.loading()) {
    _hiveSub = _box.watch().listen((_) {
      state = AsyncValue.data(_box.values.map((e) => e.toDataModel()).toList());
    });

    state = AsyncValue.data(_box.values.map((e) => e.toDataModel()).toList());
    getNextPage();
  }

  bool get isNoMore => _isNoMore;

  Future<void> reset() async {
    _currentPage = 1;
    _isNoMore = false;
    await getNextPage();
  }

  Future<void> getNextPage() async {
    if (_isNoMore || _isLoading) return;
    _isLoading = true;

    try {
      final response = await _dio.get(
        'https://beta.picosbs.com/api/v1/ecommerce/categories?page=$_currentPage',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );

      final isSuccess =
          response.statusCode == 200 && response.data?['success'] == true;

      if (isSuccess) {
        final responseData = CategoriesListResponse.fromJson(response.data);
        final newCategories = responseData.data.data;

        _isNoMore = newCategories.isEmpty;

        for (var c in newCategories) {
          _box.put(c.id, CategoryHiveModel.fromDataModel(c));
        }

        if (!_isNoMore) _currentPage++;
      }
    } on DioException catch (e, st) {
      final cached = _box.values.map((e) => e.toDataModel()).toList();
      if (cached.isNotEmpty) {
        state = AsyncValue.data(cached);
      } else {
        state = AsyncValue.error(e, st);
      }
    } finally {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _hiveSub.cancel();
    super.dispose();
  }
}


final categoryListNotifierProvider =
    StateNotifierProvider<
      CategoryListNotifier,
      AsyncValue<List<CategoryDataModel?>>
    >((ref) => CategoryListNotifier(Hive.box<CategoryHiveModel>('category')));

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
