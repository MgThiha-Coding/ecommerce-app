import 'package:picoshop_theme2/features/brands/model/response/brand_list_response.dart';

class BrandHiveModel {
  final int? id;
  final String? name;
  final String? description;

  BrandHiveModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory BrandHiveModel.fromDataModel(BrandDataModel data) {
    return BrandHiveModel(
      id: data.id,
      name: data.name,
      description: data.description,
    );
  }

  BrandDataModel toDataModel() {
    return BrandDataModel(
      id: id ?? 0,
      name: name ?? '',
      description: description,
      createdBy: 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      deletedBy: null,
      updatedBy: null,
      deletedAt: null,
    );
  }
}
