import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';

class AppConfig {
  static String _accessToken = '';

  static String tempToken =
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiJ9.eyJhdWQiOiIxIiwianRpIjoiZjI2ZTYzMzZjZDE4YTZiOGE5NzY3YzBiZGE0MjhmYWFjYzE1Y2VlMjA5ZTRjODIyYmY2MWRiNzUwOTAwMDU2MjYyZTQwMmM4MDE5MjI2NWUiLCJpYXQiOjE3NTg0NzY2OTguMjI1NTQzLCJuYmYiOjE3NTg0NzY2OTguMjI1NTUsImV4cCI6MTc3NDExNTA5OC4yMjEyNjMsInN1YiI6IjkiLCJzY29wZXMiOltdfQ.jIJ2ROVvJf9dk-heEtC1vPwngpwDZ6HMGKpdnRGM0ZeHG8slBpj09D8WJ4-Rpmeu49xuMz28g8xJ3Ji1XeEx1eynaDVompV7jl1d2DVRYzPEvyTdCe-EZKrUSTwwZgqgpCQFikAPuP5XmbRGOFBPV83mgP6pI0gey_SoiEA8CyFV17kZnlfF2IZ9Cg_LcpDWSH3OCfdv_eXIvEYiZKJIvWvDpVbIkygXhUTzK4V0-B_GstlhN407Yl3o3hmwMafLlwO-4cnbNu2oOB74E-3Wi9E9GzCPBZAmJy8qz7_wbE_6iMZ-Ubc78j-NV5OnneeVeVbck1EvQTVR0I2Co6ld9Jwwc9aDMaP0aLKR-UYLWO7lQ-Z7_LiyKADCfuvuEjIjra3WcXOfYpQgUMt3Cb3-ORLv51aHnyH_CQyyHmib4oW19y7uQQ3sKPv9JKUG_m7oW3bEXYSEWZlk2nahSghJt1lkk_sdkEXAVC1TpZBgo-ay7Q45vW-Fxk0rUdm6BgK2RLttGitLSkrlk1MW_dh9mEz_7kgUj57V0kPdz93w8FGgaJH3TK0MMyTsZo9ysKtzp8zWNpUPhcG8hhtPbYbYCqTQE18OoNJxMDcJBhj5u5c5Fnuewnl-Axbhg5W9BptCmAQag7gygjCWZvop497UA9EOcogBFarqLv_iKvWlHA4';

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
