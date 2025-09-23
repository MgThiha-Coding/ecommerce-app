import 'package:picoshop_theme2/features/category/model/categories_list_response.dart';

class CategoryHiveModel {
  final int? id;
  final String? name;
  final String? description;

  CategoryHiveModel({
    required this.id,
    required this.name,
    required this.description,
  });

  factory CategoryHiveModel.fromDataModel(CategoryDataModel data) {
    return CategoryHiveModel(
      id: data.id,
      name: data.name,
      description: data.description?.toString(),
    );
  }

  CategoryDataModel toDataModel() {
    return CategoryDataModel(
      id: id ?? 0,
      name: name ?? '',
      shortCode: null,
      parentId: 0,
      description: description,
      createdBy: 0,
      updatedBy: 0,
      deletedAt: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      parentCategory: null,
      childCategory: [],
    );
  }
}
