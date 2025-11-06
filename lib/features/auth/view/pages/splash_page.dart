import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
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
      // read the secure storage provider
      final storage = ref.read(secureStorageProvider);

      // check if this is first time launching app
      final isFirstLaunch = await storage.getFirstLaunchFlag() ?? true;

      // check if user already logged in
      final isLoggedIn = await storage.isLoggedIn();

      if (!mounted) return;

      // wait for 2 seconds to show splash
      await Future.delayed(const Duration(microseconds: 500));

      // if first launch, go to onboarding
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

      // if user is logged in, set user info and go to wrapper/home
      if (isLoggedIn) {
        final userInfo = await storage.getUserInfo();
        final userId = await storage.getUserId();

        // only set user if all important info exists
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
    final fontSize = Responsive(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // app logo
              Image.asset(AppImage.appLogo, scale: 3),
              const SizedBox(height: 8),
              // app labels
              Text(
                'Welcome to Pico Mart',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: fontSize.subHeading,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Discover your favorite items here',
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: fontSize.body,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
