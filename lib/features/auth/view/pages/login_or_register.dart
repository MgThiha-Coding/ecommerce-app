import 'package:flutter/material.dart';
import 'package:picoshop_theme2/features/auth/view/pages/login_page.dart';
import 'package:picoshop_theme2/features/auth/view/pages/register_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _SignInOrSignUpState();
}

class _SignInOrSignUpState extends State<LoginOrRegister> {
  final PageController _controller = PageController(initialPage: 0);

  bool isLogin = true;

  void toggle() {
    setState(() {
      isLogin = !isLogin;
      _controller.animateToPage(
        isLogin ? 0 : 1,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          LoginPage(toggle: toggle),
          RegisterPage(toggle: toggle),
        ],
      ),
    );
  }
}
