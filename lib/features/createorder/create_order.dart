import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/create_address/model/response/address_response.dart';
import 'package:picoshop_theme2/features/payment/model/response/payment_method_response.dart';
import 'package:picoshop_theme2/features/shipping/model/shipping_method_response.dart';

final orderNotifierProvider =
    StateNotifierProvider<OrderNotifier, AsyncValue<Map<String, dynamic>?>>(
      (ref) => OrderNotifier(),
    );

class OrderNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final Dio _dio;

  OrderNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));

  Future<void> createOrder({
    required String orderType,
    required List<int> cartItemIds,
    required AddressItem address,
    required ShippingMethod shipping,
    required PaymentMethod payment,
    required File approveScreenshot,
  }) async {
    try {
      state = const AsyncValue.loading();

      final formData = FormData();

      // Order type
      formData.fields.add(MapEntry("order_type", orderType));

      // Cart items
      for (var i = 0; i < cartItemIds.length; i++) {
        formData.fields.add(
          MapEntry("cart_item_ids[$i]", cartItemIds[i].toString()),
        );
      }

      // Shipping info
      formData.fields.addAll([
        MapEntry("shipping[address]", address.addressLine1),
        MapEntry("shipping[township]", address.townshipEnName),
        MapEntry("shipping[region]", address.regionEnName),
        MapEntry("shipping[country]", address.country),
        MapEntry("shipping[phone]", address.phone),
        MapEntry("shipping_method_id", shipping.id.toString()),
        const MapEntry("shipping_account_id", '1'),
      ]);

      // Payment info
      formData.fields.add(
        MapEntry("payment_account_id", payment.paymentAccount!.id.toString()),
      );

      // Screenshot file
      formData.files.add(
        MapEntry(
          "approve_screenshoot",
          await MultipartFile.fromFile(
            approveScreenshot.path,
            filename: approveScreenshot.path.split("/").last,
          ),
        ),
      );

      final response = await _dio.post(
        "${AppConfig.baseUrl}/v1/ecommerce/order",
        data: formData,
        options: Options(
          headers: {
            "Accept": "application/json",
            "X-API-Token": AppConfig.xApiToken,
            "Authorization": "Bearer ${AppConfig.accessToken}",
          },
          contentType: 'multipart/form-data',
        ),
      );

      state = AsyncValue.data(response.data);
    } on DioException catch (e, st) {
      final errorData = e.response?.data ?? e.message;
      state = AsyncValue.error(errorData.toString(), st);
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }
}
