import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/config/app_config.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';
import 'package:picoshop_theme2/core/storage/user_model.dart';
import 'package:picoshop_theme2/core/storage/user_provider.dart';
import 'package:picoshop_theme2/features/auth/model/request/verify_code_request.dart';
import 'package:picoshop_theme2/features/auth/model/response/verify_code_response.dart';
import 'package:picoshop_theme2/features/auth/viewmodel/auth_notifier.dart';
import 'package:picoshop_theme2/features/wrapper/wrapper_page.dart';
import 'package:picoshop_theme2/shared/app_button.dart';
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
    //final resentAsync = ref.watch(verifyCodeNotifierProvider);
    final storage = ref.watch(secureStorageProvider);
    final fontSize = Responsive(context);

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
            );

            storage.saveUserInfo(
              name: user.name ?? '',
              email: user.email,
              phone: user.phone,
            );

            ref.read(userProvider.notifier).state = UserModel(
              id: user.id.toString(),
              name: user.name ?? '',
              email: user.email,
              phone: user.phone,
            );

            storage.isLoggedIn();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Colors.grey[200],
                content: Text(
                  data.message,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: Responsive(context).body,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            );

            await storage.clearPendingEmail();
            await storage.setVerifyStage(false);

            AppConfig.updateAccessToken(accessToken);

            Navigator.pushAndRemoveUntil(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(builder: (_) => const WrapperPage()),
              (route) => false,
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
                style: TextStyle(
                  fontFamily: "Poppins",
                  fontSize: Responsive(context).body,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
        loading: () {},
      );
    });

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        final storage = ref.read(secureStorageProvider);
        await storage.setVerifyStage(false);
        await storage.clearPendingEmail();
        return true; // allow pop
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: Responsive(context).isMobile
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 50)
                : const EdgeInsets.symmetric(horizontal: 260, vertical: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(AppImage.appLogo, scale: 4),

                const SizedBox(height: 30),
                Text(
                  'OTP Verification',
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: fontSize.subHeading,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'OTP sent to ${widget.email ?? ""}',
                  style: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                    fontSize: fontSize.body,
                  ),
                ),
                const SizedBox(height: 24),
                PinCodeTextField(
                  onChanged: (value) => code = value,
                  onCompleted: (value) {
                    code = value;
                    verifyCode();
                  },
                  appContext: context,
                  length: 6,
                  keyboardType: TextInputType.number,
                  enableActiveFill: true,
                  animationType: AnimationType.none,
                  animationDuration: Duration.zero,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  textStyle: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                    fieldHeight: 50,
                    fieldWidth: 40,
                    borderWidth: 1.5,
                    activeFillColor: Colors.grey[100],
                    selectedFillColor: Colors.grey[100],
                    inactiveFillColor: Colors.grey[100],
                    activeColor: Colors.grey[400],
                    selectedColor: Colors.grey[400],
                    inactiveColor: Colors.grey[400],
                  ),
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      ref
                          .read(verifyCodeNotifierProvider.notifier)
                          .resentVerifyCode(widget.email!);
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Resend Code',
                          style: TextStyle(fontSize: fontSize.body),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: AppButton(
                    title: 'Verify Code',
                    onTap: verifyCode,
                    backgroundColor: AppColors.primary,
                    labelColor: Colors.white,
                    isLoading: verifyAsync.isLoading ? true : false,
                  ),
                ),

                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Back to",
                      style: TextStyle(
                        fontSize: fontSize.subHeading,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
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
                const SizedBox(height: 40),
                Text(
                  '© 2025 Pico SBS',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: fontSize.body,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
