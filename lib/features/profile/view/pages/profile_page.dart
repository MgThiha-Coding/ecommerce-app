import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/localization/locale_keys.g.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/core/storage/user_provider.dart';
import 'package:picoshop_theme2/features/auth/view/pages/login_or_register.dart';
import 'package:picoshop_theme2/features/auth/viewmodel/auth_notifier.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';
import 'package:picoshop_theme2/features/payment/view/payment_method_page.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    final logOutAsync = ref.watch(logOutNotifierProvider);
    ref.listen<AsyncValue<dynamic>>(logOutNotifierProvider, (previous, next) {
      next.when(
        data: (data) {
          if (data != null) {
            Future.microtask(() async {
              final storage = ref.read(secureStorageProvider);
              await storage.clear();
              if (!mounted) return;
              Navigator.pushReplacement(
                // ignore: use_build_context_synchronously
                context,
                MaterialPageRoute(builder: (_) => const LoginOrRegister()),
              );
            });
          }
        },
        loading: () {},
        error: (error, _) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.grey[200],
              content: Text(
                error.toString(),
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Consumer(
                    builder: (context, ref, _) {
                      final user = ref.watch(userProvider);
                      final displayName = (user?.name.isNotEmpty ?? false)
                          ? user!.name
                          : "Min Thih Aung";
                      final displayEmail = (user?.email.isNotEmpty ?? false)
                          ? user!.email
                          : "Guest";

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            displayEmail,
                            style: GoogleFonts.poppins(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      children: [
                        _buildMenuTile(
                          title: LocaleKeys.accountInfo.tr(),
                          icon: Icons.person_outline,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Consumer(
                                  builder: (context, ref, _) {
                                    final user = ref.watch(userProvider);
                                    final displayPhone =
                                        (user?.phone.isNotEmpty ?? false)
                                        ? user!.phone
                                        : "Unknown";
                                    final displayName =
                                        (user?.name.isNotEmpty ?? false)
                                        ? user!.name
                                        : "Pico Shop User";
                                    final displayEmail =
                                        (user?.email.isNotEmpty ?? false)
                                        ? user!.email
                                        : "Unknown";

                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              LocaleKeys.accountInfo.tr(),
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  displayName,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  displayEmail,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  displayPhone,
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 13,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 16),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context),
                                                child: Text(
                                                  "Close",
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        _buildMenuTile(
                          title: LocaleKeys.orderHistory.tr(),
                          icon: Icons.history,
                          onTap: () {},
                        ),
                        _buildMenuTile(
                          title: LocaleKeys.shippingMethod.tr(),
                          icon: Icons.local_shipping,
                          onTap: () {
                           
                          },
                        ),
                        _buildMenuTile(
                          title: LocaleKeys.paymentMethod.tr(),
                          icon: Icons.payment,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PaymentMethodPage(shippingMethod: ''),
                              ),
                            );
                          },
                        ),

                        _buildMenuTile(
                          title: LocaleKeys.language.tr(),
                          icon: Icons.language,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return Dialog(
                                  elevation: 10,
                                  insetPadding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 24,
                                  ),
                                  backgroundColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                        colors: [
                                          // ignore: deprecated_member_use
                                          AppColors.background.withOpacity(
                                            0.95,
                                          ),
                                          // ignore: deprecated_member_use
                                          AppColors.background.withOpacity(
                                            0.85,
                                          ),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          // ignore: deprecated_member_use
                                          color: AppColors.primary.withOpacity(
                                            0.4,
                                          ),
                                          blurRadius: 18,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          LocaleKeys.language.tr(),
                                          style: GoogleFonts.poppins(
                                            color: AppColors.textSecondary,
                                            fontSize: 18,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        _languageButton(
                                          context,
                                          "English",
                                          const Locale('en'),
                                        ),
                                        _languageButton(
                                          context,
                                          "Español (Spanish)",
                                          const Locale('es'),
                                        ),
                                        _languageButton(
                                          context,
                                          "Français (French)",
                                          const Locale('fr'),
                                        ),
                                        _languageButton(
                                          context,
                                          "العربية (Arabic)",
                                          const Locale('ar'),
                                        ),
                                        _languageButton(
                                          context,
                                          "日本語 (Japanese)",
                                          const Locale('ja'),
                                        ),
                                        _languageButton(
                                          context,
                                          "Deutsch (German)",
                                          const Locale('de'),
                                        ),
                                        _languageButton(
                                          context,
                                          "Nederlands (Dutch)",
                                          const Locale('nl'),
                                        ),
                                        _languageButton(
                                          context,
                                          "ไทย (Thai)",
                                          const Locale('th'),
                                        ),
                                        _languageButton(
                                          context,
                                          "မြန်မာ (Burmese)",
                                          const Locale('my'),
                                        ),
                                        _languageButton(
                                          context,
                                          "中文 (Chinese)",
                                          const Locale('zh'),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primary,
                                              elevation: 0,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: Text(
                                              "Close",
                                              style: GoogleFonts.poppins(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: logOutAsync.isLoading
                                  ? null
                                  : () {
                                      ref
                                          .read(logOutNotifierProvider.notifier)
                                          .logOut();
                                    },
                              child: Ink(
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: logOutAsync.isLoading
                                      ? const SpinKitCircle(
                                          size: 20,
                                          color: Colors.white,
                                        )
                                      : Text(
                                          "Log Out",
                                          style: GoogleFonts.poppins(
                                            fontSize: Responsive(context).body,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageButton(BuildContext context, String label, Locale locale) {
    return SizedBox(
      width: double.infinity,
      child: MaterialButton(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onPressed: () {
          context.setLocale(locale);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Language changed to $label',
                style: GoogleFonts.poppins(color: Colors.white,fontSize: Responsive(context).body),
              ),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: Responsive(context).body,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: Responsive(context).body),
    );
  }
}
