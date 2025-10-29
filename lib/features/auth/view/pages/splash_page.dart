import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/provider/auth_stage_provider.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';
import 'package:picoshop_theme2/core/storage/user_model.dart';
import 'package:picoshop_theme2/core/storage/user_provider.dart';
import 'package:picoshop_theme2/features/auth/view/pages/login_or_register.dart';
import 'package:picoshop_theme2/features/auth/view/pages/on_boarding_page.dart';
import 'package:picoshop_theme2/features/auth/view/pages/login_page.dart';
import 'package:picoshop_theme2/features/auth/view/pages/verify_code_page.dart';
import 'package:picoshop_theme2/features/wrapper/wrapper_page.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  static const _splashDelay = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNavigation();
    });
  }

  Future<void> _handleNavigation() async {
    final storage = ref.read(secureStorageProvider);
    final authStageNotifier = ref.read(authStageProvider.notifier);
    await Future.delayed(_splashDelay);
    final userInfo = await storage.getUserInfo();
    final userId = await storage.getUserId();
    if (userId != null &&
        userInfo['name'] != null &&
        userInfo['email'] != null) {
      ref.read(userProvider.notifier).state = UserModel(
        id: userId,
        name: userInfo['name'] ?? '',
        email: userInfo['email'] ?? '',
        phone: userInfo['phone'] ?? '',
      );
    }
    final isFirstLaunch = await storage.getFirstLaunchFlag() ?? true;
    if (isFirstLaunch) {
      await storage.setFirstLaunchFlag(false);
      await authStageNotifier.setStage(AuthStage.onboarding);
    }
    final currentStage = ref.read(authStageProvider);
    switch (currentStage) {
      case AuthStage.splash:
      case AuthStage.onboarding:
        _navigateRemoveAll(const OnboardingPage());
        break;

      case AuthStage.login:
        _navigateRemoveAll(const LoginOrRegister());
        break;

      case AuthStage.signup:
        final pendingEmail = await authStageNotifier.getPendingEmail();
        if (pendingEmail != null) {
          _navigateRemoveAll(VerifyCodePage(email: pendingEmail));
        } else {
          _navigateRemoveAll(const LoginPage());
        }
        break;

      case AuthStage.verify:
        final pendingEmail = await authStageNotifier.getPendingEmail();
        _navigateRemoveAll(VerifyCodePage(email: pendingEmail));
        break;

      case AuthStage.home:
        final isLoggedIn = await storage.isLoggedIn();
        if (isLoggedIn) {
          _navigateRemoveAll(const WrapperPage());
        } else {
          _navigateRemoveAll(const LoginPage());
        }
        break;
    }
  }

  void _navigateRemoveAll(Widget page) {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => page),
      (_) => false,
    );
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
