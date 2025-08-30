import 'package:flutter/material.dart';
import 'package:picoshop_theme2/features/auth/view/pages/login_page.dart';
import 'package:picoshop_theme2/features/auth/view/pages/register_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool isLogin = false;

  void toggle() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLogin) {
      return LoginPage(toggle: toggle);
    } else {
      return RegisterPage(toggle: toggle);
    }
  }
}
