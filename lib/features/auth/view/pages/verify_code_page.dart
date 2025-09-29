import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';
import 'package:picoshop_theme2/features/auth/model/request/verify_code_request.dart';
import 'package:picoshop_theme2/features/auth/model/response/verify_code_response.dart';
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

  // Get Device Info
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

  // Verify code
  void verifyCode() {
    if (code.length != 6) return;
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
    final verifyAsync = ref.watch(verifyCodeNotifierProvider);
    final storage = ref.watch(secureStorageProvider);
    final responsive = Responsive(context);

    ref.listen<AsyncValue<VerifyCodeResponse?>>(verifyCodeNotifierProvider, (
      _,
      state,
    ) {
      state.when(
        data: (data) async {
          if (data != null && data.success) {
            final accessToken = data.data.auth.accessToken;
            final refreshToken = data.data.auth.refreshToken;
            final user = data.data.user;

            await storage.saveAuthData(
              accessToken: accessToken,
              refreshToken: refreshToken,
              userId: user.id.toString(),
              name: user.name,
              email: user.email,
              phone: user.phone,
            );

            AppConfig.updateAccessToken(accessToken);
           
            context.go('/home');

           
          }
        },
        error: (error, _) {
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
        loading: () {},
      );
    });

    return Container(
      color: Colors.blue.shade400,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blue.shade900,
            leading: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: responsive.value(mobile: 15, tablet: 20, desktop: 30),
              ),
            ),
          ),
          body: SingleChildScrollView(
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

                        // Otp pin code field
                        PinCodeTextField(
                          appContext: context,
                          length: 6,
                          onChanged: (value) => code = value,
                          onCompleted: (value) => code = value,
                          pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(6),
                            fieldHeight: 52,
                            fieldWidth: 40,
                            activeFillColor: Colors.transparent,
                            selectedFillColor: Colors.transparent,
                            inactiveFillColor: Colors.grey.withOpacity(0.1),
                            activeColor: Colors.grey.shade300,
                            selectedColor: Colors.blue,
                            inactiveColor: Colors.grey.shade300,
                          ),
                          keyboardType: TextInputType.number,
                          animationType: AnimationType.fade,
                          animationDuration: const Duration(milliseconds: 250),
                          enableActiveFill: true,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                offset: Offset(0, 1),
                                blurRadius: 2,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        // Resent code Button
                        Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              ref
                                  .read(verifyCodeNotifierProvider.notifier)
                                  .resentVerifyCode(widget.email!);
                            },
                            child: Text(
                              'Resend Code',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: responsive.body,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 46,
                          width: double.infinity,
                          child: MaterialButton(
                            onPressed: verifyAsync.isLoading
                                ? null
                                : verifyCode,
                            color: Colors.blue.shade900,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: verifyAsync.isLoading
                                ? SpinKitCircle(color: Colors.white, size: 27)
                                : Text(
                                    "Verify Code",
                                    style: TextStyle(
                                      fontSize: responsive.subHeading,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),

                        // Verify Code Button
                        const SizedBox(height: 10.0),
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
