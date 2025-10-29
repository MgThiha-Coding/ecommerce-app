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
import 'package:picoshop_theme2/features/business_setting/local/business_setting_hive_adapter.dart';
import 'package:picoshop_theme2/features/business_setting/local/business_setting_hive_model.dart';
import 'package:picoshop_theme2/features/category/local/category_data_hive.dart';
import 'package:picoshop_theme2/features/category/local/category_data_hive_adapatar.dart';
import 'package:picoshop_theme2/features/product/local/product_data_hive.dart';
import 'package:picoshop_theme2/features/product/local/product_data_hive_adapater.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  final bool isTablet =
      WidgetsBinding.instance.window.physicalSize.shortestSide > 600;
  SystemChrome.setPreferredOrientations(
    isTablet ? DeviceOrientation.values : [DeviceOrientation.portraitUp],
  );

  await Hive.initFlutter();
  _registerHiveAdapters();
  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('de'),
        Locale('es'),
        Locale('fr'),
        Locale('ja'),
        Locale('nl'),
        Locale('th'),
        Locale('my'),
        Locale('zh'),
      ],
      path: 'assets/translations',
      assetLoader: const CodegenLoader(),
      startLocale: const Locale('en'),
      fallbackLocale: const Locale('my'),
      child: const ProviderScope(child: MyApp()),
    ),
  );

  unawaited(_initializeNonCriticalInBackground());
}

void _registerHiveAdapters() {
  Hive.registerAdapter(ProductDataHiveAdapter());
  Hive.registerAdapter(BrandDataHiveAdapter());
  Hive.registerAdapter(CategoryDataHiveAdapter());
  Hive.registerAdapter(BusinessSettingHiveAdapter());
}

Future<void> _initializeNonCriticalInBackground() async {
  try {
    await dotenv.load(fileName: '.env');
    await AppConfig.loadAccessToken();
    await _openBoxSafe<BusinessSettingHiveModel>('business_settings');
    unawaited(_openBoxSafe<ProductHiveModel>('products'));
    unawaited(_openBoxSafe<BrandHiveModel>('brands'));
    unawaited(_openBoxSafe<CategoryHiveModel>('category'));
  } catch (e) {
    debugPrint('Background init error: $e');
  }
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
      home: const SplashPage(),
    );
  }
}
