import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/create_address/model/request/create_address_request.dart';
import 'package:picoshop_theme2/features/create_address/model/response/create_addresss_response.dart';

class CreateAddressNotifier
    extends StateNotifier<AsyncValue<CreateAddressResponse?>> {
  final Dio _dio;

  CreateAddressNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));

  Future<void> createAddress(CreateAddressRequest params) async {
    try {
      final response = await _dio.post(
        '${AppConfig.baseUrl}/v1/ecommerce/addresses',
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

      final isSuccess =
          response.data != null &&
          response.data['success'] == true &&
          response.statusCode == 200;

      if (isSuccess) {
        final responseData = CreateAddressResponse.fromJson(response.data);

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

final createAddressNotifierProvider =
    StateNotifierProvider<
      CreateAddressNotifier,
      AsyncValue<CreateAddressResponse?>
    >((ref) => CreateAddressNotifier());
