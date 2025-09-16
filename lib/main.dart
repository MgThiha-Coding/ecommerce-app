import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:picoshop_theme2/features/auth/view/pages/splash_page.dart';
import 'package:picoshop_theme2/features/brands/model/response/brand_data_hive.dart';
import 'package:picoshop_theme2/features/brands/model/response/brand_data_hive_adapatar.dart';
import 'package:picoshop_theme2/features/category/model/response/category_data_hive.dart';
import 'package:picoshop_theme2/features/category/model/response/category_data_hive_adapatar.dart';
import 'package:picoshop_theme2/features/product/model/response/product_data_hive.dart';
import 'package:picoshop_theme2/features/product/model/response/product_data_hive_adapater.dart';
import 'package:toastification/toastification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appInit();
  runApp(ProviderScope(child: ToastificationWrapper(child: MyApp())));
}

Future<void> appInit() async {
  await dotenv.load(fileName: '.env');

  // Initialize Hive
  await Hive.initFlutter();

  // Product Hive
  Hive.registerAdapter(ProductDataHiveAdapter());
  await Hive.openBox<ProductHiveModel>('products');

  // Brand Hive
  Hive.registerAdapter(BrandDataHiveAdapter());
  await Hive.openBox<BrandHiveModel>('brands');

  // Category Hive
  Hive.registerAdapter(CategoryDataHiveAdapter());
  await Hive.openBox<CategoryHiveModel>('category');
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pico Pharmacy',
      home: SplashPage(),
    );
  }
}
