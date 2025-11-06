class CartItemResponse {
  final bool success;
  final String message;
  final List<CartItemModel> data;

  CartItemResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CartItemResponse.fromJson(Map<String, dynamic> json) {
    return CartItemResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((item) => CartItemModel.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'data': data.map((item) => item.toJson()).toList(),
  };
}

class CartItemModel {
  final int id;
  final String productName;
  final int cartId;
  final int productId;
  final int productVariantId;
  final double quantity;
  final double uomPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItemModel({
    required this.id,
    required this.productName,
    required this.cartId,
    required this.productId,
    required this.productVariantId,
    required this.quantity,
    required this.uomPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int? ?? 0,
      productName: json['product_name'] as String? ?? '',
      cartId: json['cart_id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      productVariantId: json['product_variant_id'] as int? ?? 0,
      quantity: (json['quantity'] is String)
          ? double.tryParse(json['quantity']) ?? 0
          : (json['quantity'] as num?)?.toDouble() ?? 0,
      uomPrice: (json['uom_price'] is String)
          ? double.tryParse(json['uom_price']) ?? 0
          : (json['uom_price'] as num?)?.toDouble() ?? 0,
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_name': productName,
    'cart_id': cartId,
    'product_id': productId,
    'product_variant_id': productVariantId,
    'quantity': quantity.toStringAsFixed(2),
    'uom_price': uomPrice.toStringAsFixed(2),
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
