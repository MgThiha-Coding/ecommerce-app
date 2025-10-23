import 'dart:io';
import 'package:dio/dio.dart';

class CreateOrderRequest {
  final String orderType; // "delivery" or "pickup"
  final List<int> cartItemIds;
  final ShippingInfo shipping;
  final int? shippingMethodId;
  final int? shippingAccountId;
  final int paymentAccountId;
  final File? approveScreenshoot; // optional photo

  CreateOrderRequest({
    required this.orderType,
    required this.cartItemIds,
    required this.shipping,
    this.shippingMethodId,
    this.shippingAccountId,
    required this.paymentAccountId,
    this.approveScreenshoot,
  });

  /// Convert to Dio FormData for sending as POST request
  FormData toFormData() {
    final formData = FormData();

    // order type
    formData.fields.add(MapEntry('order_type', orderType));

    // cart_item_ids[0], cart_item_ids[1], ...
    for (int i = 0; i < cartItemIds.length; i++) {
      formData.fields.add(
          MapEntry('cart_item_ids[$i]', cartItemIds[i].toString()));
    }

    // shipping info: shipping[address], shipping[township], ...
    formData.fields.add(MapEntry('shipping[address]', shipping.address));
    formData.fields.add(MapEntry('shipping[township]', shipping.township));
    formData.fields.add(MapEntry('shipping[region]', shipping.region));
    formData.fields.add(MapEntry('shipping[country]', shipping.country));
    formData.fields.add(MapEntry('shipping[phone]', shipping.phone));

    // optional fields
    if (shippingMethodId != null) {
      formData.fields
          .add(MapEntry('shipping_method_id', shippingMethodId.toString()));
    }
    if (shippingAccountId != null) {
      formData.fields
          .add(MapEntry('shipping_account_id', shippingAccountId.toString()));
    }

    formData.fields.add(
        MapEntry('payment_account_id', paymentAccountId.toString()));

    // approve screenshot as file
    if (approveScreenshoot != null) {
      formData.files.add(MapEntry(
        'approve_screenshoot',
        MultipartFile.fromFileSync(
          approveScreenshoot!.path,
          filename: approveScreenshoot!.path.split('/').last,
        ),
      ));
    }

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
