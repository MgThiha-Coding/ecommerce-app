import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/product/model/response/product_detail_response.dart';
import 'package:picoshop_theme2/features/product/model/response/product_list_response.dart';

// search notifier provider 
class ProductFilterState {
  final String searchQuery;
  final List<ChildData?> filteredList;

  ProductFilterState({this.searchQuery = '', this.filteredList = const []});

  ProductFilterState copyWith({String? searchQuery, List<ChildData?>? filteredList}) {
    return ProductFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      filteredList: filteredList ?? this.filteredList,
    );
  }
}

class ProductFilterNotifier extends StateNotifier<ProductFilterState> {
  final List<ChildData?> allProducts;

  ProductFilterNotifier(this.allProducts) : super(ProductFilterState(filteredList: allProducts));

  void updateSearchQuery(String query) {
    final filtered = allProducts.where((product) {
      final name = product?.name?.toLowerCase() ?? '';
      return name.contains(query.toLowerCase());
    }).toList();

    state = state.copyWith(searchQuery: query, filteredList: filtered);
  }

  void reset() {
    state = ProductFilterState(filteredList: allProducts);
  }
}

final productFilterProvider = StateNotifierProvider.family<ProductFilterNotifier, ProductFilterState, List<ChildData?>>(
  (ref, allProducts) => ProductFilterNotifier(allProducts),
);

// product list
class ProductListNotifier extends StateNotifier<AsyncValue<List<ChildData?>>> {
  final Dio _dio;
  ProductListNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data([]));

  Future<void> getProductList(int page) async {
    try {
      final response = await _dio.get(
        'https://beta.picosbs.com/api/v1/ecommerce/products?page=$page',
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
        final responseData = ProductListResponse.fromJson(response.data);
        final newProductList = responseData.data?.data ?? [];
        state = state.whenData(
          (oldProductList) => [...oldProductList, ...newProductList],
        );
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

final productNotifierProvider =
    StateNotifierProvider<ProductListNotifier, AsyncValue<List<ChildData?>>>(
      (ref) => ProductListNotifier(),
    );

// product detail
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
