import 'package:dio/dio.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/product/model/response/product_list_response.dart';

class ProductApiService {
  final Dio _dio;
  ProductApiService(this._dio);

  Future<List<ProductDataModel>> fetchProducts(int page) async {
    final response = await _dio.get(
      'https://beta.picosbs.com/api/v1/ecommerce/products?page=$page',
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

    final responseData = ProductListResponse.fromJson(response.data);
    return responseData.data?.data ?? [];
  }
}
