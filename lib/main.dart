import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/core/localization/codegen_loader.g.dart';
import 'package:picoshop_theme2/features/auth/view/pages/splash_page.dart';
import 'package:picoshop_theme2/features/brands/local/brand_data_hive.dart';
import 'package:picoshop_theme2/features/brands/local/brand_data_hive_adapatar.dart';
import 'package:picoshop_theme2/features/cart/local/cart_item_hive_adapater.dart';
import 'package:picoshop_theme2/features/cart/local/cart_item_hive_model.dart';
import 'package:picoshop_theme2/features/category/local/category_data_hive.dart';
import 'package:picoshop_theme2/features/category/local/category_data_hive_adapatar.dart';
import 'package:picoshop_theme2/features/product/local/product_data_hive.dart';
import 'package:picoshop_theme2/features/product/local/product_data_hive_adapater.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  FlutterError.onError = (details) => FlutterError.dumpErrorToConsole(details);
  final bool isTablet =
      // ignore: deprecated_member_use
      WidgetsBinding.instance.window.physicalSize.shortestSide > 600;
  await SystemChrome.setPreferredOrientations(
    isTablet
        ? DeviceOrientation.values
        : [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );
  await _initializeApp();
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
        Locale('fr'),
        Locale('ar'),
        Locale('ja'),
        Locale('de'),
        Locale('nl'),
        Locale('th'),
        Locale('my'),
        Locale('zh'),
      ],
      path: 'assets/translations',
      assetLoader: const CodegenLoader(),
      fallbackLocale: const Locale('en'),
      saveLocale: true,
      startLocale: const Locale('my'),
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

Future<void> _initializeApp() async {
  try {
    await Future.wait([dotenv.load(fileName: '.env'), Hive.initFlutter()]);

    // Register Hive adapters
    _registerHiveAdapters();

    // Open Hive boxes in parallel
    await Future.wait([
      _openBoxSafe<ProductHiveModel>('products'),
      _openBoxSafe<BrandHiveModel>('brands'),
      _openBoxSafe<CategoryHiveModel>('category'),
      _openBoxSafe<CartItemHiveModel>('cart'),
    ]);

    await AppConfig.loadAccessToken();
  } catch (e, st) {
    debugPrint('Startup error: $e\n$st');
  }
}

void _registerHiveAdapters() {
  try {
    Hive.registerAdapter(ProductDataHiveAdapter());
  } catch (_) {}
  try {
    Hive.registerAdapter(BrandDataHiveAdapter());
  } catch (_) {}
  try {
    Hive.registerAdapter(CategoryDataHiveAdapter());
  } catch (_) {}
  try {
    Hive.registerAdapter(CartItemHiveAdapter());
  } catch (_) {}
}

Future<void> _openBoxSafe<T>(String boxName) async {
  try {
    await Hive.openBox<T>(boxName);
  } catch (e) {
    debugPrint('Failed to open box "$boxName": $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      home: const SplashPage(),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Something went wrong. Please restart the app.',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
