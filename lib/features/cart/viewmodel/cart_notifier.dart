import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/cart/model/add_to_cart_request.dart';
import 'package:picoshop_theme2/features/cart/model/add_to_cart_response.dart';
import 'package:picoshop_theme2/features/cart/model/cart_item_response.dart';
import 'package:picoshop_theme2/features/cart/model/remove_cart_item_response.dart';
import 'package:picoshop_theme2/features/cart/model/total_cart_item_response.dart';

class CartNotifier extends StateNotifier<AsyncValue<List<CartItemModel>>> {
  final Box<CartItemModel> _localCache;
  final Dio _dio;

  final List<CartItemModel> _onlineItems = [];
  bool _isLoading = false;

  CartNotifier(this._localCache)
    : _dio = Dio(),
      super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    final cached = _localCache.values.toList();
    if (cached.isNotEmpty) {
      state = AsyncValue.data(cached);
    } else {
      await fetchCart();
    }
  }

  Future<void> fetchCart() async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/ecommerce/cart',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );

      final isSuccess =
          response.statusCode == 200 && response.data['success'] == true;

      if (!isSuccess) {
        final message =
            response.data['message'] ??
            "Something went wrong\nPlease try again";
        state = AsyncValue.error(message, StackTrace.current);
        return;
      }

      final parsed = CartItemResponse.fromJson(response.data);
      final items = parsed.data;

      _onlineItems
        ..clear()
        ..addAll(items);

      // overwrite cache
      _localCache.clear();
      for (var item in items) {
        _localCache.put(item.id, item);
      }

      state = AsyncValue.data(List.from(_onlineItems));
    } on DioException catch (e, st) {
      // fallback to cache if error
      final cached = _localCache.values.toList();
      state = AsyncValue.data(cached);

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error('Check Internet', st);
      } else {
        state = AsyncValue.error(e, st);
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refreshCart() async {
    await fetchCart();
  }

  void clearLocalCart() {
    _localCache.clear();
    state = const AsyncValue.data([]);
  }
}

final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, AsyncValue<List<CartItemModel>>>((ref) {
      final offlineCart = Hive.box<CartItemModel>('cart');
      return CartNotifier(offlineCart);
    });

class TotalCartNotifier extends StateNotifier<AsyncValue<int>> {
  final Box<int> _localCache;
  final Dio _dio;

  int? _onlineTotal;
  bool _isLoading = false;

  TotalCartNotifier(this._localCache)
    : _dio = Dio(),
      super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    if (_localCache.isNotEmpty) {
      state = AsyncValue.data(_localCache.get('total') ?? 0);
    } else {
      await fetchTotalCart();
    }
  }

  Future<void> fetchTotalCart() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/ecommerce/cart/total',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );

      final isSuccess =
          response.statusCode == 200 && response.data['success'] == true;

      if (!isSuccess) {
        final message =
            response.data['message'] ??
            "Something went wrong\nPlease try again";
        state = AsyncValue.error(message, StackTrace.current);
        return;
      }

      final parsed = TotalCartItemResponse.fromJson(response.data);
      _onlineTotal = parsed.data;

      // overwrite cache
      _localCache.put('total', _onlineTotal!);

      state = AsyncValue.data(_onlineTotal!);
    } on DioException catch (e, st) {
      // fallback to cache
      final cached = _localCache.get('total');
      if (cached != null) {
        state = AsyncValue.data(cached);
      }

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error('Check Internet', st);
      } else {
        state = AsyncValue.error(e, st);
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> refreshTotalCart() async {
    await fetchTotalCart();
  }

  void clearLocalTotal() {
    _localCache.clear();
    state = const AsyncValue.data(0);
  }
}

final totalCartNotifierProvider =
    StateNotifierProvider<TotalCartNotifier, AsyncValue<int>>((ref) {
      final offlineTotal = Hive.box<int>('total_cart');
      return TotalCartNotifier(offlineTotal);
    });

// ADD TO CART AND REMOVE FROM CART NOTIFIER
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
