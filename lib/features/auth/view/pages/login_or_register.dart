import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';
import 'package:picoshop_theme2/features/auth/view/pages/login_page.dart';
import 'package:picoshop_theme2/features/auth/view/pages/register_page.dart';
import 'package:picoshop_theme2/features/auth/view/pages/verify_code_page.dart';

class LoginOrRegister extends ConsumerStatefulWidget {
  const LoginOrRegister({super.key});

  @override
  ConsumerState<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends ConsumerState<LoginOrRegister> {
  final PageController _controller = PageController(initialPage: 0);
  bool isLogin = true;
  bool _verificationChecked = false;

  @override
  void initState() {
    super.initState();
    _checkVerificationStage();
  }

  /// Checks if user has a pending verification
  Future<void> _checkVerificationStage() async {
    final storage = ref.read(secureStorageProvider);
    final verifyStage = await storage.getVerifyStage();
    final pendingEmail = await storage.getPendingEmail();

    if (!mounted) return;

    if (verifyStage && pendingEmail != null) {
      setState(() {
        _verificationChecked = true;
      });

      // Show a subtle prompt for the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete your verification')),
      );

      // Navigate to VerifyCodePage without blocking back
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VerifyCodePage(email: pendingEmail)),
      );
    } else {
      setState(() {
        _verificationChecked = true;
      });
    }
  }

  void togglePage() {
    if (!_controller.hasClients) return;
    setState(() {
      isLogin = !isLogin;
      _controller.animateToPage(
        isLogin ? 0 : 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // While checking verification stage, show a loader
    if (!_verificationChecked) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: SpinKitCircle(color: AppColors.primary)),
      );
    }

    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          LoginPage(toggle: togglePage),
          RegisterPage(toggle: togglePage),
        ],
      ),
    );
  }
}
