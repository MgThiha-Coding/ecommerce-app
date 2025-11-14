import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/core/network/refresh_token_mixin.dart';
import 'package:picoshop_theme2/features/business_setting/model/business_setting_response.dart';

class BusinessSettingNotifier
    extends StateNotifier<AsyncValue<BusinessSettingData?>>
    with RefreshTokenMixin {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
    ),
  );
  bool _isLoading = false;

  BusinessSettingData? _cachedSetting;

  BusinessSettingNotifier() : super(const AsyncValue.loading()) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    if (_cachedSetting != null) {
      state = AsyncValue.data(_cachedSetting);
    }
    await fetchBusinessSetting();
  }

  Future<void> fetchBusinessSetting() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/ecommerce/settings',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${AppConfig.accessToken}',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );

      if (response.statusCode == 401) {
        final refreshed = await refreshAndRetry((token) async {
          return await _dio.get(
            '${AppConfig.baseUrl}/ecommerce/settings',
            options: Options(
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
                'X-API-Token': AppConfig.xApiToken,
              },
            ),
          );
        });
        if (refreshed != null) {
          await _handleResponse(refreshed);
          _isLoading = false;
          return;
        }
      }

      await _handleResponse(response);
    } on DioException catch (e) {
      String message = 'Check your internet connection.';
      if (e.response?.data != null && e.response?.data['message'] != null) {
        message = e.response!.data['message'];
      }

      if (_cachedSetting != null) {
        state = AsyncValue.data(_cachedSetting);
      } else {
        state = AsyncValue.error(message, StackTrace.current);
      }
    } catch (e, st) {
      if (_cachedSetting != null) {
        state = AsyncValue.data(_cachedSetting);
      } else {
        state = AsyncValue.error(e.toString(), st);
      }
    }

    _isLoading = false;
  }

  Future<void> _handleResponse(Response response) async {
    final isSuccess =
        response.statusCode == 200 && response.data['success'] == true;

    if (!isSuccess) {
      state = AsyncValue.error(
        response.data['message'] ?? "Failed to fetch business settings",
        StackTrace.current,
      );
      return;
    }

    final parsed = BusinessSettingResponse.fromJson(response.data);

    if (parsed.data.isNotEmpty) {
      final businessSetting = parsed.data.first;
      _cachedSetting = businessSetting;
      state = AsyncValue.data(businessSetting);
    } else {
      state = AsyncValue.error(
        'No business settings found',
        StackTrace.current,
      );
    }
  }

  Currency? get currency => state.value?.currency;

  String get currencySymbol => state.value?.currency.symbol ?? '';

  String formatPrice(double price) {
    final setting = state.value;
    if (setting == null) return price.toString();
    return '${setting.currency.symbol}${price.toStringAsFixed(setting.currencyDecimalPlaces)}';
  }

  Future<void> refresh() async {
    await fetchBusinessSetting();
  }
}

// Provider
final businessSettingNotifierProvider =
    StateNotifierProvider<BusinessSettingNotifier, AsyncValue<BusinessSettingData?>>(
        (ref) => BusinessSettingNotifier());
