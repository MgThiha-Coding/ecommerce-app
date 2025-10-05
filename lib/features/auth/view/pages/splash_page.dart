import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/router/wrapper_page.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';
import 'package:picoshop_theme2/core/storage/user_model.dart';
import 'package:picoshop_theme2/core/storage/user_provider.dart';
import 'package:picoshop_theme2/features/auth/view/pages/login_or_register.dart';

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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => WrapperPage()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginOrRegister()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(0xFF2ECC71),
      child: SafeArea(
        child: Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
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
                      const SizedBox(height: 8,),
                      Text(
                        'Welcome to Pico Shop',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
