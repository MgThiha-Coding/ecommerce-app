import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';
import 'package:picoshop_theme2/core/storage/user_model.dart';
import 'package:picoshop_theme2/core/storage/user_provider.dart';
import 'package:picoshop_theme2/features/auth/view/pages/on_boarding_page.dart';
import 'package:picoshop_theme2/features/wrapper/wrapper_page.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final storage = ref.read(secureStorageProvider);

      // 1️⃣ First launch?
      final isFirstLaunch = await storage.getFirstLaunchFlag() ?? true;

      // 3️⃣ Logged in?
      final isLoggedIn = await storage.isLoggedIn();

      if (!mounted) return;

      // small splash delay
      await Future.delayed(const Duration(seconds: 2));

      if (isFirstLaunch) {
        await storage.setFirstLaunchFlag(false);
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingPage()),
          (route) => false,
        );
        return;
      }

      if (isLoggedIn) {
        // restore user info
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

        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const WrapperPage()),
          (route) => false,
        );
        return;
      }

      // fallback → onboarding
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(AppImage.appLogo, scale: 3),
              const SizedBox(height: 8),
              Text(
                'Welcome to Pico Mart',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Discover your favorite items here',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
