
import 'total_cart_item_response.dart';

class TotalCartItemHiveModel {
  final int totalItems;

  TotalCartItemHiveModel({required this.totalItems});

  factory TotalCartItemHiveModel.fromResponse(TotalCartItemResponse response) {
    return TotalCartItemHiveModel(totalItems: response.data);
  }

  TotalCartItemResponse toResponse() {
    return TotalCartItemResponse(
      success: true,
      message: '',
      data: totalItems,
    );
  }
}
