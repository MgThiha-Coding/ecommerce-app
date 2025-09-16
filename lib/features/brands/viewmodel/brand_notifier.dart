import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/brands/model/response/brand_data_hive.dart';
import 'package:picoshop_theme2/features/brands/model/response/brand_detail_response.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/features/brands/model/response/brand_list_response.dart';

class BrandListNotifier
    extends StateNotifier<AsyncValue<List<BrandDataModel?>>> {
  final Dio _dio;
  final Box<BrandHiveModel> _box;
  late final StreamSubscription _hiveSub;
  int _currentPage = 1;
  bool _isNoMore = false;
  bool _isLoading = false;
  BrandListNotifier(this._box, [Dio? dio])
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
        'https://beta.picosbs.com/api/v1/ecommerce/brands?page=$_currentPage',
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
        final responseData = BrandListResponse.fromJson(response.data);
        final newBrands = responseData.data.data;
        _isNoMore = newBrands.isEmpty;
        for (var b in newBrands) {
          _box.put(b.id, BrandHiveModel.fromDataModel(b));
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

final brandListNotifierProvider =
    StateNotifierProvider<BrandListNotifier, AsyncValue<List<BrandDataModel?>>>(
      (ref) => BrandListNotifier(Hive.box<BrandHiveModel>('brands')),
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
