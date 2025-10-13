import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/features/brands/local/brand_data_hive.dart';

class BrandDataHiveAdapter extends TypeAdapter<BrandHiveModel> {
  @override
  final typeId = 1;

  @override
  BrandHiveModel read(BinaryReader reader) {
    return BrandHiveModel(
      id: reader.readInt(),
      name: reader.readString(),
      description: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, BrandHiveModel obj) {
    writer.writeInt(obj.id ?? 0);
    writer.writeString(obj.name ?? '');
    writer.writeString(obj.description ?? '');
  }
}
