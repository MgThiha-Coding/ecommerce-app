import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/brands/model/brand_detail_response.dart';
import 'package:picoshop_theme2/features/brands/model/brand_list_response.dart';

/// Brand List Notifier
class BrandListNotifier extends StateNotifier<AsyncValue<List<BrandDataModel>>> {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
    ),
  );

  final List<BrandDataModel> _onlineBrands = [];
  int _currentPage = 1;
  bool _isNoMore = false;
  bool _isLoading = false;

  BrandListNotifier() : super(const AsyncValue.loading()) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  bool get isNoMore => _isNoMore;

  Future<void> _init() async => await getNextPage();

  Future<void> reset() async {
    _onlineBrands.clear();
    _currentPage = 1;
    _isNoMore = false;
    await getNextPage();
  }

  Future<void> getNextPage() async {
    if (_isNoMore || _isLoading) return;
    _isLoading = true;

    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/ecommerce/brands',
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
          response.data['message'] ?? "Something went wrong",
          StackTrace.current,
        );
        _isLoading = false;
        return;
      }

      final parsed = BrandListResponse.fromJson(response.data);
      final brands = parsed.data?.data ?? [];

      if (brands.isEmpty) {
        _isNoMore = true;
      } else {
        _onlineBrands.addAll(brands);
        _currentPage++;
      }

      state = AsyncValue.data(List.from(_onlineBrands));
    } on DioException catch (e) {
      String message = 'Check your internet connection.';
      if (e.response?.data != null && e.response?.data['message'] != null) {
        message = e.response!.data['message'];
      }

      if (_onlineBrands.isNotEmpty) {
        state = AsyncValue.data(List.from(_onlineBrands));
      } else {
        _isNoMore = true;
        state = AsyncValue.error(message, StackTrace.current);
      }
    } catch (e, st) {
      if (_onlineBrands.isNotEmpty) {
        state = AsyncValue.data(List.from(_onlineBrands));
      } else {
        _isNoMore = true;
        state = AsyncValue.error(e.toString(), st);
      }
    }

    _isLoading = false;
  }
}

final brandListNotifierProvider =
    StateNotifierProvider<BrandListNotifier, AsyncValue<List<BrandDataModel>>>(
        (ref) => BrandListNotifier());


/// Brand Detail Notifier
class BrandDetailNotifier extends StateNotifier<AsyncValue<BrandDetailResponse?>> {
  final Dio _dio;

  BrandDetailNotifier([Dio? dio])
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 10),
              ),
            ),
        super(const AsyncValue.data(null));

  Future<void> getBrandDetail(int id) async {
    state = const AsyncValue.loading();

    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/ecommerce/brands/details/$id',
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
        state = AsyncValue.data(BrandDetailResponse.fromJson(response.data));
      } else {
        state = AsyncValue.error(
          response.data['message'] ?? "Something went wrong",
          StackTrace.current,
        );
      }
    } on DioException catch (e) {
      String message = 'Check your internet connection.';
      if (e.response?.data != null && e.response?.data['message'] != null) {
        message = e.response!.data['message'];
      }
      state = AsyncValue.error(message, StackTrace.current);
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }
}

final brandDetailNotifierProvider =
    StateNotifierProvider.autoDispose<BrandDetailNotifier,
        AsyncValue<BrandDetailResponse?>>((ref) => BrandDetailNotifier());
