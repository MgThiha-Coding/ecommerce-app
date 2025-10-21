import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';
import 'package:picoshop_theme2/features/auth/model/request/login_request.dart';
import 'package:picoshop_theme2/features/auth/model/request/register_request.dart';
import 'package:picoshop_theme2/features/auth/model/request/verify_code_request.dart';
import 'package:picoshop_theme2/features/auth/model/response/login_response.dart';
import 'package:picoshop_theme2/features/auth/model/response/register_response.dart';
import 'package:picoshop_theme2/features/auth/model/response/verify_code_response.dart';
import 'package:picoshop_theme2/features/auth/model/response/log_out_response.dart';

abstract class BaseAuthNotifier<T> extends StateNotifier<AsyncValue<T?>> {
  final Dio _dio;
  final SecureStorage _storage;

  BaseAuthNotifier(this._storage, [Dio? dio])
    : _dio = dio ?? Dio(),
      super(const AsyncValue.data(null));

  Future<T?> request(Map<String, dynamic> data);

  Future<void> call(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final response = await request(data);
      if (response != null) {
        state = AsyncValue.data(response);
      } else {
        state = AsyncValue.error('Request failed', StackTrace.current);
      }
    } on DioException catch (e, st) {
      if (e.response?.statusCode == 401) {
        final refreshed = await _refreshAndRetry(data);
        if (refreshed != null) {
          state = AsyncValue.data(refreshed);
          return;
        }
      }

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.unknown) {
        state = AsyncValue.error('Check internet connection', st);
      } else {
        state = AsyncValue.error(
          e.response?.data?['message'] ?? 'Unexpected error',
          st,
        );
      }
    }
  }

  Future<T?> _refreshAndRetry(Map<String, dynamic> data) async {
    final refreshToken = await _storage.getRefreshToken();
    if (refreshToken == null) return null;

    try {
      final refreshRes = await _dio.post(
        '${AppConfig.baseUrl}/v1/refresh-token',
        options: Options(headers: {'X-API-Token': AppConfig.xApiToken}),
        data: {"refresh_token": refreshToken},
      );

      final accessToken = refreshRes.data['data']['accessToken'];
      final newRefreshToken = refreshRes.data['data']['refreshToken'];
      final userId = refreshRes.data['data']['user']['id'].toString();

      // Save new tokens
      AppConfig.updateAccessToken(accessToken);
      await _storage.saveAuthData(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
        userId: userId,
      );

      return await request(data);
    } catch (_) {
      return null;
    }
  }
}

/// LOGIN
class LoginNotifier extends BaseAuthNotifier<LoginResponse> {
  LoginNotifier(SecureStorage storage, [Dio? dio]) : super(storage, dio);

  Future<void> login(LoginRequest params) async {
    await call({
      "email_or_phone_or_username": params.emailOrPhoneOrUserName,
      "password": params.password,
      "remember_me": false,
      "device_name": params.deviceName,
    });
  }

  @override
  Future<LoginResponse?> request(Map<String, dynamic> data) async {
    final response = await _dio.post(
      'https://beta.picosbs.com/api/v1/central/login',
      data: data,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-API-Token': AppConfig.xApiToken,
        },
        receiveDataWhenStatusError: true,
      ),
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return LoginResponse.fromJson(response.data);
    }
    return null;
  }
}

final loginNotifierProvider =
    StateNotifierProvider<LoginNotifier, AsyncValue<LoginResponse?>>(
      (ref) => LoginNotifier(ref.read(secureStorageProvider)),
    );

// REGISTER
class RegisterNotifier extends BaseAuthNotifier<RegisterResponse> {
  RegisterNotifier(SecureStorage storage, [Dio? dio]) : super(storage, dio);

  Future<void> register(RegisterRequest params) async {
    await call(params.toJson());
  }

  @override
  Future<RegisterResponse?> request(Map<String, dynamic> data) async {
    final response = await _dio.post(
      'https://beta.picosbs.com/api/v1/register',
      data: data,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'X-API-Token': AppConfig.xApiToken,
        },
        receiveDataWhenStatusError: true,
      ),
    );

    if (response.statusCode == 201 && response.data['success'] == true) {
      return RegisterResponse.fromJson(response.data);
    }
    return null;
  }
}

final registerNotifierProvider =
    StateNotifierProvider<RegisterNotifier, AsyncValue<RegisterResponse?>>(
      (ref) => RegisterNotifier(ref.read(secureStorageProvider)),
    );

// VERIFY CODE
class VerifyCodeNotifier extends BaseAuthNotifier<VerifyCodeResponse> {
  VerifyCodeNotifier(SecureStorage storage, [Dio? dio]) : super(storage, dio);

  Future<void> verifyCode(VerifyCodeRequest params) async {
    await call(params.toJson());
  }

  @override
  Future<VerifyCodeResponse?> request(Map<String, dynamic> data) async {
    final response = await _dio.post(
      'https://beta.picosbs.com/api/v1/verify',
      data: data,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.accessToken}',
          'X-API-Token': AppConfig.xApiToken,
        },
        receiveDataWhenStatusError: true,
      ),
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return VerifyCodeResponse.fromJson(response.data);
    }
    return null;
  }

  Future<void> resentVerifyCode(String emailOrPhone) async {
    await call({"email_or_phone": emailOrPhone});
  }
}

final verifyCodeNotifierProvider =
    StateNotifierProvider<VerifyCodeNotifier, AsyncValue<VerifyCodeResponse?>>(
      (ref) => VerifyCodeNotifier(ref.read(secureStorageProvider)),
    );

class LogOutNotifier extends BaseAuthNotifier<LogOutResponse> {
  LogOutNotifier(SecureStorage storage, [Dio? dio]) : super(storage, dio);

  Future<void> logOut() async {
    await call({}); // Keep method name unchanged
  }

  @override
  Future<LogOutResponse?> request(Map<String, dynamic> data) async {
    final response = await _dio.post(
      'https://beta.picosbs.com/api/v1/logout',
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AppConfig.accessToken}',
          'X-API-Token': AppConfig.xApiToken,
        },
        receiveDataWhenStatusError: true,
      ),
    );

    if (response.statusCode == 200 && response.data['success'] == true) {
      return LogOutResponse.fromJson(response.data);
    }
    return null;
  }
}

final logOutNotifierProvider =
    StateNotifierProvider<LogOutNotifier, AsyncValue<LogOutResponse?>>(
      (ref) => LogOutNotifier(ref.read(secureStorageProvider)),
    );

// GET DEVICE NAME
Future<String?> getDeviceName() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  if (kIsWeb) {
    final info = await deviceInfo.webBrowserInfo;
    return '${info.browserName}${info.platform}${info.vendor}';
  } else if (Platform.isAndroid) {
    final info = await deviceInfo.androidInfo;
    return info.id;
  } else if (Platform.isIOS) {
    final info = await deviceInfo.iosInfo;
    return info.identifierForVendor;
  }
  return null;
}
