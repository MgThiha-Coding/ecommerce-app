import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';
import 'package:picoshop_theme2/core/storage/user_model.dart';
import 'package:picoshop_theme2/core/storage/user_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final storage = ref.read(secureStorageProvider);

      final userInfo = await storage.getUserInfo();
      final userId = await storage.getUserId();

      if (userInfo['name'] != null &&
          userInfo['email'] != null &&
          userId != null) {
        ref.read(userProvider.notifier).state = UserModel(
          id: userId,
          name: userInfo['name'] ?? '',
          email: userInfo['email'] ?? '',
          phone: userInfo['phone'] ?? '',
        );
      }

      final isLoggedIn = await storage.isLoggedIn();

      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;
      if (isLoggedIn) {
        context.go('/home');
      } else {
        context.go('/loginOrRegister');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFC107), Color(0xFFFFE082), Color(0xFFA5D6A7)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AppImage.appLogo, scale: 14),
                  Text(
                    'Welcome to Pico Shop',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Text(
                'All you need is right here',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
