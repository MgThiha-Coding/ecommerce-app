import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/product/data/product_api_service.dart';
import 'package:picoshop_theme2/features/product/data/product_local_service.dart';
import 'package:picoshop_theme2/features/product/data/product_repository.dart';
import 'package:picoshop_theme2/features/product/model/response/product_data_hive.dart';
import 'package:picoshop_theme2/features/product/model/response/product_detail_response.dart';
import 'package:picoshop_theme2/features/product/model/response/product_list_response.dart';

class ProductListNotifier
    extends StateNotifier<AsyncValue<List<ProductDataModel?>>> {
  final ProductRepository _repo;

  int _currentPage = 1;
  bool _isNoMore = false;
  bool _isLoading = false;
  final List<ProductDataModel> _onlineProducts = [];

  ProductListNotifier(this._repo) : super(const AsyncValue.loading()) {
    final cached = _repo.loadCached();
    if (cached.isNotEmpty) {
      state = AsyncValue.data(cached);
    }
    getNextPage();
  }

  bool get isNoMore => _isNoMore;

  Future<void> reset() async {
    _currentPage = 1;
    _isNoMore = false;
    _onlineProducts.clear();
    await getNextPage();
  }

  Future<void> getNextPage() async {
    if (_isNoMore || _isLoading) return;
    _isLoading = true;

    try {
      final products = await _repo.fetchProducts(_currentPage);
      if (products.isEmpty) {
        _isNoMore = true;
      } else {
        _onlineProducts.addAll(products);
        state = AsyncValue.data(List.from(_onlineProducts));
        _currentPage++;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      _isLoading = false;
    }
  }
}

final productNotifierProvider =
    StateNotifierProvider<
      ProductListNotifier,
      AsyncValue<List<ProductDataModel?>>
    >((ref) {
      final dio = Dio();
      final api = ProductApiService(dio);
      final local = ProductLocalService(Hive.box<ProductHiveModel>('products'));
      final repo = ProductRepository(api, local);
      return ProductListNotifier(repo);
    });

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
