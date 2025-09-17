import 'package:dio/dio.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/cart/model/response/cart_item_response.dart';

class CartApiService {
  final Dio _dio;
  CartApiService(this._dio);

  Future<CartItemResponse?> fetchCartItems() async {
    final response = await _dio.get(
      'https://beta.picosbs.com/api/v1/ecommerce/cart',
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${AppConfig.accessToken}',
          'X-API-Token': AppConfig.xApiToken,
        },
      ),
    );

    final isSuccess =
        response.statusCode != null &&
        response.statusCode! >= 200 &&
        response.statusCode! < 300 &&
        (response.data['success'] == true || response.data['success'] == "true");

    if (isSuccess) {
      return CartItemResponse.fromJson(response.data);
    } else {
      final msg = response.data['message'] ?? "Something went wrong";
      throw Exception(msg);
    }
  }
}
