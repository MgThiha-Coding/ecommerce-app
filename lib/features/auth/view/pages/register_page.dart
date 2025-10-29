import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/provider/auth_stage_provider.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/auth/model/request/register_request.dart';
import 'package:picoshop_theme2/features/auth/model/response/register_response.dart';
import 'package:picoshop_theme2/features/auth/view/pages/verify_code_page.dart';
import 'package:picoshop_theme2/features/auth/viewmodel/auth_notifier.dart';
import 'package:picoshop_theme2/shared/app_button.dart';
import 'package:picoshop_theme2/shared/app_text_field.dart';

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

            await ref
                .read(authStageProvider.notifier)
                .setStage(
                  AuthStage.verify,
                  email: _emailController.text,
                );

            Navigator.push(
              // ignore: use_build_context_synchronously
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

    final fontSize = Responsive(context);
    Widget buildLabel(String text) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: fontSize.body,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
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
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(AppImage.appLogo, scale: 4),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Create Your Account',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: fontSize.subHeading,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 20),
                  buildLabel('First Name'),
                  const SizedBox(height: 4),
                  AppTextField(
                    controller: _firstNameController,
                    hintText: "First Name",
                    validator: (v) => v == null || v.isEmpty
                        ? "Please enter your first name"
                        : null,
                  ),

                  const SizedBox(height: 4),
                  buildLabel('Last Name'),
                  const SizedBox(height: 4),
                  AppTextField(
                    controller: _lastNameController,
                    hintText: "Last Name",
                    validator: (v) => v == null || v.isEmpty
                        ? "Pleae enter your last name"
                        : null,
                  ),

                  const SizedBox(height: 4),
                  buildLabel('Email'),
                  const SizedBox(height: 4),
                  AppTextField(
                    controller: _emailController,
                    hintText: "Email",
                    validator: (v) => v == null || v.isEmpty
                        ? "Please enter your email"
                        : null,
                  ),

                  const SizedBox(height: 4),

                  // Phone Field
                  buildLabel('Phone'),
                  const SizedBox(height: 4),
                  AppTextField(
                    controller: _phoneController,
                    hintText: "Phone",
                    validator: (v) => v == null || v.isEmpty
                        ? "Please enter your phone"
                        : null,
                  ),

                  const SizedBox(height: 4),

                  // Password Field
                  buildLabel('Password'),
                  const SizedBox(height: 4),
                  AppTextField(
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

                  const SizedBox(height: 4),

                  buildLabel('Confirm Password'),
                  const SizedBox(height: 4),

                  AppTextField(
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

                  const SizedBox(height: 16),

                  // Register Button
                  SizedBox(
                    height: Responsive(context).authButtonHeight,
                    width: double.infinity,
                    child: AppButton(
                      title: "Sign Up",
                      onTap: register,
                      backgroundColor: AppColors.primary,
                      labelColor: AppColors.background,
                      isLoading: registerAsync.isLoading ? true : false,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(
                          fontSize: fontSize.subHeading,
                          fontFamily: 'Poppins',
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: widget.toggle,
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: fontSize.subHeading,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Responsive(context).isMobile
                      ? const SizedBox(height: 40)
                      : const SizedBox(height: 20),

                  Text(
                    '© 2025 Pico SBS',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: fontSize.body,
                      color: AppColors.textSecondary,
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
