// lib/features/auth/ui/verify_code_page.dart
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/router/wrapper_page.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';
import 'package:picoshop_theme2/features/auth/model/request/verify_code_request.dart';
import 'package:picoshop_theme2/features/auth/model/response/verify_code_response.dart';
import 'package:picoshop_theme2/features/auth/view/pages/login_or_register.dart';
import 'package:picoshop_theme2/features/auth/viewmodel/auth_notifier.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class VerifyCodePage extends ConsumerStatefulWidget {
  final String? email;
  final String? deviceName;

  const VerifyCodePage({super.key, this.email, this.deviceName});

  @override
  ConsumerState<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends ConsumerState<VerifyCodePage> {
  String code = '';

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

  void verifyCode() {
    if (widget.email == null || widget.deviceName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email is required')),
      );
      return;
    }
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 6-digit code')),
      );
      return;
    }

    ref
        .read(verifyCodeNotifierProvider.notifier)
        .verifyCode(
          VerifyCodeRequest(
            emailOrPhone: widget.email!,
            verificationCode: code,
            deviceName: widget.deviceName!,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final verifyState = ref.watch(verifyCodeNotifierProvider);
    final storage = ref.watch(secureStorageProvider);

    ref.listen<AsyncValue<VerifyCodeResponse?>>(
      verifyCodeNotifierProvider,
      (_, state) {
        state.when(
          data: (data) async {
            if (data != null && data.success) {
              final accessToken = data.data.auth.accessToken;
              final refreshToken = data.data.auth.refreshToken;
              final userId = data.data.user.id.toString();

              await storage.saveAuthData(
                accessToken: accessToken,
                refreshToken: refreshToken,
                userId: userId,
              );

              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(data.message)));

              // Navigate to WrapperPage
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => WrapperPage()),
              );
            }
          },
          error: (error, _) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(error.toString())));
          },
          loading: () {},
        );
      },
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height,
          ),
          child: IntrinsicHeight(
            child: Container(
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
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    // Image.asset(AppImage.otpVerify, scale: 4),
                    const SizedBox(height: 20),
                    Text(
                      'OTP Verification',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'OTP sent to your Mail ${widget.email ?? ""}',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 16),
                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      onChanged: (value) => code = value,
                      onCompleted: (value) => code = value,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(4),
                        fieldHeight: 50,
                        fieldWidth: 36,
                        activeFillColor: Colors.white,
                        selectedFillColor: Colors.grey.shade200,
                        inactiveFillColor: Colors.grey.shade100,
                        activeColor: Colors.blue,
                        selectedColor: Colors.blue,
                        inactiveColor: Colors.grey,
                      ),
                      keyboardType: TextInputType.number,
                      animationType: AnimationType.fade,
                      animationDuration: const Duration(milliseconds: 300),
                      enableActiveFill: true,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    ),
                    const SizedBox(height: 8.0),
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        'Resend Code',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    SizedBox(
                      height: 45,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          disabledBackgroundColor: Colors.blue,
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: verifyState.isLoading ? null : verifyCode,
                        child: verifyState.isLoading
                            ? const SpinKitFadingCircle(
                                size: 30,
                                color: Colors.white,
                              )
                            : Text(
                                'Verify Code',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 14,),
                    SizedBox(
                      height: 45,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          disabledBackgroundColor: Colors.blue,
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginOrRegister()));
                        },
                        child: Text('Back',style: GoogleFonts.poppins( 
                           color: Colors.white,
                           fontSize: 15
                        ),)
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
