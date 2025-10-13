import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 15), 
    receiveTimeout: const Duration(seconds: 20),
    headers: {
      'Authorization': 'Bearer ${AppConfig.accessToken}',
      'X-API-Token': AppConfig.xApiToken,
    },
  ));
});
