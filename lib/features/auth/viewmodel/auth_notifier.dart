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

// login API requests and state

class LoginNotifier extends StateNotifier<AsyncValue<LoginResponse?>> {
  final Dio _dio;

  LoginNotifier([Dio? dio])
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 5),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'X-API-Token': AppConfig.xApiToken,
              },
              receiveDataWhenStatusError: true,
            ),
          ),
      super(const AsyncValue.data(null));

  Future<void> login(LoginRequest params) async {
    state = const AsyncValue.loading();

    try {
      final response = await _dio.post(
        'https://beta.picosbs.com/api/v1/central/login',
       // '${AppConfig.baseUrl}v1/central/login',
        data: {
          "email_or_phone_or_username": params.emailOrPhoneOrUserName,
          "password": params.password,
          "remember_me": false,
          "device_name": params.deviceName,
        },
      );

      final isSuccess =
          response.data != null &&
          response.statusCode == 200 &&
          response.data['success'] == true;

      if (isSuccess) {
        state = AsyncValue.data(LoginResponse.fromJson(response.data));
      } else {
        state = AsyncValue.error(
          response.data?['message'] ?? 'Login failed',
          StackTrace.current,
        );
      }
    } on DioException catch (e, st) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error(
          'Request timed out. Please check internet.',
          st,
        );
      } else {
        final errorData = e.response?.data?['message'] ?? 'Unexpected error';
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
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 5),
              receiveDataWhenStatusError: true,
            ),
          ),
      super(const AsyncValue.data(null));

  Future<void> logOut() async {
    state = const AsyncValue.loading();

    try {
      final response = await _dio.post(
        'https://beta.picosbs.com/api/v1/logout',
       // '${AppConfig.baseUrl}v1/logout',
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
        print('Logout Response ${response.data}');
        state = AsyncValue.data(LogOutResponse.fromJson(response.data));
      } else {
        state = AsyncValue.error(
          response.data?['message'] ?? 'Logout failed',
          StackTrace.current,
        );
      }
    } on DioException catch (e, st) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error(
          'Request timed out. Please check internet.',
          st,
        );
      } else {
        final errorData = e.response?.data?['message'] ?? 'Unexpected error';
        state = AsyncValue.error(errorData, st);
      }
    }
  }
}

final logOutNotifierProvider =
    StateNotifierProvider<LogOutNotifier, AsyncValue<LogOutResponse?>>(
      (ref) => LogOutNotifier(),
    );

// registration API requests and state
class RegisterNotifier extends StateNotifier<AsyncValue<RegisterResponse?>> {
  final Dio _dio;

  RegisterNotifier([Dio? dio])
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 5),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'X-API-Token': AppConfig.xApiToken,
              },
              receiveDataWhenStatusError: true,
            ),
          ),
      super(const AsyncValue.data(null));

  Future<void> register(RegisterRequest params) async {
    state = const AsyncValue.loading();

    try {
      final response = await _dio.post(
        '${AppConfig.baseUrl}v1/register',
        data: params.toJson(),
      );

      final isSuccess =
          response.data != null &&
          response.statusCode == 201 &&
          response.data['success'] == true;

      if (isSuccess) {
        state = AsyncValue.data(RegisterResponse.fromJson(response.data));
      } else {
        state = AsyncValue.error(
          response.data?['message'] ?? 'Registration failed',
          StackTrace.current,
        );
      }
    } on DioException catch (e, st) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error(
          'Request timed out. Please check internet.',
          st,
        );
      } else {
        final errorData = e.response?.data?['message'] ?? 'Unexpected error';
        state = AsyncValue.error(errorData, st);
      }
    }
  }
}

final registerNotifierProvider =
    StateNotifierProvider<RegisterNotifier, AsyncValue<RegisterResponse?>>(
      (ref) => RegisterNotifier(),
    );

// verification code API requests and state
class VerifyCodeNotifier
    extends StateNotifier<AsyncValue<VerifyCodeResponse?>> {
  final Dio _dio;

  VerifyCodeNotifier([Dio? dio])
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 5),
              headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': 'Bearer ${AppConfig.accessToken}',
                'X-API-Token': AppConfig.xApiToken,
              },
              receiveDataWhenStatusError: true,
            ),
          ),
      super(const AsyncValue.data(null));

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

  Future<void> verifyCode(VerifyCodeRequest params) async {
    state = const AsyncValue.loading();

    try {
      final response = await _dio.post(
        '${AppConfig.baseUrl}v1/verify',
        data: params.toJson(),
      );

      final isSuccess =
          response.data != null &&
          response.data['success'] == true &&
          response.statusCode == 200;

      if (isSuccess) {
        state = AsyncValue.data(VerifyCodeResponse.fromJson(response.data));
      } else {
        state = AsyncValue.error(
          response.data['message'] ?? 'Something went wrong',
          StackTrace.current,
        );
      }
    } on DioException catch (e, st) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error(
          'Request timed out. Please check internet.',
          st,
        );
      } else {
        final errorData = e.response?.data?['message'] ?? 'Unexpected error';
        state = AsyncValue.error(errorData, st);
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }

  Future<void> resentVerifyCode(String emailOrPhone) async {
    state = const AsyncValue.loading();

    try {
      final response = await _dio.post(
        '${AppConfig.baseUrl}/v1/resend-verification',
        data: {"email_or_phone": emailOrPhone},
      );

      final isSuccess =
          response.data != null &&
          response.data['success'] == true &&
          response.statusCode == 200;

      if (isSuccess) {
        state = AsyncValue.data(VerifyCodeResponse.fromJson(response.data));
      } else {
        state = AsyncValue.error(
          response.data['message'] ?? 'Something went wrong',
          StackTrace.current,
        );
      }
    } on DioException catch (e, st) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error(
          'Request timed out. Please check internet.',
          st,
        );
      } else {
        final errorData = e.response?.data?['message'] ?? 'Unexpected error';
        state = AsyncValue.error(errorData, st);
      }
    } catch (e, st) {
      state = AsyncValue.error(e.toString(), st);
    }
  }
}

final verifyCodeNotifierProvider =
    StateNotifierProvider<VerifyCodeNotifier, AsyncValue<VerifyCodeResponse?>>(
      (ref) => VerifyCodeNotifier(),
    );

// test notifier
class BaseUrlNotifier extends StateNotifier<AsyncValue<String?>> {
  final Dio _dio;

  BaseUrlNotifier([Dio? dio])
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 5),
              receiveDataWhenStatusError: true,
            ),
          ),
      super(const AsyncValue.data(null));

  Future<void> handshake() async {
    state = const AsyncValue.loading();
    try {
      final response = await _dio.get(AppConfig.baseUrl);
      print('response baseUrl ${response.data}');

      final url = response.requestOptions.uri.toString();

      if (response.statusCode == 200) {
        state = AsyncValue.data(url);
      } else {
        state = AsyncValue.error(
          'Handshake failed: ${response.statusCode}',
          StackTrace.current,
        );
      }
    } on DioException catch (e, st) {
      state = AsyncValue.error(
        e.message ?? 'Unexpected error during handshake',
        st,
      );
    }
  }
}

final baseUrlNotifierProvider =
    StateNotifierProvider<BaseUrlNotifier, AsyncValue<String?>>(
      (ref) => BaseUrlNotifier(),
    );
