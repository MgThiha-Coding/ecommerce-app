

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:picoshop_theme2/core/localization/codegen_loader.g.dart';

class AppLocalization {
  static const supportedLocales = [
    Locale('en'),
    Locale('de'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('nl'),
    Locale('th'),
    Locale('my'),
    Locale('zh'),
  ];

  static Widget setup({
    required Widget child,
    Locale? startLocale = const Locale('en'),
    Locale? fallbackLocale = const Locale('my'),
  }) {
    return EasyLocalization(
      supportedLocales: supportedLocales,
      path: 'assets/translations',
      assetLoader: const CodegenLoader(),
      startLocale: startLocale,
      fallbackLocale: fallbackLocale,
      child: child,
    );
  }

  static Future<void> ensureInitialized() async {
    await EasyLocalization.ensureInitialized();
  }
}
