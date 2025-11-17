import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'app_localization.dart';

class AppInitializer {
  /// Fast critical initialization needed for first frame
  static Future<void> initializeCriticalFast() async {
    // Ensure localization is ready
    await AppLocalization.ensureInitialized();

    // Set device orientation quickly
    await _setDeviceOrientation();

    // Load critical config / env
    await dotenv.load(fileName: '.env');
    await AppConfig.loadAccessToken();
  }

  /// Optional delayed non-critical initialization
  static Future<void> initializeNonCriticalDelayed() async {
    // Can run other heavy tasks here if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() async {
        // Add any non-critical setup here
        // e.g., prefetch data, analytics initialization
      });
    });
  }

  /// Device orientation logic
  static Future<void> _setDeviceOrientation() async {
    // ignore: deprecated_member_use
    final window = WidgetsBinding.instance.window;
    final screenWidth = window.physicalSize.width / window.devicePixelRatio;

    if (screenWidth >= 600) {
      // Tablet: allow portrait & landscape
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

  /// Optional helper to run truly heavy tasks off main isolate
  static Future<void> runHeavyTaskInBackground(Future<void> Function() task) async {
    await compute(_runTaskWrapper, task);
  }

  static Future<void> _runTaskWrapper(Future<void> Function() task) async {
    await task();
  }
}
