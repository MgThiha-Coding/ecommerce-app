
import '../model/cart_item_response.dart';

class CartItemHiveModel {
  final int? id;
  final String? productName;
  final int? cartId;
  final int? productId;
  final int? productVariantId;
  final double? quantity;
  final double? uomPrice;

  CartItemHiveModel({
    required this.id,
    required this.productName,
    required this.cartId,
    required this.productId,
    required this.productVariantId,
    required this.quantity,
    required this.uomPrice,
  });

  // Convert from CartItem to Hive model
  factory CartItemHiveModel.fromCartItem(CartItemModel data) {
    return CartItemHiveModel(
      id: data.id,
      productName: data.productName,
      cartId: data.cartId,
      productId: data.productId,
      productVariantId: data.productVariantId,
      quantity: data.quantity,
      uomPrice: data.uomPrice,
    );
  }

  // Convert back from Hive model to CartItem
  CartItemModel toCartItem() {
    return CartItemModel(
      id: id ?? 0,
      productName: productName ?? '',
      cartId: cartId ?? 0,
      productId: productId ?? 0,
      productVariantId: productVariantId ?? 0,
      quantity: quantity ?? 0,
      uomPrice: uomPrice ?? 0,
      createdAt: DateTime.now(), // you can store createdAt separately if needed
      updatedAt: DateTime.now(),
    );
  }
}
