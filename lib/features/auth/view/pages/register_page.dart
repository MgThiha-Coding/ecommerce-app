import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/core/widgets/app_text_form_field.dart';
import 'package:picoshop_theme2/features/auth/model/request/register_request.dart';
import 'package:picoshop_theme2/features/auth/model/response/register_response.dart';
import 'package:picoshop_theme2/features/auth/view/pages/verify_code_page.dart';
import 'package:picoshop_theme2/features/auth/viewmodel/auth_notifier.dart';

class RegisterPage extends ConsumerStatefulWidget {
  final VoidCallback toggle;
  const RegisterPage({super.key, required this.toggle});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<String?> getDeviceName() async {
    final deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      final webInfo = await deviceInfo.webBrowserInfo;
      return '${webInfo.browserName}-${webInfo.platform}';
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor;
    }
    return null;
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;
    final deviceName = await getDeviceName();
    ref
        .read(registerNotifierProvider.notifier)
        .register(
          RegisterRequest(
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            password: _passwordController.text,
            passwordConfirmation: _passwordController.text,
            deviceName: deviceName ?? "Unknown",
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final registerAsync = ref.watch(registerNotifierProvider);

    ref.listen<AsyncValue<RegisterResponse?>>(registerNotifierProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        data: (data) async {
          if (data?.success == true) {
            final deviceName = await getDeviceName();

            if (!context.mounted) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VerifyCodePage(
                  email: _emailController.text,
                  deviceName: deviceName,
                ),
              ),
            );
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.grey[200],
              content: Text(
                error.toString(),
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: Colors.blueGrey,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      );
    });

    return Container(
      color: const Color(0xFF2ECC71),
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
                colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.authHorizontalPadding,
                vertical: 50,
              ),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                      const SizedBox(height: 20),

                      // First Name Field
                      _glassCard(
                        child: AppTextFormField(
                          controller: _firstNameController,
                          hintText: "First Name",
                          validator: (v) => v == null || v.isEmpty
                              ? "First Name required"
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Last Name Field
                      _glassCard(
                        child: AppTextFormField(
                          controller: _lastNameController,
                          hintText: "Last Name",
                          validator: (v) => v == null || v.isEmpty
                              ? "Last Name required"
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Email Field
                      _glassCard(
                        child: AppTextFormField(
                          controller: _emailController,
                          hintText: "Email",
                          validator: (v) =>
                              v == null || v.isEmpty ? "Email required" : null,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Phone Field
                      _glassCard(
                        child: AppTextFormField(
                          controller: _phoneController,
                          hintText: "Phone",
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Password Field
                      _glassCard(
                        child: AppTextFormField(
                          controller: _passwordController,
                          hintText: "Password",
                          addObscure: true,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Password required";
                            }
                            if (v.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Confirm Password Field
                      _glassCard(
                        child: AppTextFormField(
                          controller: _confirmController,
                          hintText: "Confirm Password",
                          addObscure: true,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return "Confirm Password required";
                            }
                            if (v != _passwordController.text) {
                              return "Passwords do not match";
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Register Button
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: MaterialButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) register();
                          },
                          color: const Color(0xFFFFC107),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: registerAsync.isLoading
                              ? const SpinKitCircle(
                                  color: Colors.white,
                                  size: 28,
                                )
                              : Text(
                                  "Sign Up",
                                  style: GoogleFonts.poppins(
                                    fontSize: responsive.subHeading,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Log In
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Already have an account?",
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: widget.toggle,
                            child: Text(
                              'Log In',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFFFFC107),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),

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
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: child,
    );
  }
}
