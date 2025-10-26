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
  SystemChrome.setPreferredOrientations(
    isTablet ? DeviceOrientation.values : [DeviceOrientation.portraitUp],
  );


  await Hive.initFlutter();
  _registerHiveAdapters();
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('my')],
      path: 'assets/translations',
      assetLoader: const CodegenLoader(),
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(child: MyApp()),
    ),
  );
  unawaited(_initializeNonCriticalInBackground());
}

Future<void> _initializeNonCriticalInBackground() async {
  try {
  
    await dotenv.load(fileName: '.env');
    await AppConfig.loadAccessToken();
    await Future.wait([
      _openBoxSafe<ProductHiveModel>('products'),
      _openBoxSafe<BrandHiveModel>('brands'),
      _openBoxSafe<CategoryHiveModel>('category'),
    ]);
  } catch (e) {
    debugPrint('Background init error: $e');
  }
}

void _registerHiveAdapters() {
  Hive.registerAdapter(ProductDataHiveAdapter());
  Hive.registerAdapter(BrandDataHiveAdapter());
  Hive.registerAdapter(CategoryDataHiveAdapter());
}

Future<void> _openBoxSafe<T>(String boxName) async {
  try {
    await Hive.openBox<T>(boxName);
  } catch (e) {
    debugPrint('Box $boxName error: $e');
    try {
      await Hive.deleteBoxFromDisk(boxName);
      await Hive.openBox<T>(boxName);
    } catch (e2) {
      debugPrint('Failed to recover box $boxName: $e2');
    }
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,

      // CRITICAL: White background to prevent black flash
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: Colors.white,
      ),

      home: const SplashPage(),
    );
  }
}
