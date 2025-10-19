import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import '../model/response/create_addresss_response.dart';

class AddressNotifier extends StateNotifier<AsyncValue<List<AddressData>>> {
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
        final List<dynamic> data = response.data['data'];
        final addresses = data.map((e) => AddressData.fromJson(e)).toList();
        state = AsyncValue.data(addresses);
      } else {
        state = AsyncValue.error(
          response.data['message'] ?? 'Failed to fetch addresses',
          StackTrace.current,
        );
      }
    } on DioException catch (e, st) {
      final error = e.response?.data['message'] ??
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
    StateNotifierProvider<AddressNotifier, AsyncValue<List<AddressData>>>(
        (ref) => AddressNotifier());
