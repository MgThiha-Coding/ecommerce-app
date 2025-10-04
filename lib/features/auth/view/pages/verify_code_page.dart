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

  Future<String?> getDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      final webInfo = await deviceInfo.webBrowserInfo;
      return '${webInfo.browserName}-${webInfo.platform}';
    } else if (Platform.isAndroid) {
      return (await deviceInfo.androidInfo).id;
    } else if (Platform.isIOS) {
      return (await deviceInfo.iosInfo).identifierForVendor;
    }
    return null;
  }

  void verifyCode() {
    if (code.length != 6) return;
    ref.read(verifyCodeNotifierProvider.notifier).verifyCode(
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

    ref.listen<AsyncValue<VerifyCodeResponse?>>(verifyCodeNotifierProvider,
        (_, state) {
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
            );

          

            AppConfig.updateAccessToken(accessToken);
            context.go('/home');
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
        loading: () {},
      );
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'OTP Verification',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'OTP sent to ${widget.email ?? ""}',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 24),

                _glassCard(
                  child: PinCodeTextField(
                    appContext: context,
                    length: 6,
                    onChanged: (value) => code = value,
                    onCompleted: (value) => code = value,
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(8),
                      fieldHeight: 50,
                      fieldWidth: 40,
                      activeFillColor: Colors.transparent,
                      selectedFillColor: Colors.transparent,
                      inactiveFillColor: Colors.grey.withOpacity(0.1),
                      activeColor: Colors.grey.shade300,
                      selectedColor: Colors.green.shade700,
                      inactiveColor: Colors.grey.shade300,
                    ),
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    animationDuration: const Duration(milliseconds: 250),
                    enableActiveFill: true,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    textStyle: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => ref
                        .read(verifyCodeNotifierProvider.notifier)
                        .resentVerifyCode(widget.email!),
                    child: Text(
                      'Resend Code',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: responsive.body,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: MaterialButton(
                    onPressed: verifyAsync.isLoading ? null : verifyCode,
                    color: const Color(0xFF42B946),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: verifyAsync.isLoading
                        ? const SpinKitCircle(color: Colors.white, size: 28)
                        : Text(
                            'Verify Code',
                            style: GoogleFonts.poppins(
                              fontSize: responsive.subHeading,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  '© 2025 Pico SBS',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _glassCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
      child: child,
    );
  }
}
