import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/core/network/refresh_token_mixin.dart';
import 'package:picoshop_theme2/features/create_address/model/create_address_request.dart';
import 'package:picoshop_theme2/features/create_address/model/create_addresss_response.dart';

class CreateAddressNotifier
    extends StateNotifier<AsyncValue<CreateAddressResponse?>>
    with RefreshTokenMixin {
  final Dio _dio;
  bool _isLoading = false;

  CreateAddressNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));

  Future<void> createAddress(CreateAddressRequest params) async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final response = await _dio.post(
        '${AppConfig.baseUrl}/ecommerce/addresses',
        data: params.toJson(),
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AppConfig.accessToken}',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );

      _handleResponse(response);
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 401) {
        final refreshed = await refreshAndRetry((token) async {
          return await _dio.post(
            '${AppConfig.baseUrl}/ecommerce/addresses',
            data: params.toJson(),
            options: Options(
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
                'X-API-Token': AppConfig.xApiToken,
              },
            ),
          );
        });

        if (refreshed != null) {
          _handleResponse(refreshed);
          _isLoading = false;
          return;
        }
      }

      final errorData =
          e.response?.data['message'] ??
          (e.type == DioExceptionType.connectionError ||
                  e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.unknown
              ? 'Check Internet'
              : 'Something went wrong, please try again later');
      state = AsyncValue.error(errorData, st);
    } finally {
      _isLoading = false;
    }
  }

  void _handleResponse(Response response) {
    final isSuccess =
        response.statusCode == 200 && response.data['success'] == true;

    if (isSuccess) {
      final responseData = CreateAddressResponse.fromJson(response.data);
      state = AsyncValue.data(responseData);
    } else {
      final msg = response.data['message'] ?? 'Failed to create address';
      state = AsyncValue.error(msg, StackTrace.current);
    }
  }

  Future<void> refresh(CreateAddressRequest params) async {
    await createAddress(params);
  }
}

final createAddressNotifierProvider =
    StateNotifierProvider<
      CreateAddressNotifier,
      AsyncValue<CreateAddressResponse?>
    >((ref) => CreateAddressNotifier());
