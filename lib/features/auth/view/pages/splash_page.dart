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
      final storage = ref.read(secureStorageProvider);

      // read flags and login status
      final isFirstLaunch = await storage.getFirstLaunchFlag() ?? true;
      final isLoggedIn = await storage.isLoggedIn();

      // show splash for 2 seconds
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      // first time open → onboarding
      if (isFirstLaunch) {
        await storage.setFirstLaunchFlag(false);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnboardingPage()),
        );
        return;
      }

      // already logged in
      if (isLoggedIn) {
        final userInfo = await storage.getUserInfo();
        final userId = await storage.getUserId();

        // set user data if available
        if (userId != null) {
          ref.read(userProvider.notifier).state = UserModel(
            id: userId,
            name: userInfo['name'] ?? '',
            email: userInfo['email'] ?? '',
            phone: userInfo['phone'] ?? '',
          );
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WrapperPage()),
        );
        return;
      }

      // default → go to onboarding
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingPage()),
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
              Image.asset(AppImage.appLogo, scale: 3),
              const SizedBox(height: 8),
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
