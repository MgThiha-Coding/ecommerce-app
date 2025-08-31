
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';

// version 1
/*
class AppConfig {
  static String get baseUrl => dotenv.env['API_BASE_URL']!;
  static String get xApiToken => dotenv.env['X_API_TOKEN']!;
  static String get accessToken =>
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiMjc0OWYxMWE0YTRmYTc5ZWVmMTcwMDcwNjdkZTgyYzNlZDExNmU5NTMzNjM1YjFiODJjZDkyYWFiZTg5YjdjNmI1N2YzMjcwM2Y0MTQ3ODUiLCJpYXQiOjE3NTY1OTQ0NTIuMjU0MzkzLCJuYmYiOjE3NTY1OTQ0NTIuMjU0Mzk3LCJleHAiOjE3NzI0OTIwNTIuMjUwMzIyLCJzdWIiOiIyMyIsInNjb3BlcyI6W119.C0wqV-7x6zCedhokib9rjx_kq9_TWxysa45z0r3x04zwYLAMmjd5pueHvYixXLmElzvQxlXMAp5aSiWJuJO1wy1FpbFN36JosZzY9VbAHSFGwzv2SYUw4r0aLn4TK2S3KnB1G-YgbxqN5D8tQu9lvisq4EGP-vizTToOb6d0WpAt_cqCi7ITBA2B7WPLZx0zCmF6jKOArqm86JI2iPdvvXrobox79Agvhj3II63loc87J91mXNVmWG-gRnakQcpfVZJK_RWRhKxqbafovro2O2ooSRIg4KAnSRyKn-j9ijtfea5060Op8wgcAps5dGz0A949O9dclqzsKxZDPxVTPiCX2HkR0BofB_DbzZKluz2on7HfMddYv1QbScKSBVEZSEyxFWv8vHuhalWxzZg8FbserjulLNpsC13BR7GkXW_IQX0B1ot358N0mT5RDmb2YOwrGOPZ8eVbnF7s2c91BFIwvpupM-_9D6C363lByAqSfwtqxLtJgPQk4Ci8hCXsV-E87BPkMXnJJ6O8epzFSMy5QpIMpbJ7gKwCm2H4qveikE2rlfVUJ4UjK7tXQkt0S7Q1VD61Dx65__GHls5JX_8fXJm0KL7bT1zCAv1GxsMjEy6Rx5nacuv964D30U0nEYSTkwuSSZJYNyXUZbQ1fZpfSD-LqD0SdVQsLzPUf3U';
}

*/
//version2

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
