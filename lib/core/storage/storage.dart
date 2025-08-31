import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Save accessToken, refreshToken, and userId securely
  Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    await _storage.write(key: 'user_id', value: userId);
  }

  /// Check if the user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null && token.isNotEmpty;
  }

  /// Get the access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  /// Get the refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  /// Get the user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  /// Clear all stored data
  Future<void> clear() async {
    await _storage.deleteAll();
  }
}
