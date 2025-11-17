class CreateOrderResponse {
  final bool success;
  final String message;
  final OrderData? data;

  CreateOrderResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? OrderData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class OrderData {
  final String orderNumber;
  final int contentId;
  final String status;
  final String checkoutType;
  final int saleId;
  final int? shippingMethodId;
  final String paymentAccountId;
  final String? paymentsTransactionId;
  final String? approveScreenshoot;
  final double amountShipped;
  final double amountDiscount;
  final double amountTax;
  final double amountTotal;
  final List<dynamic> billingAddress;
  final ShippingAddress? shippingAddress;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final int id;

  OrderData({
    required this.orderNumber,
    required this.contentId,
    required this.status,
    required this.checkoutType,
    required this.saleId,
    this.shippingMethodId,
    required this.paymentAccountId,
    this.paymentsTransactionId,
    this.approveScreenshoot,
    required this.amountShipped,
    required this.amountDiscount,
    required this.amountTax,
    required this.amountTotal,
    required this.billingAddress,
    this.shippingAddress,
    this.updatedAt,
    this.createdAt,
    required this.id,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    dynamic billingRaw = json['billing_address'];
    List<dynamic> safeBilling;
    if (billingRaw is List) {
      safeBilling = billingRaw;
    } else if (billingRaw is Map) {
      safeBilling = [billingRaw];
    } else {
      safeBilling = [];
    }

    return OrderData(
      orderNumber: json['order_number'] ?? '',
      contentId: int.tryParse(json['content_id'].toString()) ?? 0,
      status: json['status'] ?? '',
      checkoutType: json['checkout_type'] ?? '',
      saleId: int.tryParse(json['sale_id'].toString()) ?? 0,
      shippingMethodId: json['shipping_method_id'] != null
          ? int.tryParse(json['shipping_method_id'].toString())
          : null,
      paymentAccountId: json['payment_account_id']?.toString() ?? '',
      paymentsTransactionId: json['payments_transaction_id'],
      approveScreenshoot: json['approve_screenshoot'],
      amountShipped: double.tryParse(json['amount_shipped'].toString()) ?? 0,
      amountDiscount: double.tryParse(json['amount_discount'].toString()) ?? 0,
      amountTax: double.tryParse(json['amount_tax'].toString()) ?? 0,
      amountTotal: double.tryParse(json['amount_total'].toString()) ?? 0,
      billingAddress: safeBilling,
      shippingAddress: json['shipping_address'] != null
          ? ShippingAddress.fromJson(json['shipping_address'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      id: int.tryParse(json['id'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order_number': orderNumber,
      'content_id': contentId,
      'status': status,
      'checkout_type': checkoutType,
      'sale_id': saleId,
      'shipping_method_id': shippingMethodId,
      'payment_account_id': paymentAccountId,
      'payments_transaction_id': paymentsTransactionId,
      'approve_screenshoot': approveScreenshoot,
      'amount_shipped': amountShipped,
      'amount_discount': amountDiscount,
      'amount_tax': amountTax,
      'amount_total': amountTotal,
      'billing_address': billingAddress,
      'shipping_address': shippingAddress?.toJson(),
      'updated_at': updatedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'id': id,
    };
  }
}

class ShippingAddress {
  final String address;
  final String township;
  final String region;
  final String? postalCode;
  final String country;
  final String phone;

  ShippingAddress({
    required this.address,
    required this.township,
    required this.region,
    this.postalCode,
    required this.country,
    required this.phone,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      address: json['address'] ?? '',
      township: json['township'] ?? '',
      region: json['region'] ?? '',
      postalCode: json['postal_code'],
      country: json['country'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'township': township,
      'region': region,
      'postal_code': postalCode,
      'country': country,
      'phone': phone,
    };
  }
}
