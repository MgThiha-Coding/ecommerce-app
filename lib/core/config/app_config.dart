import 'package:picoshop_theme2/core/storage/storage.dart';

class AppConfig {
  static String _accessToken = '';
  static String get accessToken => _accessToken;
  static String get baseUrl => 'https://beta.picosbs.com/api';
  //dotenv.env['API_BASE_URL']!;
  static String get xApiToken =>
      'a53b832172f332ab71d0c8fc55fae7c4c21e9203bb662af9622f071699a397a5';
  //dotenv.env['X_API_TOKEN']!;
  static Future<void> loadAccessToken() async {
    final secureStorage = SecureStorage();
    _accessToken = (await secureStorage.getAccessToken()) ?? '';
  }

  static void updateAccessToken(String token) {
    _accessToken = token;
  }
}
