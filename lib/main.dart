import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/core/router/app_router.dart';
import 'package:toastification/toastification.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/brands/local/brand_data_hive.dart';
import 'package:picoshop_theme2/features/brands/local/brand_data_hive_adapatar.dart';
import 'package:picoshop_theme2/features/category/local/category_data_hive.dart';
import 'package:picoshop_theme2/features/category/local/category_data_hive_adapatar.dart';
import 'package:picoshop_theme2/features/product/model/local/product_data_hive.dart';
import 'package:picoshop_theme2/features/product/model/local/product_data_hive_adapater.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appInit();
  await AppConfig.loadAccessToken();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(const ProviderScope(child: ToastificationWrapper(child: MyApp())));
  });
}

Future<void> appInit() async {
  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  Hive.registerAdapter(ProductDataHiveAdapter());
  Hive.registerAdapter(BrandDataHiveAdapter());
  Hive.registerAdapter(CategoryDataHiveAdapter());
  await Hive.openBox<ProductHiveModel>('products');
  await Hive.openBox<BrandHiveModel>('brands');
  await Hive.openBox<CategoryHiveModel>('category');
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
