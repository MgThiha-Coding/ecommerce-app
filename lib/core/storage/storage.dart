import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Auth Data
  Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    await _storage.write(key: 'user_id', value: userId);
  }

  // User Info
  Future<void> saveUserInfo({
    required String name,
    required String email,
    required String phone,
  }) async {
    await _storage.write(key: 'user_name', value: name);
    await _storage.write(key: 'user_email', value: email);
    await _storage.write(key: 'user_phone', value: phone);
  }

  Future<Map<String, String?>> getUserInfo() async {
    final name = await _storage.read(key: 'user_name');
    final email = await _storage.read(key: 'user_email');
    final phone = await _storage.read(key: 'user_phone');
    return {'name': name, 'email': email, 'phone': phone};
  }

 
  Future<void> clear() async => await _storage.deleteAll();

  
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null && token.isNotEmpty;
  }

  Future<String?> getAccessToken() async =>
      await _storage.read(key: 'access_token');

  Future<String?> getRefreshToken() async =>
      await _storage.read(key: 'refresh_token');

  Future<String?> getUserId() async => await _storage.read(key: 'user_id');

  
  Future<void> setFirstLaunchFlag(bool isFirstLaunch) async {
    await _storage.write(
        key: 'first_launch', value: isFirstLaunch ? 'true' : 'false');
  }

  Future<bool?> getFirstLaunchFlag() async {
    final value = await _storage.read(key: 'first_launch');
    if (value == null) return null; 
    return value == 'true';
  }
}
