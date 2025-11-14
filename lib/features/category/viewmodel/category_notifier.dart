import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/core/network/safe_api_call.dart';
import 'package:picoshop_theme2/features/category/model/categories_detail_response.dart';
import 'package:picoshop_theme2/features/category/model/categories_list_response.dart';


/// Category list
class CategoryListNotifier
    extends StateNotifier<AsyncValue<List<CategoryDataModel>>> {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
    ),
  );

  final List<CategoryDataModel> _onlineCategories = [];
  int _currentPage = 1;
  bool _isNoMore = false;
  bool _isLoading = false;

  CategoryListNotifier() : super(const AsyncValue.loading()) {
     WidgetsBinding.instance.addPostFrameCallback((_) {
    _init();
  });
  }

  bool get isNoMore => _isNoMore;

  Future<void> _init() async => await getNextPage();

  Future<void> reset() async {
    _onlineCategories.clear();
    _currentPage = 1;
    _isNoMore = false;
    await getNextPage();
  }

  Future<void> getNextPage() async {
    if (_isNoMore || _isLoading) return;
    _isLoading = true;

    await safeApiCall(() async {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/ecommerce/categories',
        queryParameters: {'page': _currentPage},
        options: Options(headers: {
          'Accept': 'application/json',
          'X-API-Token': AppConfig.xApiToken,
        }),
      );

      final isSuccess =
          response.statusCode == 200 && response.data['success'] == true;

      if (!isSuccess) {
        state = AsyncValue.error(
          response.data['message'] ?? "Something went wrong",
          StackTrace.current,
        );
        return;
      }

      final parsed = CategoriesListResponse.fromJson(response.data);
      final categories = parsed.data.data;

      if (categories.isEmpty) {
        _isNoMore = true;
      } else {
        _onlineCategories.addAll(categories);
        _currentPage++;
      }

      state = AsyncValue.data(List.from(_onlineCategories));
    }, onError: (message) {
      if (_onlineCategories.isNotEmpty) {
        state = AsyncValue.data(List.from(_onlineCategories));
      } else {
        _isNoMore = true;
        state = AsyncValue.error(message, StackTrace.current);
      }
    });

    _isLoading = false;
  }
}

final categoryListNotifierProvider =
    StateNotifierProvider<CategoryListNotifier, AsyncValue<List<CategoryDataModel>>>(
  (ref) => CategoryListNotifier(),
);

/// Category detail
class CategoryDetailNotifier
    extends StateNotifier<AsyncValue<CategoryDetailResponse?>> {
  final Dio _dio;

  CategoryDetailNotifier([Dio? dio])
      : _dio = dio ?? Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 10),
          ),
        ),
        super(const AsyncValue.data(null));

  Future<void> getCategoryDetail(int id) async {
    await safeApiCall(() async {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/ecommerce/categories/details/$id',
        options: Options(headers: {
          'Accept': 'application/json',
          'X-API-Token': AppConfig.xApiToken,
        }),
      );

      final isSuccess =
          response.statusCode == 200 && response.data['success'] == true;

      if (isSuccess) {
        state = AsyncValue.data(CategoryDetailResponse.fromJson(response.data));
      } else {
        state = AsyncValue.error(
          response.data['message'] ?? "Something went wrong",
          StackTrace.current,
        );
      }
    }, onError: (message) {
      state = AsyncValue.error(message, StackTrace.current);
    });
  }
}

final categoryDetailNotifierProvider =
    StateNotifierProvider.autoDispose<CategoryDetailNotifier,
        AsyncValue<CategoryDetailResponse?>>(
  (ref) => CategoryDetailNotifier(),
);
