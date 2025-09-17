import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/cart/model/request/add_to_cart_request.dart';
import 'package:picoshop_theme2/features/cart/model/response/add_to_cart_response.dart';
import 'package:picoshop_theme2/features/cart/model/response/remove_cart_item_response.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/features/cart/data/cart_api_service.dart';
import 'package:picoshop_theme2/features/cart/data/cart_local_service.dart';
import 'package:picoshop_theme2/features/cart/data/cart_repository.dart';
import 'package:picoshop_theme2/features/cart/data/total_cart_api_service.dart';
import 'package:picoshop_theme2/features/cart/data/total_cart_local_service.dart';
import 'package:picoshop_theme2/features/cart/data/total_cart_repository.dart';
import 'package:picoshop_theme2/features/cart/model/response/cart_item_hive_model.dart';
import 'package:picoshop_theme2/features/cart/model/response/total_cart_item_model.dart';

class CartNotifier extends StateNotifier<AsyncValue<List<CartItemHiveModel>>> {
  final CartRepository _repo;

  CartNotifier(this._repo) : super(const AsyncValue.loading()) {
    final cached = _repo.loadCached();
    if (cached.isNotEmpty) {
      state = AsyncValue.data(cached);
    }
    fetchCart();
  }

  Future<void> fetchCart() async {
    state = AsyncValue.loading();
    try {
      final items = await _repo.fetchCartItems();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refreshCart() async {
    await fetchCart();
  }
}

final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, AsyncValue<List<CartItemHiveModel>>>((
      ref,
    ) {
      final dio = Dio();
      final api = CartApiService(dio);
      final local = CartLocalService(Hive.box<CartItemHiveModel>('cart'));
      final repo = CartRepository(api, local);
      return CartNotifier(repo);
    });

class TotalCartNotifier
    extends StateNotifier<AsyncValue<TotalCartItemHiveModel?>> {
  final TotalCartRepository _repo;

  TotalCartNotifier(this._repo) : super(const AsyncValue.data(null)) {
    final cached = _repo.loadCached();
    if (cached != null) state = AsyncValue.data(cached);
    fetchTotalCart();
  }

  Future<void> fetchTotalCart() async {
    state = const AsyncValue.loading();
    try {
      final total = await _repo.fetchTotalCart();
      state = AsyncValue.data(total);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refreshTotalCart() async {
    await fetchTotalCart();
  }
}

final totalCartNotifierProvider =
    StateNotifierProvider<
      TotalCartNotifier,
      AsyncValue<TotalCartItemHiveModel?>
    >((ref) {
      final dio = Dio();
      final api = TotalCartApiService(dio);
      final local = TotalCartLocalService(
        Hive.box<TotalCartItemHiveModel>('total_cart'),
      );
      final repo = TotalCartRepository(api, local);
      return TotalCartNotifier(repo);
    });

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
