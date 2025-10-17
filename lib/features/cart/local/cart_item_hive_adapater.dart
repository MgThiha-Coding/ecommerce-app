import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/features/cart/local/cart_item_hive_model.dart';

class CartItemHiveAdapter extends TypeAdapter<CartItemHiveModel> {
  @override
  final typeId = 3; 

  @override
  CartItemHiveModel read(BinaryReader reader) {
    return CartItemHiveModel(
      id: reader.readInt(),
      productName: reader.readString(),
      cartId: reader.readInt(),
      productId: reader.readInt(),
      productVariantId: reader.readInt(),
      quantity: reader.readDouble(),
      uomPrice: reader.readDouble(),
    );
  }

  @override
  void write(BinaryWriter writer, CartItemHiveModel obj) {
    writer.writeInt(obj.id ?? 0);
    writer.writeString(obj.productName ?? '');
    writer.writeInt(obj.cartId ?? 0);
    writer.writeInt(obj.productId ?? 0);
    writer.writeInt(obj.productVariantId ?? 0);
    writer.writeDouble(obj.quantity ?? 0);
    writer.writeDouble(obj.uomPrice ?? 0);
  }
}
