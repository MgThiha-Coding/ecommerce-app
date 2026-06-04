import 'dart:io';
import 'package:dio/dio.dart';

class CreateOrderRequest {
  final String orderType; 
  final List<int> cartItemIds;
  final ShippingInfo shipping;
  final int? shippingMethodId;
  final int? shippingAccountId;
  final int paymentAccountId;
  final File approveScreenshot; 

  CreateOrderRequest({
    required this.orderType,
    required this.cartItemIds,
    required this.shipping,
    this.shippingMethodId,
    this.shippingAccountId,
    required this.paymentAccountId,
    required this.approveScreenshot,
  });

  /// Convert to FormData for multipart upload
  FormData toFormData() {
    final formData = FormData();

    formData.fields.add(MapEntry('order_type', orderType));

    // Add cart items
    for (int i = 0; i < cartItemIds.length; i++) {
      formData.fields.add(
        MapEntry('cart_item_ids[$i]', cartItemIds[i].toString()),
      );
    }

    // Add shipping fields
    formData.fields.add(MapEntry('shipping[address]', shipping.address));
    formData.fields.add(MapEntry('shipping[township]', shipping.township));
    formData.fields.add(MapEntry('shipping[region]', shipping.region));
    formData.fields.add(MapEntry('shipping[country]', shipping.country));
    formData.fields.add(MapEntry('shipping[phone]', shipping.phone));

    // Optional fields
    if (shippingMethodId != null) {
      formData.fields.add(MapEntry('shipping_method_id', shippingMethodId.toString()));
    }
    if (shippingAccountId != null) {
      formData.fields.add(MapEntry('shipping_account_id', shippingAccountId.toString()));
    }

    // Payment field
    formData.fields.add(MapEntry('payment_account_id', paymentAccountId.toString()));

    // Add screenshot file
    formData.files.add(
      MapEntry(
        'approve_screenshoot',
        MultipartFile.fromFileSync(
          approveScreenshot.path,
          filename: approveScreenshot.path.split('/').last,
        ),
      ),
    );

    return formData;
  }
}

class ShippingInfo {
  final String address;
  final String township;
  final String region;
  final String country;
  final String phone;

  ShippingInfo({
    required this.address,
    required this.township,
    required this.region,
    required this.country,
    required this.phone,
  });
}
