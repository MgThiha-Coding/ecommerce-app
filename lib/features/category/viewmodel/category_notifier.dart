import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/category/model/response/categories_detail_response.dart';
import 'package:picoshop_theme2/features/category/model/response/categories_list_response.dart';

class CategoriesNotifier
    extends StateNotifier<AsyncValue<CategoriesListResponse?>> {
  final Dio _dio;
  CategoriesNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));
  Future<void> getCagetoryList() async {
    try {
      final response = await _dio.get(
        'https://beta.picosbs.com/api/v1/ecommerce/categories',
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
        final responseData = CategoriesListResponse.fromJson(response.data);
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

final categoriesListNotifierProvider =
    StateNotifierProvider<
      CategoriesNotifier,
      AsyncValue<CategoriesListResponse?>
    >((ref) => CategoriesNotifier());

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
