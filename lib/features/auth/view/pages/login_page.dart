import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/core/storage/user_model.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';
import 'package:picoshop_theme2/core/storage/user_provider.dart';
import 'package:picoshop_theme2/core/widgets/app_text_form_field.dart';
import 'package:picoshop_theme2/features/auth/model/request/login_request.dart';
import 'package:picoshop_theme2/features/auth/model/response/login_response.dart';
import 'package:picoshop_theme2/features/auth/viewmodel/auth_notifier.dart';

class LoginPage extends ConsumerStatefulWidget {
  final VoidCallback? toggle;
  const LoginPage({super.key, this.toggle});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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
    final responsive = Responsive(context);
    final loginAsync = ref.watch(loginNotifierProvider);

    ref.listen<AsyncValue<LoginResponse?>>(loginNotifierProvider, (prev, next) {
      next.whenOrNull(
        data: (response) {
          if (response?.success == true && response?.data.accessToken != null) {
            final storage = ref.read(secureStorageProvider);
            final auth = response!.data;
            final user = auth.user;

            storage.saveAuthData(
              accessToken: auth.accessToken,
              refreshToken: auth.refreshToken,
              userId: user.id.toString(),
            );

            storage.saveUserInfo(
              name: user.name ?? '',
              email: user.email,
              phone: user.phone
              
            );

            ref.read(userProvider.notifier).state = UserModel(
              id: user.id.toString(),
              name: user.name ?? '',
              email: user.email,
              phone: user.phone,
            );

            print(user.name);
            print(user.email);

            AppConfig.updateAccessToken(auth.accessToken);

            if (context.mounted) {
              context.go('/home');
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

    return Container(
      color: Color(0xFFFFC107),
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFFC107),
                  Color(0xFFFFE082),
                  Color(0xFFA5D6A7),
                ],
              ),
            ),
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
                      // Logo / Title
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
                      const SizedBox(height: 30),

                      // Email Field
                      _glassCard(
                        child: AppTextFormField(
                          controller: _emailController,
                          hintText: "Email",
                          validator: (value) =>
                              value!.isEmpty ? "Email required" : null,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Password Field
                      _glassCard(
                        child: AppTextFormField(
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
                      ),
                      const SizedBox(height: 20),

                      // Login Button
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                            shadowColor: Colors.green.withOpacity(0.3),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) login();
                          },
                          child: loginAsync.isLoading
                              ? const SpinKitCircle(
                                  color: Colors.white,
                                  size: 28,
                                )
                              : Text(
                                  "Log In",
                                  style: GoogleFonts.poppins(
                                    fontSize: responsive.subHeading,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: GoogleFonts.poppins(color: Colors.white70),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: widget.toggle,
                            child: Text(
                              'Register',
                              style: GoogleFonts.poppins(
                                color: Colors.green.shade800,
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
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: child,
    );
  }
}
