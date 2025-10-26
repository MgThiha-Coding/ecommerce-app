class AddToCartResponse {
  final bool? success;
  final String? message;
  final List<CartItem>? data; // Changed from Data? to List<CartItem>?

  AddToCartResponse({
    this.success,
    this.message,
    this.data,
  });

  factory AddToCartResponse.fromJson(Map<String, dynamic> json) {
    return AddToCartResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] is List
          ? (json['data'] as List).map((item) => CartItem.fromJson(item)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'message': message,
        'data': data?.map((item) => item.toJson()).toList(),
      };
}

class CartItem {
  final int? id;
  final int? cartId;
  final int? productId;
  final int? productVariantId;
  final String? quantity;
  final String? uomPrice;
  final String? productName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CartItem({
    this.id,
    this.cartId,
    this.productId,
    this.productVariantId,
    this.quantity,
    this.uomPrice,
    this.productName,
    this.createdAt,
    this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: _parseInt(json['id']),
      cartId: _parseInt(json['cart_id']),
      productId: _parseInt(json['product_id']),
      productVariantId: _parseInt(json['product_variant_id']),
      quantity: json['quantity']?.toString(),
      uomPrice: json['uom_price']?.toString(),
      productName: json['product_name'] as String?,
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
        'product_name': productName,
        'created_at': createdAt?.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
      };

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

