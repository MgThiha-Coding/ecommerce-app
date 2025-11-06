import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/core/network/refresh_token_mixin.dart';
import 'package:picoshop_theme2/features/order_history/model/order_history_response.dart';

class OrderHistoriesNotifier
    extends StateNotifier<AsyncValue<OrderHistoryResponse?>>
    with RefreshTokenMixin {
  final Dio _dio;

  OrderHistoriesNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));

  Future<void> getOrderHistories() async {
    state = const AsyncValue.loading();

    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/ecommerce/order/histories',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${AppConfig.accessToken}',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );

      await _handleResponse(response);
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 401) {
        final refreshed = await refreshAndRetry((token) async {
          return await _dio.get(
            '${AppConfig.baseUrl}/ecommerce/order/histories',
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
          return;
        }
      }

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error('Check Internet', st);
      } else {
        final errorData = e.response?.data ?? e.message;
        state = AsyncValue.error(errorData, st);
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> _handleResponse(Response response) async {
    final isSuccess =
        response.data != null &&
        response.statusCode == 200 &&
        response.data['success'] == true;

    if (isSuccess) {
      final responseData = OrderHistoryResponse.fromJson(response.data);
      state = AsyncValue.data(responseData);
    } else {
      state = AsyncValue.error(
        response.data?['message'] ?? 'Failed to load order histories',
        StackTrace.current,
      );
    }
  }

  Future<void> refresh() async {
    await getOrderHistories();
  }
}

final orderHistoriesNotifierProvider =
    StateNotifierProvider<
      OrderHistoriesNotifier,
      AsyncValue<OrderHistoryResponse?>
    >((ref) => OrderHistoriesNotifier());
