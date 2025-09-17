import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/features/cart/model/response/total_cart_item_model.dart';

class TotalCartItemHiveAdapter extends TypeAdapter<TotalCartItemHiveModel> {
  @override
  final typeId = 2;

  @override
  TotalCartItemHiveModel read(BinaryReader reader) {
    return TotalCartItemHiveModel(totalItems: reader.readInt());
  }

  @override
  void write(BinaryWriter writer, TotalCartItemHiveModel obj) {
    writer.writeInt(obj.totalItems);
  }
}
