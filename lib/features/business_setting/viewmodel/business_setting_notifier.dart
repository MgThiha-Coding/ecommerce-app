import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/business_setting/local/business_setting_hive_model.dart';
import 'package:picoshop_theme2/features/business_setting/model/business_setting_response.dart';

class BusinessSettingNotifier
    extends StateNotifier<AsyncValue<BusinessSettingData?>> {
  final Box<BusinessSettingHiveModel> _localCache;
  final Dio _dio;
  bool _isLoading = false;

  BusinessSettingNotifier(this._localCache)
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),
        ),
      ),
      super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    final cached = _localCache.get('business_settings');
    if (cached != null) {
      state = AsyncValue.data(cached.toDataModel());
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

      final isSuccess =
          response.statusCode == 200 && response.data['success'] == true;

      if (!isSuccess) {
        final message =
            response.data['message'] ?? "Failed to fetch business settings";
        state = AsyncValue.error(message, StackTrace.current);
        return;
      }

      final parsed = BusinessSettingResponse.fromJson(response.data);

      if (parsed.data.isNotEmpty) {
        final businessSetting = parsed.data.first;
        // Save to local cache
        final hiveModel = BusinessSettingHiveModel.fromDataModel(
          businessSetting,
        );
        _localCache.put('business_settings', hiveModel);
        state = AsyncValue.data(businessSetting);
      } else {
        state = AsyncValue.error(
          'No business settings found',
          StackTrace.current,
        );
      }
    } on DioException catch (e, st) {
      // If online fetch fails, use cached data if available
      final cached = _localCache.get('business_settings');
      if (cached != null) {
        state = AsyncValue.data(cached.toDataModel());
      } else {
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.unknown) {
          state = AsyncValue.error('Check your connection', st);
        } else {
          state = AsyncValue.error(
            e.response?.data['message'] ?? 'Failed to fetch settings',
            st,
          );
        }
      }
    } finally {
      _isLoading = false;
    }
  }

  // Helper method to get currency info for products
  Currency? get currency {
    return state.value?.currency;
  }

  // Helper method to get currency symbol
  String get currencySymbol {
    return state.value?.currency.symbol ?? '';
  }

  // Helper method to format price according to business settings
  String formatPrice(double price) {
    final setting = state.value;
    if (setting == null) return price.toString();

    final decimalPlaces = setting.currencyDecimalPlaces;
    return '${setting.currency.symbol}${price.toStringAsFixed(decimalPlaces)}';
  }

  Future<void> refresh() async {
    await fetchBusinessSetting();
  }
}

final businessSettingNotifierProvider =
    StateNotifierProvider<
      BusinessSettingNotifier,
      AsyncValue<BusinessSettingData?>
    >((ref) {
      final box = Hive.box<BusinessSettingHiveModel>('business_settings');
      return BusinessSettingNotifier(box);
    });
