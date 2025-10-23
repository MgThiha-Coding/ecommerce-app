import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  final bool isTablet =
      // ignore: deprecated_member_use
      WidgetsBinding.instance.window.physicalSize.shortestSide > 600;
  await SystemChrome.setPreferredOrientations(
    isTablet
        ? DeviceOrientation.values
        : [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

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
      fallbackLocale: const Locale('my'),
      saveLocale: true,
      startLocale: const Locale('en'),
      child: const ProviderScope(child: MyApp()),
    ),
  );

  _initializeApp();
}

Future<void> _initializeApp() async {
  try {
    await Future.wait([dotenv.load(fileName: '.env'), Hive.initFlutter()]);

    _registerHiveAdapters();

    await Future.wait([_openBoxSafe<CartItemHiveModel>('cart')]);

    await AppConfig.loadAccessToken();

    unawaited(
      Future.wait([
        _openBoxSafe<ProductHiveModel>('products'),
        _openBoxSafe<BrandHiveModel>('brands'),
        _openBoxSafe<CategoryHiveModel>('category'),
      ]),
    );
  } catch (e, st) {
    debugPrint('Startup error: $e\n$st');
  }
}

void _registerHiveAdapters() {
  Hive.registerAdapter(ProductDataHiveAdapter());
  Hive.registerAdapter(BrandDataHiveAdapter());
  Hive.registerAdapter(CategoryDataHiveAdapter());
  Hive.registerAdapter(CartItemHiveAdapter());
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
