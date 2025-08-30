import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/auth/model/request/login_request.dart';
import 'package:picoshop_theme2/features/auth/model/response/log_out_response.dart';
import 'package:picoshop_theme2/features/auth/model/response/login_response.dart';

class LoginNotifier extends StateNotifier<AsyncValue<LoginResponse?>> {
  final Dio _dio;
  LoginNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));

  Future<void> login(LoginRequest params) async {
    state = AsyncValue.loading();

    try {
      final response = await _dio.post(
        '${AppConfig.baseUrl}/v1/central/login',
        data: {
          "email_or_phone_or_username": params.emailOrPhoneOrUserName,
          "password": params.password,
          "remember_me": params.rememberMe,
          "device_name": params.deviceName,
        },
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );
      final isSuccess =
          response.data != null &&
          response.statusCode == 200 &&
          response.data['success'] == true;
      if (isSuccess) {
        final responseData = LoginResponse.fromJson(response.data);
        state = AsyncValue.data(responseData);
      }
    } on DioException catch (e, st) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error('Check Internet', StackTrace.current);
      } else {
        final errorData = e.response?.data['message'];
        state = AsyncValue.error(errorData, st);
      }
    }
  }
}

final loginNotifierProvider =
    StateNotifierProvider<LoginNotifier, AsyncValue<LoginResponse?>>(
      (ref) => LoginNotifier(),
    );

class LogOutNotifier extends StateNotifier<AsyncValue<LogOutResponse?>> {
  final Dio _dio;
  LogOutNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));

  Future<void> logOut() async {
    try {
      final response = await _dio.post(
        'https://beta.picosbs.com/api/v1/logout',
        options: Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${AppConfig.accessToken}',
            'Content-Type': 'application/json',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );
      final isSuccess =
          response.data != null &&
          response.statusCode == 200 &&
          response.data['success'] == true;
      if (isSuccess) {
        final responseData = LogOutResponse.fromJson(response.data);
        state = AsyncValue.data(responseData);
      }
    } on DioException catch (e, st) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error('Check Internet', st);
      } else {
        final errorData = e.response?.data['message'];
        state = AsyncValue.error(errorData, st);
      }
    }
  }
}

final logOutNotifierProvider =
    StateNotifierProvider<LogOutNotifier, AsyncValue<LogOutResponse?>>(
      (ref) => LogOutNotifier(),
    );
