import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';

class AppConfig {
  static String _accessToken = '';

  // Make baseUrl a private variable so it can be updated
  static String _baseUrl = 'https://beta.picosbs.com/api/v1';

  // Public getters
  static String get accessToken => _accessToken;
  static String get baseUrl => _baseUrl;
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

  // Clear access token
  static void clearAccessToken() {
    _accessToken = '';
  }

  // NEW: Update base URL dynamically
  static void updateBaseUrl(String newUrl) {
    _baseUrl = newUrl;
  }
}
