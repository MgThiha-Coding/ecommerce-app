import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'hive_config.dart';
import 'app_localization.dart';

class AppInitializer {
  static Future<void> initialize() async {
    // Phase 1: Critical synchronous initializations
    await _initializeCritical();

    // Phase 2: Non-critical async initializations
    unawaited(_initializeNonCritical());
  }

  static Future<void> _initializeCritical() async {
    // 1. Localization
    await AppLocalization.ensureInitialized();

    // 2. Device orientation
    await _setDeviceOrientation();

    // 3. Hive setup
    await HiveConfig.init();
    await HiveConfig.openCriticalBoxes();

    // 4. Environment and critical config
    await dotenv.load(fileName: '.env');
    await AppConfig.loadAccessToken();
  }

  static Future<void> _initializeNonCritical() async {
    // Open non-critical Hive boxes in background
    await HiveConfig.openNonCriticalBoxes();

    // Other non-critical initializations can go here
    // await Analytics.init();
    // await PushNotification.init();
  }

  static Future<void> _setDeviceOrientation() async {
    // Get device size
    final window = WidgetsBinding.instance.window;
    final screenWidth = window.physicalSize.width / window.devicePixelRatio;

    if (screenWidth >= 600) {
      // Tablet: allow both portrait and landscape
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      // Mobile: portrait only
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
    }
  }
}
