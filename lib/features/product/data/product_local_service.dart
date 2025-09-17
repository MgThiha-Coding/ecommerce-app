import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/features/product/model/response/product_data_hive.dart';
import 'package:picoshop_theme2/features/product/model/response/product_list_response.dart';

class ProductLocalService {
  final Box<ProductHiveModel> _box;
  ProductLocalService(this._box);

  List<ProductDataModel> loadProducts() {
    return _box.values.map((e) => e.toDataModel()).toList();
  }

  void saveProduct(ProductDataModel product) {
    if (_box.length >= 20) {
      final oldestKey = _box.keys.first;
      _box.delete(oldestKey);
    }
    _box.put(product.id, ProductHiveModel.fromDataModel(product));
  }
}
