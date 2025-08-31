import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<String?> getDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
      return '${webBrowserInfo.browserName}${webBrowserInfo.platform}${webBrowserInfo.product}${webBrowserInfo.productSub}${webBrowserInfo.vendor}';
    } else {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor;
      }
    }
    return null;
  }

  void register() async {
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
            deviceName: deviceName!,
            passwordConfirmation: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    double getHorizontalPadding(double width) {
      if (width >= 1400) return 400;
      if (width >= 1024) return 200;
      if (width >= 768) return 50;
      return 15;
    }

    double screenWidth = MediaQuery.of(context).size.width;

    ref.watch(registerNotifierProvider);

    ref.listen<AsyncValue<RegisterResponse?>>(registerNotifierProvider, (
      previous,
      next,
    ) {
      next.whenOrNull(
        data: (response) async {
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
        },
        error: (error, stack) {
          final message = error is Map && error['message'] != null
              ? error['message']
              : 'Registration failed';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.grey[200],
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Text(
                      message,
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

    final registerAsync = ref.watch(registerNotifierProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey.shade300, Colors.grey.shade300],
          ),
        ),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.blue.shade900,
                      Colors.blue.shade500,
                      Colors.blue.shade100,
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: getHorizontalPadding(screenWidth),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Pico Shop',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Icon(
                              Icons.shopping_bag,
                              color: Colors.white,
                              size: 30,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        AppTextFormField(
                          controller: _firstNameController,
                          hintText: "First Name",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "First Name required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8.0),
                        AppTextFormField(
                          controller: _lastNameController,
                          hintText: "Last Name",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Last Name required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8.0),
                        AppTextFormField(
                          controller: _emailController,
                          hintText: "Email",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Email required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8.0),
                        AppTextFormField(
                          controller: _phoneController,
                          hintText: "Phone",
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Phone number required";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8.0),
                        AppTextFormField(
                          controller: _passwordController,
                          hintText: "Password",
                          addObscure: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Password required";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8.0),
                        AppTextFormField(
                          controller: _confirmController,
                          hintText: "Confirm Password",
                          addObscure: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Confirm Password required";
                            }
                            if (value.length < 6) {
                              return "Password must be at least 6 characters";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16.0),
                        SizedBox(
                          height: 46,
                          width: double.infinity,
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            onPressed: registerAsync.isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      register();
                                    }
                                  },
                            color: Colors.blue.shade900,
                            child: registerAsync.isLoading
                                ? SpinKitCircle(color: Colors.white, size: 27)
                                : const Text(
                                    "Sign Up",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: TextStyle(color: Colors.white),
                            ),
                            const SizedBox(width: 4.0),
                            GestureDetector(
                              onTap: widget.toggle,
                              child: Text(
                                'Log In',
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
      ),
    );
  }
}
