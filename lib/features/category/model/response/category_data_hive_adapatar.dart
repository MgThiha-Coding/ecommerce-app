import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/features/category/model/response/category_data_hive.dart';

class CategoryDataHiveAdapter extends TypeAdapter<CategoryHiveModel> {
  @override
  final typeId = 2;

  @override
  CategoryHiveModel read(BinaryReader reader) {
    return CategoryHiveModel(
      id: reader.readInt(),
      name: reader.readString(),
      description: reader.readString(),
    );
  }

  @override
  void write(BinaryWriter writer, CategoryHiveModel obj) {
    writer.writeInt(obj.id ?? 0);
    writer.writeString(obj.name ?? '');
    writer.writeString(obj.description ?? '');
  }
}
