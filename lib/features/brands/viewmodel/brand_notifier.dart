import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/brands/model/response/brand_detail_response.dart';
import 'package:picoshop_theme2/features/brands/model/response/brand_list_response.dart';

class BrandListNotifier extends StateNotifier<AsyncValue<BrandListResponse?>> {
  final Dio _dio;
  BrandListNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));

  Future<void> getBrandList() async {
    final response = await _dio.get(
      'https://beta.picosbs.com/api/v1/ecommerce/brands',
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
      final responseData = BrandListResponse.fromJson(response.data);
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

final brandListNotifierProvider =
    StateNotifierProvider<BrandListNotifier, AsyncValue<BrandListResponse?>>(
      (ref) => BrandListNotifier(),
    );



class BrandDetailNotifier extends StateNotifier<AsyncValue<BrandDetailResponse?>> {
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
    StateNotifierProvider<BrandDetailNotifier, AsyncValue<BrandDetailResponse?>>(
      (ref) => BrandDetailNotifier(),
    );
