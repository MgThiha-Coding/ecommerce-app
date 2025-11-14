import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/product/model/product_list_response.dart';

class CombinedProductSearchNotifier
    extends StateNotifier<AsyncValue<List<ProductDataModel>>> {
  final Dio _dio = Dio();
  final List<ProductDataModel> _results = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isNoMore = false;

  String _keyword = '';

  CombinedProductSearchNotifier() : super(const AsyncValue.data([])) {
    loadInitialProducts();
  }

  bool get isNoMore => _isNoMore;
  bool get isLoading => _isLoading;

  Future<void> loadInitialProducts({int count = 10}) async {
    if (_results.isNotEmpty) return;
    _isLoading = true;
    try {
      final resp = await _dio.get(
        '${AppConfig.baseUrl}/ecommerce/products',
        queryParameters: {'page': 1, 'per_page': count},
        options: Options(headers: {'X-API-Token': AppConfig.xApiToken}),
      );

      final parsed = ProductListResponse.fromJson(resp.data);
      final products = parsed.data?.data ?? [];

      _results.clear();
      _results.addAll(products);
      _currentPage = 2;
      _isNoMore = false;
      state = AsyncValue.data(List.from(_results));
    } catch (_) {
      state = const AsyncValue.data([]);
    } finally {
      _isLoading = false;
    }
  }

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
    _results.clear();
    _currentPage = 1;
    _isNoMore = false;

    if (_keyword.isEmpty) {
      await loadInitialProducts();
      return;
    }

    state = const AsyncValue.loading();
    await _fetchPage();
  }

  Future<void> loadMore() async {
    if (_isLoading || _isNoMore || _keyword.isEmpty) return;
    await _fetchPage();
  }

  Future<void> _fetchPage() async {
    _isLoading = true;
    try {
      final Map<String, dynamic> query = {'page': _currentPage};
      query['filter[products.name][\$like]'] = '%$_keyword%';

      final resp = await _dio.get(
        '${AppConfig.baseUrl}/ecommerce/products',
        queryParameters: query,
        options: Options(headers: {'X-API-Token': AppConfig.xApiToken}),
      );

      final parsed = ProductListResponse.fromJson(resp.data);
      var products = parsed.data?.data ?? [];

      if (products.isEmpty) {
        _isNoMore = true;
      } else {
        // Sort/filter off the main thread
        products = await compute(_sortProducts, {
          'products': products,
          'keyword': _keyword,
        });

        _results.addAll(products);
        _currentPage++;
      }

      state = AsyncValue.data(List.from(_results));
    } on DioException catch (e, st) {
      state = AsyncValue.error(
        e.response?.data['message'] ?? 'Check Internet',
        st,
      );
    } finally {
      _isLoading = false;
    }
  }
}

/// Top-level function for compute
List<ProductDataModel> _sortProducts(Map<String, dynamic> params) {
  final products = List<ProductDataModel>.from(params['products']);
  final keyword = (params['keyword'] as String).toLowerCase();

  products.sort((a, b) {
    final nameA = a.name?.toLowerCase() ?? '';
    final nameB = b.name?.toLowerCase() ?? '';

    if (nameA.startsWith(keyword) && !nameB.startsWith(keyword)) return -1;
    if (!nameA.startsWith(keyword) && nameB.startsWith(keyword)) return 1;
    if (nameA.contains(keyword) && !nameB.contains(keyword)) return -1;
    if (!nameA.contains(keyword) && nameB.contains(keyword)) return 1;
    return nameA.compareTo(nameB);
  });

  return products;
}

/// Provider
final combinedProductSearchProvider =
    StateNotifierProvider<
      CombinedProductSearchNotifier,
      AsyncValue<List<ProductDataModel>>
    >((ref) => CombinedProductSearchNotifier());
