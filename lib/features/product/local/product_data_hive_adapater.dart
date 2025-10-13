import 'package:hive_flutter/adapters.dart';
import 'package:picoshop_theme2/features/product/local/product_data_hive.dart';

class ProductDataHiveAdapter extends TypeAdapter<ProductHiveModel> {
  @override
  final typeId = 0; 

  @override
  ProductHiveModel read(BinaryReader reader) {
    return ProductHiveModel(
      id: reader.readInt(),
      name: reader.readString(),
      productImage: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, ProductHiveModel obj) {
    writer.writeInt(obj.id ?? 0);
    writer.writeString(obj.name ?? '');
    writer.writeString(obj.productImage ?? '');
  }
}
