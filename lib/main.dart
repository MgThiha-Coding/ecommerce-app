import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/config/app_initializer.dart';
import 'package:picoshop_theme2/core/config/app_localization.dart';
import 'package:picoshop_theme2/features/auth/view/pages/splash_page.dart';
import 'core/services/ota_update_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInitializer.initialize();
  runApp(AppLocalization.setup(child: const ProviderScope(child: MyApp())));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OtaUpdateService.checkForUpdate(context);
    });

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      home: const SplashPage(),
    );
  }
}
