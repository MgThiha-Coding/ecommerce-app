import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/shipping/model/shipping_method_response.dart';

class ShippingMethodNotifier
    extends StateNotifier<AsyncValue<ShippingMethodResponse?>> {
  final Dio _dio;
  ShippingMethodNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));

  Future<void> getShippingMethod() async {
    try {
      final response = await _dio.get(
        'https://beta.picosbs.com/api/ecommerce/shipping-methods',
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
      if (isSuccess) {
        final responseData = ShippingMethodResponse.fromJson(response.data);
        state = AsyncValue.data(responseData);
      }
    } on DioException catch (e, st) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error('Check Internet', st);
      } else {
        final errorData = e.response?.data['messsage'];
        state = AsyncValue.error(errorData, st);
      }
    }
  }
}

final shippingMethodNotifierProvider =
    StateNotifierProvider<
      ShippingMethodNotifier,
      AsyncValue<ShippingMethodResponse?>
    >((ref) => ShippingMethodNotifier());
