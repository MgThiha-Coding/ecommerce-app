

import 'dart:convert';

class OrderHistoryResponse {
  final bool success;
  final String message;
  final List<OrderHistory> data;

  OrderHistoryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) {
    return OrderHistoryResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => OrderHistory.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() => jsonEncode(toJson());
}

class OrderHistory {
  final int id;
  final String orderNumber;
  final int contentId;
  final String status;
  final String checkoutType;
  final int saleId;
  final int? shippingMethodId;
  final int? paymentAccountId;
  final String? paymentsTransactionId;
  final String? approveScreenshoot;
  final String amountShipped;
  final String amountDiscount;
  final String amountTax;
  final String amountTotal;
  final List<dynamic> billingAddress;
  final ShippingAddress? shippingAddress;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? viewedAt;
  final List<OrderItem> items;

  OrderHistory({
    required this.id,
    required this.orderNumber,
    required this.contentId,
    required this.status,
    required this.checkoutType,
    required this.saleId,
    this.shippingMethodId,
    this.paymentAccountId,
    this.paymentsTransactionId,
    this.approveScreenshoot,
    required this.amountShipped,
    required this.amountDiscount,
    required this.amountTax,
    required this.amountTotal,
    required this.billingAddress,
    this.shippingAddress,
    required this.createdAt,
    required this.updatedAt,
    this.viewedAt,
    required this.items,
  });

  factory OrderHistory.fromJson(Map<String, dynamic> json) {
    return OrderHistory(
      id: json['id'] as int,
      orderNumber: json['order_number'] as String,
      contentId: json['content_id'] as int,
      status: json['status'] as String,
      checkoutType: json['checkout_type'] as String,
      saleId: json['sale_id'] as int,
      shippingMethodId: json['shipping_method_id'] as int?,
      paymentAccountId: json['payment_account_id'] as int?,
      paymentsTransactionId: json['payments_transaction_id'] as String?,
      approveScreenshoot: json['approve_screenshoot'] as String?,
      amountShipped: (json['amount_shipped'] ?? '').toString(),
      amountDiscount: (json['amount_discount'] ?? '').toString(),
      amountTax: (json['amount_tax'] ?? '').toString(),
      amountTotal: (json['amount_total'] ?? '').toString(),
      billingAddress: (json['billing_address'] as List<dynamic>?) ?? [],
      shippingAddress: json['shipping_address'] != null
          ? ShippingAddress.fromJson(json['shipping_address'])
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      viewedAt: json['viewed_at'] != null
          ? DateTime.tryParse(json['viewed_at'] as String)
          : null,
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'viewed_at': viewedAt?.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class ShippingAddress {
  final String? address;
  final String? township;
  final String? region;
  final String? postalCode;
  final String? country;
  final String? phone;

  ShippingAddress({
    this.address,
    this.township,
    this.region,
    this.postalCode,
    this.country,
    this.phone,
  });

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      address: json['address'] as String?,
      township: json['township'] as String?,
      region: json['region'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String?,
      phone: json['phone'] as String?,
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

class OrderItem {
  final int id;
  final int orderId;
  final int productId;
  final int productVariationId;
  final int uomId;
  final String quantity;
  final String uomPrice;
  final String subtotal;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productVariationId,
    required this.uomId,
    required this.quantity,
    required this.uomPrice,
    required this.subtotal,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      orderId: json['order_id'] as int,
      productId: json['product_id'] as int,
      productVariationId: json['product_variation_id'] as int,
      uomId: json['uom_id'] as int,
      quantity: (json['quantity'] ?? '').toString(),
      uomPrice: (json['uom_price'] ?? '').toString(),
      subtotal: (json['subtotal'] ?? '').toString(),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_variation_id': productVariationId,
      'uom_id': uomId,
      'quantity': quantity,
      'uom_price': uomPrice,
      'subtotal': subtotal,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
