import 'package:dio/dio.dart';
import 'package:picoshop_theme2/features/brands/data/brand_api_service.dart';
import 'package:picoshop_theme2/features/brands/data/brand_local_service.dart';
import 'package:picoshop_theme2/features/brands/model/response/brand_list_response.dart';

class BrandRepository {
  final BrandApiService _api;
  final BrandLocalService _local;

  BrandRepository(this._api, this._local);

  Future<List<BrandDataModel>> fetchBrands(int page) async {
    try {
      final brands = await _api.fetchBrands(page);
      for (var b in brands.take(20)) {
        _local.saveBrand(b);
      }
      return brands;
    } on DioException {
      return _local.loadBrands();
    }
  }

  List<BrandDataModel> loadCached() {
    return _local.loadBrands();
  }
}
