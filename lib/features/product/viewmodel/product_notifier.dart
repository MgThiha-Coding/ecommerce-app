import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/product/local/product_data_hive.dart';
import 'package:picoshop_theme2/features/product/model/product_detail_response.dart';
import 'package:picoshop_theme2/features/product/model/product_list_response.dart';

class ProductListNotifier
    extends StateNotifier<AsyncValue<List<ProductDataModel>>> {
  final Box<ProductHiveModel> _localCache;
  final Dio _dio;
  final List<ProductDataModel> _onlineProducts = [];
  int _currentPage = 1;
  bool _isNoMore = false;
  bool _isLoading = false;

  ProductListNotifier(this._localCache)
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
    _onlineProducts.clear();
    _currentPage = 1;
    _isNoMore = false;
    await getNextPage();
  }

  Future<void> getNextPage() async {
    if (_isNoMore || _isLoading) return;
    _isLoading = true;

    try {
      final response = await _dio.get(
        'https://beta.picosbs.com/api/ecommerce/products',
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
        state = AsyncValue.error(
          response.data['message'] ?? 'Something went wrong',
          StackTrace.current,
        );
        return;
      }

      final parsed = ProductListResponse.fromJson(response.data);
      final products = parsed.data?.data ?? [];

      if (products.isEmpty) {
        _isNoMore = true;
      } else {
        _onlineProducts.addAll(products);

        for (var product in products.take(8)) {
          if (_localCache.length >= 8) {
            _localCache.delete(_localCache.keys.first);
          }
          if (product.id != null) {
            _localCache.put(
              product.id,
              ProductHiveModel.fromDataModel(product),
            );
          }
        }

        _currentPage++;
      }

      final connectivityResult = await Connectivity().checkConnectivity();
      final isOnline = connectivityResult != ConnectivityResult.none;

      state = AsyncValue.data(
        isOnline
            ? List.from(_onlineProducts)
            : _localCache.values.map((e) => e.toDataModel()).toList(),
      );
    } on DioException catch (e, st) {
      final cached = _localCache.values.map((e) => e.toDataModel()).toList();
      if (cached.isNotEmpty) {
        state = AsyncValue.data(cached);
      } else {
        _isNoMore = true;
        state = AsyncValue.error(
          e.response?.data['message'] ?? 'Check Internet',
          st,
        );
      }
    } finally {
      _isLoading = false;
    }
  }
}

final productNotifierProvider =
    StateNotifierProvider<
      ProductListNotifier,
      AsyncValue<List<ProductDataModel>>
    >((ref) {
      final offlineProducts = Hive.box<ProductHiveModel>('products');
      return ProductListNotifier(offlineProducts);
    });

class ProductDetailNotifier
    extends StateNotifier<AsyncValue<ProductDetailResponse?>> {
  final Dio _dio;

  ProductDetailNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));

  void reset() {
    state = const AsyncValue.loading();
  }

  Future<void> getProductDetail(int productId) async {
    try {
      final response = await _dio.get(
        'https://beta.picosbs.com/api/ecommerce/products/details/$productId',
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
        state = AsyncValue.data(ProductDetailResponse.fromJson(response.data));
      }
    } on DioException catch (e, st) {
      state = AsyncValue.error(
        e.response?.data['message'] ?? 'Check your connection!',
        st,
      );
    }
  }
}

final productDetailNotifierProvider =
  StateNotifierProvider.autoDispose<
    ProductDetailNotifier,
    AsyncValue<ProductDetailResponse?>
  >((ref) => ProductDetailNotifier());
