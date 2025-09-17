import 'package:picoshop_theme2/features/cart/data/cart_api_service.dart';
import 'package:picoshop_theme2/features/cart/data/cart_local_service.dart';
import 'package:picoshop_theme2/features/cart/model/response/cart_item_hive_model.dart';

class CartRepository {
  final CartApiService _api;
  final CartLocalService _local;

  CartRepository(this._api, this._local);

  Future<List<CartItemHiveModel>> fetchCartItems() async {
    try {
      final response = await _api.fetchCartItems();
      final items = response?.data.map((e) => CartItemHiveModel.fromCartItem(e)).toList() ?? [];
      _local.saveCartItems(items);
      return items;
    } catch (_) {
      return _local.loadCartItems();
    }
  }

  List<CartItemHiveModel> loadCached() => _local.loadCartItems();
}
