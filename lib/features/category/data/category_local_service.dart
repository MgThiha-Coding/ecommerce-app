import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/features/category/model/response/categories_list_response.dart';
import 'package:picoshop_theme2/features/category/model/response/category_data_hive.dart';

class CategoryLocalService {
  final Box<CategoryHiveModel> _box;
  CategoryLocalService(this._box);

  List<CategoryDataModel> loadCategories() {
    return _box.values.map((e) => e.toDataModel()).toList();
  }

  void saveCategory(CategoryDataModel category) {
    if (_box.length >= 20) {
      final oldestKey = _box.keys.first;
      _box.delete(oldestKey);
    }
    _box.put(category.id, CategoryHiveModel.fromDataModel(category));
  }
}
