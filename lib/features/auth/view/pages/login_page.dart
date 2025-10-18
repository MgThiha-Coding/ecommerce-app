import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/core/storage/user_model.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';
import 'package:picoshop_theme2/core/storage/user_provider.dart';
import 'package:picoshop_theme2/features/auth/model/request/login_request.dart';
import 'package:picoshop_theme2/features/auth/model/response/login_response.dart';
import 'package:picoshop_theme2/features/auth/viewmodel/auth_notifier.dart';
import 'package:picoshop_theme2/features/wrapper/wrapper_page.dart';
import 'package:picoshop_theme2/shared/app_button.dart';
import 'package:picoshop_theme2/shared/app_text_field.dart';

class LoginPage extends ConsumerStatefulWidget {
  final VoidCallback? toggle;
  const LoginPage({super.key, this.toggle});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  // password and email controllers
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // login
  void login() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    ref
        .read(loginNotifierProvider.notifier)
        .login(
          LoginRequest(
            emailOrPhoneOrUserName: email,
            password: password,
            rememberMe: true,
            deviceName: 'Pico User',
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    // app responsive
    final responsive = Responsive(context);
    // watch login state from loginNotifier
    final loginAsync = ref.watch(loginNotifierProvider);

    ref.listen<AsyncValue<LoginResponse?>>(loginNotifierProvider, (prev, next) {
      next.whenOrNull(
        data: (response) {
          if (response?.success == true && response?.data.accessToken != null) {
            final storage = ref.read(secureStorageProvider);
            final auth = response!.data;
            final user = auth.user;

            // Save auth data
            storage.saveAuthData(
              accessToken: auth.accessToken,
              refreshToken: auth.refreshToken,
              userId: user.id.toString(),
            );

            // save user information
            storage.saveUserInfo(
              name: user.name ?? '',
              email: user.email,
              phone: user.phone,
            );

            // update in userProvider
            ref.read(userProvider.notifier).state = UserModel(
              id: user.id.toString(),
              name: user.name ?? '',
              email: user.email,
              phone: user.phone,
            );

            storage.isLoggedIn();

            AppConfig.updateAccessToken(auth.accessToken);
            // route to wrapper page
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const WrapperPage()),
              );
            }
          }
        },
        error: (error, _) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                backgroundColor: Colors.grey.shade200,
                content: Text(
                  error.toString(),
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: Colors.red.shade700,
                    fontSize: 12,
                  ),
                ),
              ),
            );
        },
      );
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: responsive.authHorizontalPadding,
              vertical: 50,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Logo & Title
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(AppImage.appLogo, scale: 14),
                      const SizedBox(height: 16),
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

                  const SizedBox(height: 30),

                  // Email Field
                  AppTextField(
                    controller: _emailController,
                    hintText: "Email",
                    validator: (value) =>
                        value!.isEmpty ? "Email required" : null,
                  ),

                  const SizedBox(height: 10),

                  // Password Field
                  AppTextField(
                    controller: _passwordController,
                    hintText: "Password",
                    addObscure: true,
                    validator: (value) {
                      if (value!.isEmpty) return "Password required";
                      if (value.length < 6) {
                        return "Min 6 characters";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // Login Button
                  SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: AppButton(
                      title: "Sign In",
                      onTap: login,
                      backgroundColor: AppColors.primary,
                      labelColor: AppColors.background,
                      isLoading: loginAsync.isLoading ? true : false,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Register
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account?",
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: widget.toggle,
                        child: Text(
                          'Sign Up',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFFFC107),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  // Footer
                  Text(
                    '© 2025 Pico SBS',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
