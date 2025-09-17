import 'package:dio/dio.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/brands/model/response/brand_list_response.dart';

class BrandApiService {
  final Dio _dio;
  BrandApiService(this._dio);

  Future<List<BrandDataModel>> fetchBrands(int page) async {
    final response = await _dio.get(
      'https://beta.picosbs.com/api/v1/ecommerce/brands?page=$page',
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

    final responseData = BrandListResponse.fromJson(response.data);
    return responseData.data.data;
  }
}
