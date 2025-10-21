import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/cart/model/add_to_cart_request.dart';
import 'package:picoshop_theme2/features/cart/model/add_to_cart_response.dart';
import 'package:picoshop_theme2/features/cart/model/cart_item_response.dart';
import 'package:picoshop_theme2/features/cart/model/total_cart_item_response.dart';

// get cart item notifier state
class CartNotifier extends StateNotifier<AsyncValue<List<CartItemModel>>> {
  final Dio _dio;

  final List<CartItemModel> _onlineItems = [];
  bool _isLoading = false;

  CartNotifier() : _dio = Dio(), super(const AsyncValue.loading());

  Future<void> fetchCart() async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      final response = await _dio.get(
        'https://beta.picosbs.com/api/ecommerce/cart',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${AppConfig.accessToken}',
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

      state = AsyncValue.data(List.from(_onlineItems));
    } on DioException catch (e, st) {
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
}

final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, AsyncValue<List<CartItemModel>>>((ref) {
      return CartNotifier();
    });

// total cart item notifier state or itemcount
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

// add to cart notifier state
class AddToCartState {
  final Map<int, bool> itemLoading;
  final Map<int, String?> itemError;
  final AddToCartResponse? lastResponse;

  AddToCartState({
    required this.itemLoading,
    required this.itemError,
    this.lastResponse,
  });

  AddToCartState copyWith({
    Map<int, bool>? itemLoading,
    Map<int, String?>? itemError,
    AddToCartResponse? lastResponse,
  }) {
    return AddToCartState(
      itemLoading: itemLoading ?? this.itemLoading,
      itemError: itemError ?? this.itemError,
      lastResponse: lastResponse ?? this.lastResponse,
    );
  }
}

class AddToCartNotifier extends StateNotifier<AddToCartState> {
  final Dio _dio;
  final Ref _ref;

  AddToCartNotifier(this._ref, [Dio? dio])
    : _dio = dio ?? Dio(),
      super(AddToCartState(itemLoading: {}, itemError: {}, lastResponse: null));

  Future<void> addToCart(AddToCartRequest params) async {
    final id = params.productId;

    state = state.copyWith(
      itemLoading: {...state.itemLoading, id: true},
      itemError: {...state.itemError}..remove(id),
    );

    try {
      final response = await _dio.post(
        'https://beta.picosbs.com/api/ecommerce/cart',
        data: {
          "product_id": params.productId,
          "purchase_qty": params.purchaseQty,
          "variation_id": params.variationId,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${AppConfig.accessToken}',
            'Content-Type': 'application/json',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );

      final data = response.data;
      if (response.statusCode == 200 && data?['success'] == true) {
        final responseData = AddToCartResponse.fromJson(data);

        state = state.copyWith(
          itemLoading: {...state.itemLoading}..remove(id),
          itemError: {...state.itemError}..remove(id),
          lastResponse: responseData,
        );

        _ref.read(totalCartNotifierProvider.notifier).refreshTotalCart();
        _ref.read(cartNotifierProvider.notifier).refreshCart();
      } else {
        throw Exception(data?['message'] ?? "Failed to add to cart");
      }
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] ??
          (e.type == DioExceptionType.connectionError ||
                  e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.unknown
              ? 'Check your internet connection.'
              : 'Something went wrong. Please try again.');

      state = state.copyWith(
        itemLoading: {...state.itemLoading}..remove(id),
        itemError: {...state.itemError, id: message},
      );
    } catch (e) {
      state = state.copyWith(
        itemLoading: {...state.itemLoading}..remove(id),
        itemError: {...state.itemError, id: e.toString()},
      );
    }
  }
}

final addToCartNotifierProvider =
    StateNotifierProvider<AddToCartNotifier, AddToCartState>(
      (ref) => AddToCartNotifier(ref),
    );

// remove cart notifier state
class CartState {
  final Map<int, bool> itemLoading;
  final Map<int, String?> itemError;

  CartState({required this.itemLoading, required this.itemError});

  CartState copyWith({
    Map<int, bool>? itemLoading,
    Map<int, String?>? itemError,
  }) {
    return CartState(
      itemLoading: itemLoading ?? this.itemLoading,
      itemError: itemError ?? this.itemError,
    );
  }
}

class RemoveCartItemNotifier extends StateNotifier<CartState> {
  final Dio _dio;

  RemoveCartItemNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(CartState(itemLoading: {}, itemError: {}));

  Future<void> removeCartItem(int id) async {
    state = state.copyWith(
      itemLoading: {...state.itemLoading, id: true},
      itemError: {...state.itemError}..remove(id),
    );

    try {
      final response = await _dio.delete(
        'https://beta.picosbs.com/api/ecommerce/cart',
        queryParameters: {'cart_item_id': id},
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

      if (!isSuccess) {
        final msg = response.data['message'] ?? "Failed to remove item";
        throw Exception(msg);
      }

      state = state.copyWith(
        itemLoading: {...state.itemLoading}..remove(id),
        itemError: {...state.itemError}..remove(id),
      );
    } on DioException catch (e, _) {
      final errorData =
          e.response?.data['message'] ??
          "Something went wrong. Please try again.";

      state = state.copyWith(
        itemLoading: {...state.itemLoading}..remove(id),
        itemError: {...state.itemError, id: errorData},
      );
    } catch (e) {
      state = state.copyWith(
        itemLoading: {...state.itemLoading}..remove(id),
        itemError: {...state.itemError, id: e.toString()},
      );
    }
  }
}

final removeCartItemNotifierProvider =
    StateNotifierProvider<RemoveCartItemNotifier, CartState>(
      (ref) => RemoveCartItemNotifier(),
    );
