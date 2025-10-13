import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';

class AppConfig {
  static String _accessToken = '';

  // Public getters
  static String get accessToken => _accessToken;
  static String get baseUrl => dotenv.env['API_BASE_URL']!;
  static String get xApiToken => dotenv.env['X_API_TOKEN']!;

  // Load access token from secure storage
  static Future<void> loadAccessToken() async {
    final secureStorage = SecureStorage();
    _accessToken = (await secureStorage.getAccessToken()) ?? '';
  }

  // Update access token
  static void updateAccessToken(String token) {
    _accessToken = token;
  }
}
