import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';
import 'package:picoshop_theme2/features/cart/model/request/add_to_cart_request.dart';
import 'package:picoshop_theme2/features/cart/model/add_to_cart_response.dart';
import 'package:picoshop_theme2/features/cart/model/cart_item_response.dart';
import 'package:picoshop_theme2/features/cart/model/total_cart_item_response.dart';

mixin RefreshTokenMixin {
  final Dio _refreshDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
    ),
  );
  final SecureStorage _storage = SecureStorage();

  Future<Response<dynamic>?> refreshAndRetry(
    Future<Response<dynamic>> Function(String accessToken) retryCallback,
  ) async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) return null;
    try {
      final refreshRes = await _refreshDio.post(
        '${AppConfig.baseUrl}/v1/refresh-token',
        data: {'refresh_token': refreshToken},
        options: Options(headers: {'X-API-Token': AppConfig.xApiToken}),
      );
      final accessToken = refreshRes.data['data']['accessToken'];
      final newRefreshToken = refreshRes.data['data']['refreshToken'];
      final userId = refreshRes.data['data']['user']['id'].toString();
      AppConfig.updateAccessToken(accessToken);
      await _storage.saveAuthData(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
        userId: userId,
      );
      return await retryCallback(accessToken);
    } catch (_) {
      return null;
    }
  }
}

// Get Cart Item State
class CartNotifier extends StateNotifier<AsyncValue<List<CartItemModel>>>
    with RefreshTokenMixin {
  final Dio _dio;
  final List<CartItemModel> _onlineItems = [];
  bool _isLoading = false;

  CartNotifier([Dio? dio])
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 10),
            ),
          ),
      super(const AsyncValue.loading());

  // fetch cart
  Future<void> fetchCart() async {
    if (_isLoading) return;
    _isLoading = true;
    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/ecommerce/cart',
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
      if (e.response?.statusCode == 401) {
        final refreshed = await refreshAndRetry((token) async {
          return await _dio.get(
            '${AppConfig.baseUrl}/ecommerce/cart',
            options: Options(
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
                'X-API-Token': AppConfig.xApiToken,
              },
            ),
          );
        });
        if (refreshed != null) {
          final isSuccess =
              refreshed.statusCode == 200 && refreshed.data['success'] == true;
          if (isSuccess) {
            final parsed = CartItemResponse.fromJson(refreshed.data);
            final items = parsed.data;
            _onlineItems
              ..clear()
              ..addAll(items);
            state = AsyncValue.data(List.from(_onlineItems));
            _isLoading = false;
            return;
          }
        }
      }
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error('Check your connection!', st);
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

//  get total cart item state ( itemcount )
class TotalCartNotifier extends StateNotifier<AsyncValue<int>>
    with RefreshTokenMixin {
  final Dio _dio;
  int? _onlineTotal;
  int? _cachedTotal; // Simple variable instead of Hive box
  bool _isLoading = false;

  TotalCartNotifier()
    : _dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 10),
        ),
      ),
      super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    if (_cachedTotal != null) {
      state = AsyncValue.data(_cachedTotal!);
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
        _isLoading = false;
        return;
      }
      final parsed = TotalCartItemResponse.fromJson(response.data);
      _onlineTotal = parsed.data;
      _cachedTotal = _onlineTotal; // Store in variable instead of Hive
      state = AsyncValue.data(_onlineTotal!);
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 401) {
        final refreshed = await refreshAndRetry((token) async {
          return await _dio.get(
            '${AppConfig.baseUrl}/ecommerce/cart/total',
            options: Options(
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
                'X-API-Token': AppConfig.xApiToken,
              },
            ),
          );
        });
        if (refreshed != null) {
          final isSuccess =
              refreshed.statusCode == 200 && refreshed.data['success'] == true;
          if (isSuccess) {
            final parsed = TotalCartItemResponse.fromJson(refreshed.data);
            _onlineTotal = parsed.data;
            _cachedTotal = _onlineTotal; // Store in variable instead of Hive
            state = AsyncValue.data(_onlineTotal!);
            _isLoading = false;
            return;
          }
        }
      }
      // Use cached variable instead of Hive
      if (_cachedTotal != null) {
        state = AsyncValue.data(_cachedTotal!);
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
    _cachedTotal = null;
    state = const AsyncValue.data(0);
  }
}

final totalCartNotifierProvider =
    StateNotifierProvider<TotalCartNotifier, AsyncValue<int>>((ref) {
      return TotalCartNotifier(); // No more fucking Hive!
    });

// Add to cart state
// Add to cart state
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

class AddToCartNotifier extends StateNotifier<AddToCartState>
    with RefreshTokenMixin {
  final Dio _dio;
  final Ref _ref;

  AddToCartNotifier(this._ref, [Dio? dio])
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 10),
            ),
          ),
      super(AddToCartState(itemLoading: {}, itemError: {}, lastResponse: null));

  Future<void> addToCart(AddToCartRequest params) async {
    final id = params.productId;

    // mark loading
    state = AddToCartState(
      itemLoading: {...state.itemLoading, id: true},
      itemError: {...state.itemError}..remove(id),
      lastResponse: state.lastResponse,
    );

    try {
      final response = await _dio.post(
        '${AppConfig.baseUrl}/ecommerce/cart',
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

        state = AddToCartState(
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
      if (e.response?.statusCode == 401) {
        final refreshed = await refreshAndRetry((token) async {
          return await _dio.post(
            '${AppConfig.baseUrl}/ecommerce/cart',
            data: {
              "product_id": params.productId,
              "purchase_qty": params.purchaseQty,
              "variation_id": params.variationId,
            },
            options: Options(
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
                'X-API-Token': AppConfig.xApiToken,
              },
            ),
          );
        });

        if (refreshed != null && refreshed.data?['success'] == true) {
          final responseData = AddToCartResponse.fromJson(refreshed.data);

          state = AddToCartState(
            itemLoading: {...state.itemLoading}..remove(id),
            itemError: {...state.itemError}..remove(id),
            lastResponse: responseData,
          );

          _ref.read(totalCartNotifierProvider.notifier).refreshTotalCart();
          _ref.read(cartNotifierProvider.notifier).refreshCart();
          return;
        }
      }

      final message =
          e.response?.data?['message'] ??
          (e.type == DioExceptionType.connectionError ||
                  e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.unknown
              ? 'Check your internet connection.'
              : 'Something went wrong. Please try again.');

      state = AddToCartState(
        itemLoading: {...state.itemLoading}..remove(id),
        itemError: {...state.itemError, id: message},
        lastResponse: state.lastResponse,
      );
    } catch (e) {
      state = AddToCartState(
        itemLoading: {...state.itemLoading}..remove(id),
        itemError: {...state.itemError, id: e.toString()},
        lastResponse: state.lastResponse,
      );
    }
  }
}

final addToCartNotifierProvider =
    StateNotifierProvider<AddToCartNotifier, AddToCartState>(
      (ref) => AddToCartNotifier(ref),
    );

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

class RemoveCartItemNotifier extends StateNotifier<CartState>
    with RefreshTokenMixin {
  final Dio _dio;
  final Ref? _ref;

  RemoveCartItemNotifier([Dio? dio, Ref? ref])
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 10),
            ),
          ),
      _ref = ref,
      super(CartState(itemLoading: {}, itemError: {}));

  Future<void> removeCartItem(int id) async {
    state = state.copyWith(
      itemLoading: {...state.itemLoading, id: true},
      itemError: {...state.itemError}..remove(id),
    );
    try {
      final response = await _dio.delete(
        '${AppConfig.baseUrl}/ecommerce/cart',
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
      if (_ref != null) {
        _ref.read(cartNotifierProvider.notifier).refreshCart();
        _ref.read(totalCartNotifierProvider.notifier).refreshTotalCart();
      }
    } on DioException catch (e, _) {
      if (e.response?.statusCode == 401) {
        final refreshed = await refreshAndRetry((token) async {
          return await _dio.delete(
            '${AppConfig.baseUrl}/ecommerce/cart',
            queryParameters: {'cart_item_id': id},
            options: Options(
              headers: {
                'Accept': 'application/json',
                'Authorization': 'Bearer $token',
                'X-API-Token': AppConfig.xApiToken,
              },
            ),
          );
        });
        if (refreshed != null && refreshed.data?['success'] == true) {
          state = state.copyWith(
            itemLoading: {...state.itemLoading}..remove(id),
            itemError: {...state.itemError}..remove(id),
          );
          if (_ref != null) {
            _ref.read(cartNotifierProvider.notifier).refreshCart();
            _ref.read(totalCartNotifierProvider.notifier).refreshTotalCart();
          }
          return;
        }
      }
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
