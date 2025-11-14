  import 'dart:async';
  import 'package:dio/dio.dart';
  import 'package:flutter/widgets.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:picoshop_theme2/core/config/app_config.dart';
  import 'package:picoshop_theme2/core/network/safe_api_call.dart';
  import 'package:picoshop_theme2/features/product/model/product_detail_response.dart';
  import 'package:picoshop_theme2/features/product/model/product_list_response.dart';

  /// Helper class to define filter operator and value
  class FilterValue {
    final String operator; // eq, ne, lt, lte, gt, gte, like
    final dynamic value;

    FilterValue(this.operator, this.value);
  }

  /// Build query parameters for filters automatically
  Map<String, dynamic> buildFilterParams(Map<String, dynamic> filters) {
    final Map<String, dynamic> queryParams = {};
    filters.forEach((key, value) {
      if (value is FilterValue) {
        queryParams['filter[products.$key][\$${value.operator}]'] = value.value;
      } else {
        // Default to equality if raw value
        queryParams['filter[products.$key][\$eq]'] = value;
      }
    });
    return queryParams;
  }

  /// Product List Notifier
  class ProductListNotifier
      extends StateNotifier<AsyncValue<List<ProductDataModel>>> {
    final Dio _dio = Dio();
    final List<ProductDataModel> _onlineProducts = [];
    int _currentPage = 1;
    bool _isNoMore = false;
    bool _isLoading = false;

    Map<String, dynamic> _filters = {};

    ProductListNotifier() : super(const AsyncValue.loading()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _init();
      });
    }

    bool get isNoMore => _isNoMore;

    Future<void> _init() async {
      await getNextPage();
    }

    /// Set filters (category, price, etc.) and refresh list
    Future<void> setFilters(Map<String, dynamic> filters) async {
      _filters = filters;
      await reset();
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

      await safeApiCall(
        () async {
          try {
            // Merge pagination and filters
            final queryParams = {
              'page': _currentPage,
              ...buildFilterParams(_filters),
            };

            final response = await _dio.get(
              '${AppConfig.baseUrl}/ecommerce/products',
              queryParameters: queryParams,
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
              _currentPage++;
            }

            state = AsyncValue.data(List.from(_onlineProducts));
          } on DioException catch (e) {
            String message = 'Check your internet connection.';
            if (e.response?.data != null && e.response?.data['message'] != null) {
              message = e.response!.data['message'];
            }
            state = AsyncValue.error(message, StackTrace.current);
          } catch (e, st) {
            state = AsyncValue.error(e.toString(), st);
          }
        },
        onError: (message) {
          state = AsyncValue.error(message, StackTrace.current);
        },
      );

      _isLoading = false;
    }
  }

  /// Riverpod provider
  final productNotifierProvider =
      StateNotifierProvider<
        ProductListNotifier,
        AsyncValue<List<ProductDataModel>>
      >((ref) => ProductListNotifier());

  /// Product Detail Notifier
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
      await safeApiCall(
        () async {
          final response = await _dio.get(
            '${AppConfig.baseUrl}/ecommerce/products/details/$productId',
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
            state = AsyncValue.data(
              ProductDetailResponse.fromJson(response.data),
            );
          } else {
            state = AsyncValue.error(
              response.data['message'] ?? 'Something went wrong',
              StackTrace.current,
            );
          }
        },
        onError: (message) {
          state = AsyncValue.error(message, StackTrace.current);
        },
      );
    }
  }

  final productDetailNotifierProvider =
      StateNotifierProvider.autoDispose<
        ProductDetailNotifier,
        AsyncValue<ProductDetailResponse?>
      >((ref) => ProductDetailNotifier());
