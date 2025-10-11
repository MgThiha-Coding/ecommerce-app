import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/product/model/product_list_response.dart';

/// Product Search Notifier Provider
class ProductSearchNotifier
    extends StateNotifier<AsyncValue<List<ProductDataModel>>> {
  final Dio _dio;
  final List<ProductDataModel> _searchResults = [];
  int _currentPage = 1;
  bool _isNoMore = false;
  bool _isLoading = false;
  String _searchQuery = '';

  ProductSearchNotifier() : _dio = Dio(), super(const AsyncValue.data([]));

  bool get isNoMore => _isNoMore;
  bool get isLoading => _isLoading;

  Future<void> resetSearch() async {
    _searchResults.clear();
    _currentPage = 1;
    _isNoMore = false;
    _searchQuery = '';
    state = const AsyncValue.data([]);
  }

  Future<void> search(String query) async {
    _searchQuery = query.trim();
    _searchResults.clear();
    _currentPage = 1;
    _isNoMore = false;

    if (_searchQuery.isEmpty) {
      await resetSearch();
      return;
    }

    state = const AsyncValue.loading();
    await _fetchSearchPage();
  }

  Future<void> loadMore() async {
    if (_isLoading || _isNoMore || _searchQuery.isEmpty) return;
    await _fetchSearchPage();
  }

  Future<void> _fetchSearchPage() async {
    _isLoading = true;

    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/v1/ecommerce/products',
        queryParameters: {'page': _currentPage, 'search': _searchQuery},
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

/// Provider for ProductSearchNotifier
final productSearchNotifierProvider =
    StateNotifierProvider<
      ProductSearchNotifier,
      AsyncValue<List<ProductDataModel>>
    >((ref) {
      return ProductSearchNotifier();
    });
