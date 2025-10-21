class AddToCartResponse {
  final bool? success;
  final String? message;
  final Data? data;

  AddToCartResponse({
    this.success,
    this.message,
    this.data,
  });

  factory AddToCartResponse.fromJson(Map<String, dynamic> json) {
    return AddToCartResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.toJson(),
      };
}

class Data {
  final CartItem? cartItem;
  final String? cartTotal;
  final int? itemsCount;

  Data({
    this.cartItem,
    this.cartTotal,
    this.itemsCount,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      cartItem: json['cart_item'] != null
          ? CartItem.fromJson(json['cart_item'])
          : null,
      cartTotal: json['cart_total']?.toString(),
      itemsCount: _parseInt(json['items_count']),
    );
  }

  Map<String, dynamic> toJson() => {
        'cart_item': cartItem?.toJson(),
        'cart_total': cartTotal,
        'items_count': itemsCount,
      };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}

class CartItem {
  final int? id;
  final int? cartId;
  final int? productId;
  final int? productVariantId;
  final String? quantity;
  final String? uomPrice;
  final String? productFullName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CartItem({
    this.id,
    this.cartId,
    this.productId,
    this.productVariantId,
    this.quantity,
    this.uomPrice,
    this.productFullName,
    this.createdAt,
    this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: Data._parseInt(json['id']),
      cartId: Data._parseInt(json['cart_id']),
      productId: Data._parseInt(json['product_id']),
      productVariantId: Data._parseInt(json['product_variant_id']),
      quantity: json['quantity']?.toString(),
      uomPrice: json['uom_price']?.toString(),
      productFullName: json['product_full_name'] as String?,
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cart_id': cartId,
        'product_id': productId,
        'product_variant_id': productVariantId,
        'quantity': quantity,
        'uom_price': uomPrice,
        'product_full_name': productFullName,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}
