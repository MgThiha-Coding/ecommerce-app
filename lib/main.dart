import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/core/router/app_router.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/brands/local/brand_data_hive.dart';
import 'package:picoshop_theme2/features/brands/local/brand_data_hive_adapatar.dart';
import 'package:picoshop_theme2/features/category/local/category_data_hive.dart';
import 'package:picoshop_theme2/features/category/local/category_data_hive_adapatar.dart';
import 'package:picoshop_theme2/features/product/model/local/product_data_hive.dart';
import 'package:picoshop_theme2/features/product/model/local/product_data_hive_adapater.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.dumpErrorToConsole(details);
  };

  try {
    await appInit();
    await AppConfig.loadAccessToken();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    runApp(const ProviderScope(child: MyApp()));
  } catch (e, st) {
    print('Startup error: $e\n$st');
    runApp(const ErrorApp());
  }
}


Future<void> appInit() async {
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {}
  
  await Hive.initFlutter();

  try {
    Hive.registerAdapter(ProductDataHiveAdapter());
  } catch (_) {}
  try {
    Hive.registerAdapter(BrandDataHiveAdapter());
  } catch (_) {}
  try {
    Hive.registerAdapter(CategoryDataHiveAdapter());
  } catch (_) {}

  await _openBoxSafe<ProductHiveModel>('products');
  await _openBoxSafe<BrandHiveModel>('brands');
  await _openBoxSafe<CategoryHiveModel>('category');
}

Future<void> _openBoxSafe<T>(String boxName) async {
  try {
    await Hive.openBox<T>(boxName);
  } catch (e) {
    print('Failed to open box "$boxName": $e');
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,
      routeInformationProvider: router.routeInformationProvider,
      title: 'Pico Shop',
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Something went wrong. Please restart the app.',
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
