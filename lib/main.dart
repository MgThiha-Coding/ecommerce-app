import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/features/auth/view/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appInit();
  runApp(const ProviderScope(child: MyApp()));
}

Future<void> appInit() async {
  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  await Hive.openBox('appCache');
  await AppConfig.loadAccessToken();
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
