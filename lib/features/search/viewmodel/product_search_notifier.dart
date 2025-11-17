import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/product/model/product_list_response.dart';
import 'package:picoshop_theme2/features/brands/model/brand_list_response.dart';
import 'package:picoshop_theme2/features/category/model/categories_list_response.dart';

class CombinedProductSearchNotifier
    extends StateNotifier<AsyncValue<List<dynamic>>> {
  final Dio _dio = Dio();
  final List<dynamic> _results = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isNoMore = false;

  String _keyword = '';
  String _filterType = 'product';

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
    _filterType = filterType;
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

      switch (_filterType) {
        case 'brand':
          query['filter[brands.name][\$like]'] = '%$_keyword%';
          break;
        case 'category':
          query['filter[categories.name][\$like]'] = '%$_keyword%';
          break;
        default:
          query['filter[products.name][\$like]'] = '%$_keyword%';
      }

      final url = switch (_filterType) {
        'brand' => '${AppConfig.baseUrl}/ecommerce/brands',
        'category' => '${AppConfig.baseUrl}/ecommerce/categories',
        _ => '${AppConfig.baseUrl}/ecommerce/products',
      };

      final resp = await _dio.get(
        url,
        queryParameters: query,
        options: Options(headers: {'X-API-Token': AppConfig.xApiToken}),
      );

      List<dynamic> results;

      if (_filterType == 'product') {
        final parsed = ProductListResponse.fromJson(resp.data);
        results = parsed.data?.data ?? [];
      } else if (_filterType == 'brand') {
        final parsed = BrandListResponse.fromJson(resp.data);
        results = parsed.data?.data ?? [];
      } else {
        final parsed = CategoriesListResponse.fromJson(resp.data);
        results = parsed.data.data;
      }

      if (results.isEmpty) {
        _isNoMore = true;
      } else {
        _results.addAll(results);
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

/// Riverpod provider
final combinedProductSearchProvider =
    StateNotifierProvider<CombinedProductSearchNotifier, AsyncValue<List<dynamic>>>(
        (ref) => CombinedProductSearchNotifier());
