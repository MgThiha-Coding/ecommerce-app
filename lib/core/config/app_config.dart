import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';

class AppConfig {
  static String _accessToken = '';

  static String get accessToken => _accessToken;

  static String get baseUrl => 'https://beta.picosbs.com/api/v1';
  static String get xApiToken => dotenv.env['X_API_TOKEN']!;

  static Future<void> loadAccessToken() async {
    final secureStorage = SecureStorage();
    _accessToken = (await secureStorage.getAccessToken()) ?? '';
  }

  static void updateAccessToken(String token) {
    _accessToken = token;
  }

  static void clearAccessToken() {
    _accessToken = '';
  }
}
