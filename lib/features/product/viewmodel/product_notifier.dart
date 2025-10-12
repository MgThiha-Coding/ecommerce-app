import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/product/local/product_data_hive.dart';
import 'package:picoshop_theme2/features/product/model/product_detail_response.dart';
import 'package:picoshop_theme2/features/product/model/product_list_response.dart';
import 'package:hive/hive.dart';


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
        '${AppConfig.baseUrl}/v1/ecommerce/products',
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
      final parsed = ProductListResponse.fromJson(response.data);
      final products = parsed.data?.data ?? [];
      if (products.isEmpty) {
        _isNoMore = true;
      } else {
        _onlineProducts.addAll(products);
        final limitedItems = products.take(20).toList();
        for (var product in limitedItems) {
          if (_localCache.length >= 20) {
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
      if (isOnline) {
        state = AsyncValue.data(List.from(_onlineProducts));
      } else {
        final cached = _localCache.values.map((e) => e.toDataModel()).toList();
        state = AsyncValue.data(cached);
      }
    } on DioException catch (e, st) {
      final cached = _localCache.values.map((e) => e.toDataModel()).toList();

      if (cached.isNotEmpty) {
        state = AsyncValue.data(cached);
      } else {
        _isNoMore = true;
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.unknown) {
          state = AsyncValue.error('Check Internet', st);
        } else {
          state = AsyncValue.error(e.response?.data['message'], st);
        }
      }
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

// Product Detail Notifier Provider
class ProductDetailNotifier
    extends StateNotifier<AsyncValue<ProductDetailResponse?>> {
  final Dio _dio;

  ProductDetailNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));

  Future<void> getProductDetail(int productId) async {
    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/v1/ecommerce/products/details/$productId',
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
