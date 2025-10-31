import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/product/model/product_list_response.dart';
import 'package:picoshop_theme2/features/product/local/product_data_hive.dart';

class CombinedProductSearchNotifier
    extends StateNotifier<AsyncValue<List<ProductDataModel>>> {
  final Dio _dio;
  final Box<ProductHiveModel> _productCache;
  final List<ProductDataModel> _results = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isNoMore = false;

  String _keyword = '';
  String _filterType = 'product';

  CombinedProductSearchNotifier(this._productCache)
    : _dio = Dio(),
      super(const AsyncValue.data([])) {
    loadInitialProducts();
  }

  // --- Preload 10 recent products or first products ---
  Future<void> loadInitialProducts({int count = 10}) async {
    if (_results.isNotEmpty) return;
    _isLoading = true;
    try {
      // Try loading recent products from cache first
      final recent = _productCache.values.map((e) => e.toDataModel()).toList();
      if (recent.isNotEmpty) {
        _results.clear();
        _results.addAll(recent.take(count));
        state = AsyncValue.data(List.from(_results));
        _isLoading = false;
        return;
      }

      // Otherwise, load first products from API
      final resp = await _dio.get(
        'https://beta.picosbs.com/api/ecommerce/products',
        queryParameters: {'page': 1, 'per_page': count},
        options: Options(headers: {'X-API-Token': AppConfig.xApiToken}),
      );
      final parsed = ProductListResponse.fromJson(resp.data);
      var products = parsed.data?.data ?? [];

      _results.clear();
      _results.addAll(products);
      _currentPage = 2;
      _isNoMore = false;
      state = AsyncValue.data(List.from(_results));

      // Save to cache
      for (var product in products.take(count)) {
        if (product.id != null) {
          _productCache.put(
            product.id,
            ProductHiveModel.fromDataModel(product),
          );
        }
      }
    } catch (_) {
      state = const AsyncValue.data([]);
    } finally {
      _isLoading = false;
    }
  }

  bool get isNoMore => _isNoMore;
  bool get isLoading => _isLoading;

  Future<void> reset() async {
    _results.clear();
    _currentPage = 1;
    _isNoMore = false;
    _keyword = '';
    state = const AsyncValue.data([]);
  }

  Future<void> search({
    required String keyword,
    required String filterType,
  }) async {
    _keyword = keyword.trim();
    _filterType = filterType;
    _results.clear();
    _currentPage = 1;
    _isNoMore = false;

    if (_keyword.isEmpty) {
      await showRecent();
      return;
    }

    state = const AsyncValue.loading();
    await _fetchPage();
  }

  Future<void> showRecent({int count = 10}) async {
    _results.clear();
    _results.addAll(
      _productCache.values.map((e) => e.toDataModel()).take(count),
    );
    state = AsyncValue.data(List.from(_results));
  }

  Future<void> loadMore() async {
    if (_isLoading || _isNoMore || _keyword.isEmpty) return;
    await _fetchPage();
  }

  Future<void> _fetchPage() async {
    _isLoading = true;
    try {
      //List<int> filterIds = [];

      // --- BRAND AND CATEGORY SEARCH (commented for MVP) ---
      /*
      if (_filterType == 'brand') {
        final brandResp = await _dio.get(
          'https://beta.picosbs.com/api/ecommerce/brands',
          queryParameters: {'search': _keyword},
          options: Options(headers: {'X-API-Token': AppConfig.xApiToken}),
        );
        final brands = BrandListResponse.fromJson(brandResp.data).data?.data ?? [];
        filterIds = brands.map((b) => b.id).whereType<int>().toList();
        if (filterIds.isEmpty) {
          _isNoMore = true;
          state = const AsyncValue.data([]);
          return;
        }
      } else if (_filterType == 'category') {
        final catResp = await _dio.get(
          'https://beta.picosbs.com/api/ecommerce/categories',
          queryParameters: {'search': _keyword},
          options: Options(headers: {'X-API-Token': AppConfig.xApiToken}),
        );
        final categories = CategoriesListResponse.fromJson(catResp.data).data.data;
        filterIds = categories.map((c) => c.id).whereType<int>().toList();
        if (filterIds.isEmpty) {
          _isNoMore = true;
          state = const AsyncValue.data([]);
          return;
        }
      }
      */

      final Map<String, dynamic> query = {'page': _currentPage};
      if (_filterType == 'product') {
        query['filter[products.name][\$like]'] = '%$_keyword%';
      }

      final resp = await _dio.get(
        'https://beta.picosbs.com/api/ecommerce/products',
        queryParameters: query,
        options: Options(headers: {'X-API-Token': AppConfig.xApiToken}),
      );

      final parsed = ProductListResponse.fromJson(resp.data);
      var products = parsed.data?.data ?? [];

      if (products.isEmpty) {
        _isNoMore = true;
      } else {
        // Sort by relevance
        products.sort((a, b) {
          final nameA = a.name?.toLowerCase() ?? '';
          final nameB = b.name?.toLowerCase() ?? '';
          final kw = _keyword.toLowerCase();
          if (nameA.startsWith(kw) && !nameB.startsWith(kw)) return -1;
          if (!nameA.startsWith(kw) && nameB.startsWith(kw)) return 1;
          if (nameA.contains(kw) && !nameB.contains(kw)) return -1;
          if (!nameA.contains(kw) && nameB.contains(kw)) return 1;
          return nameA.compareTo(nameB);
        });

        _results.addAll(products);
        _currentPage++;

        for (var product in products.take(8)) {
          if (_productCache.length >= 8 && product.id != null) {
            _productCache.delete(_productCache.keys.first);
          }
          if (product.id != null) {
            _productCache.put(
              product.id,
              ProductHiveModel.fromDataModel(product),
            );
          }
        }
      }

      state = AsyncValue.data(List.from(_results));
    } on DioException catch (e, st) {
      final cached = _productCache.values.map((e) => e.toDataModel()).toList();
      if (cached.isNotEmpty) {
        state = AsyncValue.data(cached);
      } else {
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

final combinedProductSearchProvider =
    StateNotifierProvider<
      CombinedProductSearchNotifier,
      AsyncValue<List<ProductDataModel>>
    >((ref) {
      final offlineProducts = Hive.box<ProductHiveModel>('products');
      return CombinedProductSearchNotifier(offlineProducts);
    });
