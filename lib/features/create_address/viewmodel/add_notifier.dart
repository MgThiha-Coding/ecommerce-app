import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/create_address/model/response/address_response.dart';

class AddressNotifier extends StateNotifier<AsyncValue<AddressResponse>> {
  final Dio _dio;

  AddressNotifier([Dio? dio])
      : _dio = dio ?? Dio(),
        super(const AsyncValue.loading());

  Future<void> getAddresses() async {
    try {
      final response = await _dio.get(
        'https://beta.picosbs.com/api/ecommerce/addresses',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${AppConfig.accessToken}',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final addressResponse = AddressResponse.fromJson(response.data);
        state = AsyncValue.data(addressResponse);
      } else {
        state = AsyncValue.error(
          response.data['message'] ?? 'Failed to fetch addresses',
          StackTrace.current,
        );
      }
    } on DioException catch (e, st) {
      final error = e.response?.data?['message'] ??
          (e.type == DioExceptionType.connectionError ||
                  e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.unknown
              ? 'Check Internet'
              : 'Something went wrong');
      state = AsyncValue.error(error, st);
    }
  }
}

final addressNotifierProvider =
    StateNotifierProvider<AddressNotifier, AsyncValue<AddressResponse>>(
  (ref) => AddressNotifier(),
);
