import 'package:picoshop_theme2/features/cart/data/total_cart_api_service.dart';
import 'package:picoshop_theme2/features/cart/data/total_cart_local_service.dart';
import 'package:picoshop_theme2/features/cart/model/response/total_cart_item_model.dart';

class TotalCartRepository {
  final TotalCartApiService _api;
  final TotalCartLocalService _local;

  TotalCartRepository(this._api, this._local);

  Future<TotalCartItemHiveModel> fetchTotalCart() async {
    try {
      final response = await _api.fetchTotalCartItems();
      final hiveModel = TotalCartItemHiveModel.fromResponse(response);
      _local.saveTotalCart(hiveModel);
      return hiveModel;
    } catch (_) {
      final cached = _local.loadTotalCart();
      if (cached != null) return cached;
      rethrow;
    }
  }

  TotalCartItemHiveModel? loadCached() => _local.loadTotalCart();
}
