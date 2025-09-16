import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/product/model/response/product_data_hive.dart';
import 'package:picoshop_theme2/features/product/model/response/product_detail_response.dart';
import 'package:picoshop_theme2/features/product/model/response/product_list_response.dart';

class ProductListNotifier
    extends StateNotifier<AsyncValue<List<ProductDataModel?>>> {
  final Dio _dio;
  final Box<ProductHiveModel> _box;
  late final StreamSubscription _hiveSub;

  int _currentPage = 1;
  bool _isNoMore = false;
  bool _isLoading = false;

  ProductListNotifier(this._box, [Dio? dio])
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
        'https://beta.picosbs.com/api/v1/ecommerce/products?page=$_currentPage',
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
        final responseData = ProductListResponse.fromJson(response.data);
        final newProducts = responseData.data?.data ?? [];

        _isNoMore = newProducts.isEmpty;

        for (var p in newProducts) {
          _box.put(p.id, ProductHiveModel.fromDataModel(p));
        }

        print('Pagination $_currentPage');
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

final productNotifierProvider =
    StateNotifierProvider<
      ProductListNotifier,
      AsyncValue<List<ProductDataModel?>>
    >((ref) => ProductListNotifier(Hive.box<ProductHiveModel>('products')));

// Product Detail Notifier
class ProductDetailNotifier
    extends StateNotifier<AsyncValue<ProductDetailResponse?>> {
  final Dio _dio;

  ProductDetailNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));

  Future<void> getProductDetail(int productId) async {
    try {
      final response = await _dio.get(
        'https://beta.picosbs.com/api/v1/ecommerce/products/details/$productId',
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
        final responseData = ProductDetailResponse.fromJson(response.data);
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

final productDetailNotifierProvider =
    StateNotifierProvider<
      ProductDetailNotifier,
      AsyncValue<ProductDetailResponse?>
    >((ref) => ProductDetailNotifier());
