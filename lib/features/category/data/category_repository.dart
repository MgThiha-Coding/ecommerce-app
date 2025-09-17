import 'package:dio/dio.dart';
import 'package:picoshop_theme2/features/category/data/category_api_service.dart';
import 'package:picoshop_theme2/features/category/data/category_local_service.dart';
import 'package:picoshop_theme2/features/category/model/response/categories_list_response.dart';

class CategoryRepository {
  final CategoryApiService _api;
  final CategoryLocalService _local;

  CategoryRepository(this._api, this._local);

  Future<List<CategoryDataModel>> fetchCategories(int page) async {
    try {
      final categories = await _api.fetchCategories(page);
      for (var c in categories.take(20)) {
        _local.saveCategory(c);
      }
      return categories;
    } on DioException {
      return _local.loadCategories();
    }
  }

  List<CategoryDataModel> loadCached() {
    return _local.loadCategories();
  }
}
