import 'package:dio/dio.dart';
import 'package:picoshop_theme2/features/product/data/product_api_service.dart';
import 'package:picoshop_theme2/features/product/data/product_local_service.dart';
import 'package:picoshop_theme2/features/product/model/response/product_list_response.dart';

class ProductRepository {
  final ProductApiService _api;
  final ProductLocalService _local;

  ProductRepository(this._api, this._local);

  Future<List<ProductDataModel>> fetchProducts(int page) async {
    try {
      final products = await _api.fetchProducts(page);
      for (var p in products.take(20)) {
        _local.saveProduct(p);
      }
      return products;
    } on DioException {
      return _local.loadProducts();
    }
  }

  List<ProductDataModel> loadCached() {
    return _local.loadProducts();
  }
}
