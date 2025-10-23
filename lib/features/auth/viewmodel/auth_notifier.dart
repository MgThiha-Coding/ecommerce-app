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

// Refersh Token
abstract class BaseAuthNotifier<T> extends StateNotifier<AsyncValue<T?>> {
  final Dio _dio;
  final SecureStorage _storage;

  BaseAuthNotifier(this._storage, [Dio? dio])
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
              sendTimeout: const Duration(seconds: 10),
            ),
          ),
      super(const AsyncValue.data(null));

  Future<T?> request(Map<String, dynamic> data);

  Future<void> call(Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      // first request
      final response = await request(data);
      if (response != null) {
        state = AsyncValue.data(response);
      } else {
        state = AsyncValue.error('Request failed', StackTrace.current);
      }
    } on DioException catch (e, st) {
      // if status code 401 : access token invalid , refersh token by adding stored access token in authdata
      if (e.response?.statusCode == 401) {
        // refresh token
        final refreshed = await _refreshAndRetry(data);
        if (refreshed != null) {
          // and emit result to state
          state = AsyncValue.data(refreshed);
          return;
        }
      }

      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.unknown) {
        // dio exception error
        state = AsyncValue.error('Check internet connection', st);
      } else {
        // error message from api response
        state = AsyncValue.error(
          e.response?.data?['message'] ?? 'Unexpected error',
          st,
        );
      }
    }
  }

  // refresh token
  Future<T?> _refreshAndRetry(Map<String, dynamic> data) async {
    // get saved refersh token from secureStorage
    final refreshToken = await _storage.getRefreshToken();
    // if token is null , stop here
    if (refreshToken == null) return null;

    try {
      // refresh token and receive new token
      final refreshRes = await _dio.post(
        '${AppConfig.baseUrl}/v1/refresh-token',
        options: Options(headers: {'X-API-Token': AppConfig.xApiToken}),
        data: {"refresh_token": refreshToken},
      );

      // received new tokens and data
      final accessToken = refreshRes.data['data']['accessToken'];
      final newRefreshToken = refreshRes.data['data']['refreshToken'];
      final userId = refreshRes.data['data']['user']['id'].toString();

      // and update the securestorage
      AppConfig.updateAccessToken(accessToken);
      await _storage.saveAuthData(
        accessToken: accessToken,
        refreshToken: newRefreshToken,
        userId: userId,
      );

      // return value
      return await request(data);
    } catch (_) {
      return null;
    }
  }
}

// Login State
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
      '${AppConfig.baseUrl}/v1/central/login',
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

// Register State
class RegisterNotifier extends BaseAuthNotifier<RegisterResponse> {
  RegisterNotifier(SecureStorage storage, [Dio? dio]) : super(storage, dio);

  Future<void> register(RegisterRequest params) async {
    await call(params.toJson());
  }

  @override
  Future<RegisterResponse?> request(Map<String, dynamic> data) async {
    final response = await _dio.post(
      '${AppConfig.baseUrl}/api/v1/register',
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

// Verify Code State
class VerifyCodeNotifier extends BaseAuthNotifier<VerifyCodeResponse> {
  VerifyCodeNotifier(SecureStorage storage, [Dio? dio]) : super(storage, dio);

  Future<void> verifyCode(VerifyCodeRequest params) async {
    await call(params.toJson());
  }

  @override
  Future<VerifyCodeResponse?> request(Map<String, dynamic> data) async {
    final response = await _dio.post(
      '${AppConfig.baseUrl}/api/v1/verify',
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

  // Resent Verify Code
  Future<void> resentVerifyCode(String emailOrPhone) async {
    await call({"email_or_phone": emailOrPhone});
  }
}

final verifyCodeNotifierProvider =
    StateNotifierProvider<VerifyCodeNotifier, AsyncValue<VerifyCodeResponse?>>(
      (ref) => VerifyCodeNotifier(ref.read(secureStorageProvider)),
    );

// Logout State
class LogOutNotifier extends BaseAuthNotifier<LogOutResponse> {
  LogOutNotifier(SecureStorage storage, [Dio? dio]) : super(storage, dio);

  Future<void> logOut() async {
    await call({});
  }

  @override
  Future<LogOutResponse?> request(Map<String, dynamic> data) async {
    final response = await _dio.post(
      '${AppConfig.baseUrl}/api/v1/logout',
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

// Get Device Name
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
