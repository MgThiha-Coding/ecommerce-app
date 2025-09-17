import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/features/cart/model/response/total_cart_item_model.dart';


class TotalCartLocalService {
  final Box<TotalCartItemHiveModel> _box;
  TotalCartLocalService(this._box);

  TotalCartItemHiveModel? loadTotalCart() {
    return _box.get('total') ;
  }

  void saveTotalCart(TotalCartItemHiveModel total) {
    _box.put('total', total);
  }

  void clearTotalCart() => _box.delete('total');
}
