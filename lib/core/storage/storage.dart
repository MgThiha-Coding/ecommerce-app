import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveAuthData({
    required String accessToken,
    required String refreshToken,
    required String userId,
    String? name,
    String? email,
    String? phone,
  }) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
    await _storage.write(key: 'user_id', value: userId);

    if (name != null) await _storage.write(key: 'user_name', value: name);
    if (email != null) await _storage.write(key: 'user_email', value: email);
    if (phone != null) await _storage.write(key: 'user_phone', value: phone);
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null && token.isNotEmpty;
  }

  Future<String?> getAccessToken() async =>
      await _storage.read(key: 'access_token');
  Future<String?> getRefreshToken() async =>
      await _storage.read(key: 'refresh_token');

  Future<String?> getUserId() async => await _storage.read(key: 'user_id');
  Future<String?> getUserName() async => await _storage.read(key: 'user_name');
  Future<String?> getUserEmail() async =>
      await _storage.read(key: 'user_email');
  Future<String?> getUserPhone() async =>
      await _storage.read(key: 'user_phone');

  Future<void> clear() async => await _storage.deleteAll();
}

final isLoggedInProvider = FutureProvider<bool>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  return await storage.isLoggedIn();
});
