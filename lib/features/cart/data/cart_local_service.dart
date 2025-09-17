import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/features/cart/model/response/cart_item_hive_model.dart';


class CartLocalService {
  final Box<CartItemHiveModel> _box;
  CartLocalService(this._box);

  List<CartItemHiveModel> loadCartItems() {
    return _box.values.toList();
  }

  void saveCartItems(List<CartItemHiveModel> items) {
    for (var item in items) {
      _box.put(item.id, item);
    }
  }

  void clearCart() => _box.clear();
}
