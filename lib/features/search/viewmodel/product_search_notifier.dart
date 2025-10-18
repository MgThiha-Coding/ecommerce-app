import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/product/model/product_list_response.dart';

/// Product Search Notifier 
class ProductSearchNotifier
    extends StateNotifier<AsyncValue<List<ProductDataModel>>> {
  final Dio _dio;
  final List<ProductDataModel> _searchResults = [];
  int _currentPage = 1;
  bool _isNoMore = false;
  bool _isLoading = false;

  String _nameQuery = '';
  String _brandQuery = '';
  String _categoryQuery = '';

  ProductSearchNotifier() : _dio = Dio(), super(const AsyncValue.data([]));

  bool get isNoMore => _isNoMore;
  bool get isLoading => _isLoading;

  Future<void> resetSearch() async {
    _searchResults.clear();
    _currentPage = 1;
    _isNoMore = false;
    _nameQuery = '';
    _brandQuery = '';
    _categoryQuery = '';
    state = const AsyncValue.data([]);
  }

  Future<void> search({
    String? name,
    String? brand,
    String? category,
    String? keyword,
  }) async {
    final kw = keyword?.trim() ?? '';

    _nameQuery = name?.trim() ?? (kw.isNotEmpty ? kw : '');
    _brandQuery = brand?.trim() ?? (kw.isNotEmpty ? kw : '');
    _categoryQuery = category?.trim() ?? (kw.isNotEmpty ? kw : '');

    _searchResults.clear();
    _currentPage = 1;
    _isNoMore = false;

    if (_nameQuery.isEmpty && _brandQuery.isEmpty && _categoryQuery.isEmpty) {
      await resetSearch();
      return;
    }

    state = const AsyncValue.loading();

    await _fetchSearchPage();
  }

  Future<void> loadMore() async {
    if (_isLoading || _isNoMore) return;
    if (_nameQuery.isEmpty && _brandQuery.isEmpty && _categoryQuery.isEmpty) {
      return;
    }
    await _fetchSearchPage();
  }

  Future<void> _fetchSearchPage() async {
    _isLoading = true;

    try {
      final Map<String, dynamic> filters = {
        'page': _currentPage,
        if (_nameQuery.isNotEmpty)
          'filter[products.name][\$like]': '%$_nameQuery%',
        if (_brandQuery.isNotEmpty)
          'filter[products.brand][\$like]': '%$_brandQuery%',
        if (_categoryQuery.isNotEmpty)
          'filter[products.category][\$like]': '%$_categoryQuery%',
      };

      final response = await _dio.get(
        'https://beta.picosbs.com/api/ecommerce/products',
        queryParameters: filters,
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
        final msg = response.data['message'] ?? "Search failed. Try again.";
        state = AsyncValue.error(msg, StackTrace.current);
        return;
      }

      final parsed = ProductListResponse.fromJson(response.data);
      final products = parsed.data?.data ?? [];
      if (products.isEmpty) {
        _isNoMore = true;
      } else {
        _searchResults.addAll(products);
        _currentPage++;
      }

      final connectivity = await Connectivity().checkConnectivity();
      // ignore: unrelated_type_equality_checks
      final isOnline = connectivity != ConnectivityResult.none;

      if (isOnline) {
        state = AsyncValue.data(List.from(_searchResults));
      } else {
        state = AsyncValue.data(List.from(_searchResults));
      }
    } on DioException catch (e, st) {
      final msg = e.type == DioExceptionType.connectionError
          ? 'Check Internet Connection'
          : e.message ?? 'Something went wrong';
      state = AsyncValue.error(msg, st);
    } finally {
      _isLoading = false;
    }
  }
}

final productSearchNotifierProvider =
    StateNotifierProvider<
      ProductSearchNotifier,
      AsyncValue<List<ProductDataModel>>
    >((ref) {
      return ProductSearchNotifier();
    });
