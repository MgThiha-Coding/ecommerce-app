import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/cart/model/request/add_to_cart_request.dart';
import 'package:picoshop_theme2/features/cart/model/response/add_to_cart_response.dart';
import 'package:picoshop_theme2/features/cart/model/response/cart_item_response.dart';
import 'package:picoshop_theme2/features/cart/model/response/remove_cart_item_response.dart';
import 'package:picoshop_theme2/features/cart/model/response/total_cart_item_response.dart';

// Add to Cart notifier
class AddToCartNotifier extends StateNotifier<AsyncValue<AddToCartResponse?>> {
  final Dio _dio;

  AddToCartNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));

  Future<void> addtoCart(AddToCartRequest params) async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.post(
        'https://beta.picosbs.com/api/v1/ecommerce/cart',
        data: {
          "product_id": params.productId,
          "purchase_qty": params.purchaseQty,
          "variation_id": params.variationId,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AppConfig.accessToken}',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );
      final isSuccess =
          response.data != null &&
          response.data['success'] == true &&
          response.statusCode == 200;

      if (isSuccess) {
        print('cart issue check ${response.data}');
        final responseData = AddToCartResponse.fromJson(response.data);

        state = AsyncValue.data(responseData);
      } else {
        final msg = response.data['message'];
        state = AsyncValue.error(msg, StackTrace.current);
      }
    } on DioException catch (e, st) {
      final errorData =
          (e.response?.data['message'] ??
          (e.type == DioExceptionType.connectionError ||
                  e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.unknown
              ? 'Check Internet'
              : "Something went wrong, Please try again later"));
      state = AsyncValue.error(errorData, st);
    }
  }
}

final addToCartNotifierProvider =
    StateNotifierProvider<AddToCartNotifier, AsyncValue<AddToCartResponse?>>(
      (ref) => AddToCartNotifier(),
    );

// Get Cart Item Notifier
class GetCartItemNotifier extends StateNotifier<AsyncValue<CartItemResponse?>> {
  final Dio _dio;
  GetCartItemNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));

  Future<void> getCartItem() async {
    state = AsyncValue.loading();
    try {
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
          (response.data['success'] == true ||
              response.data['success'] == "true");
      if (isSuccess) {
        final responseData = CartItemResponse.fromJson(response.data);
        state = AsyncValue.data(responseData);
      } else {
        final msg = response.data['message'];
        state = AsyncValue.error(msg, StackTrace.current);
      }
    } on DioException catch (e, st) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error('Check Internet', st);
      } else {
        final errorData =
            e.response?.data['message'] ??
            "Something went wrong,Please try again later";
        state = AsyncValue.error(errorData, st);
      }
    }
  }
}

final getCartItemNotifierProvider =
    StateNotifierProvider<GetCartItemNotifier, AsyncValue<CartItemResponse?>>(
      (ref) => GetCartItemNotifier(),
    );

// Get Total Cart Item Notifier
class GetTotalCartItemNotifier
    extends StateNotifier<AsyncValue<TotalCartItemResponse?>> {
  final Dio _dio;
  GetTotalCartItemNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));

  Future<void> getTotalCartItem() async {
    state = AsyncValue.loading();
    try {
      final response = await _dio.get(
        'https://beta.picosbs.com/api/v1/ecommerce/cart/total-items',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${AppConfig.accessToken}',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );
      final isSuccess =
          response.data != null &&
          response.data['success'] == true &&
          response.statusCode == 200;
      if (isSuccess) {
        final responseData = TotalCartItemResponse.fromJson(response.data);
        state = AsyncValue.data(responseData);
      } else {
        final msg = response.data['message'];
        state = AsyncValue.error(msg, StackTrace.current);
      }
    } on DioException catch (e, st) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error('Check Internet', st);
      } else {
        final errorData =
            e.response?.data['message'] ??
            "Something went wrong,Please try again later";
        state = AsyncValue.error(errorData, st);
      }
    }
  }
}

final getTotalCartItemNotifierProvider =
    StateNotifierProvider<
      GetTotalCartItemNotifier,
      AsyncValue<TotalCartItemResponse?>
    >((ref) => GetTotalCartItemNotifier());

// Revmoe Cart from Product Notifier
class RemoveCartItemNotifier
    extends StateNotifier<AsyncValue<RemoveCartItemResponse?>> {
  final Dio _dio;
  RemoveCartItemNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));

  Future<void> removeCartItem(int id) async {
    state = AsyncValue.loading();
    try {
      final response = await _dio.delete(
        'https://beta.picosbs.com/api/v1/ecommerce/cart?cart_item_id=$id',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${AppConfig.accessToken}',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );
      final isSuccess =
          response.data != null &&
          response.data['success'] == true &&
          response.statusCode == 200;
      if (isSuccess) {
        final responseData = RemoveCartItemResponse.fromJson(response.data);
        state = AsyncValue.data(responseData);
      } else {
        final msg = response.data['message'];
        state = AsyncValue.error(msg, StackTrace.current);
      }
    } on DioException catch (e, st) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error('Check Internet', st);
      } else {
        final errorData =
            e.response?.data['message'] ??
            "Something went wrong,Please try again later";
        state = AsyncValue.error(errorData, st);
      }
    }
  }
}

final removeCartItemNotifierProvider =
    StateNotifierProvider<
      RemoveCartItemNotifier,
      AsyncValue<RemoveCartItemResponse?>
    >((ref) => RemoveCartItemNotifier());
