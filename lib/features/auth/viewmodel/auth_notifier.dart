import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/auth/model/request/login_request.dart';
import 'package:picoshop_theme2/features/auth/model/request/register_request.dart';
import 'package:picoshop_theme2/features/auth/model/request/verify_code_request.dart';
import 'package:picoshop_theme2/features/auth/model/response/log_out_response.dart';
import 'package:picoshop_theme2/features/auth/model/response/login_response.dart';
import 'package:picoshop_theme2/features/auth/model/response/register_response.dart';
import 'package:picoshop_theme2/features/auth/model/response/verify_code_response.dart';

class LoginNotifier extends StateNotifier<AsyncValue<LoginResponse?>> {
  final Dio _dio;
  LoginNotifier([Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));

  Future<void> login(LoginRequest params) async {
    state = AsyncValue.loading();

    try {
      final response = await _dio.post(
        'https://beta.picosbs.com/api/v1/central/login',
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
    state = AsyncValue.loading();
    try {
      final response = await _dio.post(
        'https://beta.picosbs.com/api/v1/logout',
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



class RegisterNotifier extends StateNotifier<AsyncValue<RegisterResponse?>> {
  RegisterNotifier() : super(const AsyncValue.data(null));

  Future<void> register(RegisterRequest params) async {
    state = AsyncValue.loading();
    final dio = Dio();

    try {
      final response = await dio.post(
        'https://beta.picosbs.com/api/v1/register',
        data: params.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'X-API-Token': AppConfig.xApiToken,
          },
          validateStatus: (status) => status != null,
        ),
      );

      if (response.statusCode != null &&
          response.statusCode! >= 200 &&
          response.statusCode! < 300 &&
          response.data['success'] == true) {
        final registerResponse = RegisterResponse.fromJson(response.data);

        state = AsyncValue.data(registerResponse);
    
      } else {
        state = AsyncValue.error(response.data, StackTrace.current);
      }
    } on DioException catch (e) {
      final errorData =
          e.response?.data['message'];
      state = AsyncValue.error(errorData, StackTrace.current);
    }
  }
}

final registerNotifierProvider =
    StateNotifierProvider<RegisterNotifier, AsyncValue<RegisterResponse?>>(
      (ref) => RegisterNotifier(),
    );



class VerifyCodeNotifier extends StateNotifier<AsyncValue<VerifyCodeResponse?>> {
  final Dio _dio;

  VerifyCodeNotifier([Dio? dio])
      : _dio = dio ?? Dio(),
        super(const AsyncValue.data(null));

  // Get device name
  Future<String?> getDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
      return '${webBrowserInfo.browserName}${webBrowserInfo.platform}${webBrowserInfo.product}${webBrowserInfo.productSub}${webBrowserInfo.vendor}';
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor;
    }
    return null;
  }

  // Verify code
  Future<void> verifyCode(VerifyCodeRequest params) async {
    state = const AsyncValue.loading();

    try {
      final response = await _dio.post(
        'https://beta.picosbs.com/api/v1/verify',
        data: params.toJson(),
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${AppConfig.accessToken}',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );

      final isSuccess = response.data != null &&
          response.data['success'] == true &&
          response.statusCode == 200;

      if (isSuccess) {
        final verifyResponse = VerifyCodeResponse.fromJson(response.data);
        state = AsyncValue.data(verifyResponse);
      } else {
        final msg = response.data['message'] ?? 'Something went wrong';
        state = AsyncValue.error(msg, StackTrace.current);
      }
    } on DioException catch (e, st) {
      final errorData = e.response?.data['message'] ??
          (e.type == DioExceptionType.connectionError ||
                  e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.unknown
              ? 'Check Internet'
              : "Something went wrong, Please try again later");
      state = AsyncValue.error(errorData, st);
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  // Resend verification code
  Future<void> resentVerifyCode(String emailOrPhone) async {
    state = const AsyncValue.loading();

    try {
      final response = await _dio.post(
        'https://beta.picosbs.com/api/v1/resend-verification',
        data: {"email_or_phone": emailOrPhone},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer ${AppConfig.accessToken}',
            'X-API-Token': AppConfig.xApiToken,
          },
        ),
      );

      final isSuccess = response.data != null &&
          response.data['success'] == true &&
          response.statusCode == 200;

      if (isSuccess) {
        final verifyResponse = VerifyCodeResponse.fromJson(response.data);
        state = AsyncValue.data(verifyResponse);
      } else {
        final msg = response.data['message'] ?? 'Something went wrong';
        state = AsyncValue.error(msg, StackTrace.current);
      }
    } on DioException catch (e, st) {
      final errorData = e.response?.data['message'] ??
          (e.type == DioExceptionType.connectionError ||
                  e.type == DioExceptionType.connectionTimeout ||
                  e.type == DioExceptionType.unknown
              ? 'Check Internet'
              : "Something went wrong, Please try again later");
      state = AsyncValue.error(errorData, st);
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }
}

// Provider
final verifyCodeNotifierProvider =
    StateNotifierProvider<VerifyCodeNotifier, AsyncValue<VerifyCodeResponse?>>(
        (ref) => VerifyCodeNotifier());
