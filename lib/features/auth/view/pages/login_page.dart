import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/core/router/wrapper_page.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';
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

  // Login
  void login() {
    final email = _emailController.text;
    final password = _passwordController.text;
    final rememberMe = true;
    final deviceName = 'Pico User';
    ref
        .read(loginNotifierProvider.notifier)
        .login(
          LoginRequest(
            emailOrPhoneOrUserName: email,
            password: password,
            rememberMe: rememberMe,
            deviceName: deviceName,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final loginAsync = ref.watch(loginNotifierProvider);
    ref.listen<AsyncValue<LoginResponse?>>(loginNotifierProvider, (prev, next) {
      next.whenOrNull(
        data: (data) async {
          if (data?.success == true && data?.data.accessToken != null) {
            final storage = ref.read(secureStorageProvider);
            await storage.saveAuthData(
              accessToken: data!.data.accessToken,
              refreshToken: data.data.refreshToken,
              userId: data.data.user.id.toString(),
            );
            AppConfig.updateAccessToken(data.data.accessToken);
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const WrapperPage()),
            );
          }
        },
        error: (error, _) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.grey[200],
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Text(
                      error.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: Colors.blueGrey,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade500,
              Colors.blue.shade200,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: responsive.authHorizontalPadding,
                  vertical: 50,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Pico Shop',
                            style: GoogleFonts.poppins(
                              fontSize: responsive.heading,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Email
                      AppTextFormField(
                        controller: _emailController,
                        hintText: "Email",
                        validator: (value) =>
                            value!.isEmpty ? "Email required" : null,
                      ),
                      const SizedBox(height: 8.0),

                      // Password
                      AppTextFormField(
                        controller: _passwordController,
                        hintText: "Password",
                        addObscure: true,
                        validator: (value) {
                          if (value!.isEmpty) return "Password required";
                          if (value.length < 6)
                            return "Password must be at least 6 characters";
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),

                      // Login Button
                      SizedBox(
                        height: 46,
                        width: double.infinity,
                        child: MaterialButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) login();
                          },
                          color: Colors.blue.shade900,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: loginAsync.isLoading
                              ? SpinKitCircle(color: Colors.white, size: 27)
                              : Text(
                                  "Log In",
                                  style: TextStyle(
                                    fontSize: responsive.subHeading,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      //
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 4.0),
                          GestureDetector(
                            onTap: widget.toggle,
                            child: Text(
                              'Register',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
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
}
