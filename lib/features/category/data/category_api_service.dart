import 'package:dio/dio.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/category/model/response/categories_list_response.dart';

class CategoryApiService {
  final Dio _dio;
  CategoryApiService(this._dio);

  Future<List<CategoryDataModel>> fetchCategories(int page) async {
    final response = await _dio.get(
      'https://beta.picosbs.com/api/v1/ecommerce/categories?page=$page',
      options: Options(
        headers: {
          'Accept': 'application/json',
          'X-API-Token': AppConfig.xApiToken,
        },
      ),
    );

    final isSuccess =
        response.statusCode == 200 && response.data?['success'] == true;
    if (!isSuccess) return [];

    final responseData = CategoriesListResponse.fromJson(response.data);
    return responseData.data.data;
  }
}
