import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/features/brands/model/response/brand_data_hive.dart';
import 'package:picoshop_theme2/features/brands/model/response/brand_list_response.dart';

class BrandLocalService {
  final Box<BrandHiveModel> _box;
  BrandLocalService(this._box);

  List<BrandDataModel> loadBrands() {
    return _box.values.map((e) => e.toDataModel()).toList();
  }

  void saveBrand(BrandDataModel brand) {
    if (_box.length >= 20) {
      final oldestKey = _box.keys.first;
      _box.delete(oldestKey);
    }
    _box.put(brand.id, BrandHiveModel.fromDataModel(brand));
  }
}
