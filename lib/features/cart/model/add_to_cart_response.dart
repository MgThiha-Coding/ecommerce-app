class AddToCartResponse {
  final bool? success;
  final String? message;
  final Data? data;

  AddToCartResponse({this.success, this.message, this.data});

  factory AddToCartResponse.fromJson(Map<String, dynamic> json) {
    return AddToCartResponse(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
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

class Data {
  final CartItem? cartItem;
  final String? cartTotal;
  final int? itemsCount;

  Data({this.cartItem, this.cartTotal, this.itemsCount});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      cartItem: json['cart_item'] != null ? CartItem.fromJson(json['cart_item']) : null,
      cartTotal: json['cart_total'] != null ? json['cart_total'].toString() : null,
      itemsCount: json['items_count'] is int ? json['items_count'] as int : int.tryParse(json['items_count']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cart_item': cartItem?.toJson(),
      'cart_total': cartTotal,
      'items_count': itemsCount,
    };
  }
}

class CartItem {
  final int? id;
  final int? cartId;
  final int? productId;
  final int? productVariantId;
  final String? quantity;
  final String? uomPrice;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? productFullName;

  CartItem({
    this.id,
    this.cartId,
    this.productId,
    this.productVariantId,
    this.quantity,
    this.uomPrice,
    this.createdAt,
    this.updatedAt,
    this.productFullName,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? ''),
      cartId: json['cart_id'] is int ? json['cart_id'] as int : int.tryParse(json['cart_id']?.toString() ?? ''),
      productId: json['product_id'] is int ? json['product_id'] as int : int.tryParse(json['product_id']?.toString() ?? ''),
      productVariantId: json['product_variant_id'] is int ? json['product_variant_id'] as int : int.tryParse(json['product_variant_id']?.toString() ?? ''),
      quantity: json['quantity']?.toString(),
      uomPrice: json['uom_price']?.toString(),
      productFullName: json['product_full_name'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
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
  }
}
