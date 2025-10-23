import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/core/storage/user_provider.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';
import 'package:picoshop_theme2/features/auth/view/pages/login_or_register.dart';
import 'package:picoshop_theme2/features/auth/viewmodel/auth_notifier.dart';
import 'package:picoshop_theme2/features/order_history/view/order_history_list_page.dart';
import 'package:picoshop_theme2/features/profile/view/pages/payment_method_page.dart';
import 'package:picoshop_theme2/features/profile/view/pages/shipping_method_page.dart';
import 'package:picoshop_theme2/core/localization/locale_keys.g.dart';
import 'package:picoshop_theme2/shared/app_button.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final logOutAsync = ref.watch(logOutNotifierProvider);

    ref.listen<AsyncValue<dynamic>>(logOutNotifierProvider, (prev, next) {
      next.when(
        data: (data) async {
          if (data != null) {
            final storage = ref.read(secureStorageProvider);
            await storage.clear();
            // ignore: use_build_context_synchronously
            await context.setLocale(const Locale('en'));

            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              // ignore: use_build_context_synchronously
              context,
              MaterialPageRoute(builder: (_) => const LoginOrRegister()),
              (route) => false,
            );
          }
        },
        loading: () {},
        error: (err, _) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Colors.grey[200],
              content: Text(
                err.toString(),
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

    final user = ref.watch(userProvider);

    final displayName = (user?.name.isNotEmpty ?? false)
        ? user!.name
        : "Pico Mart";
    final displayEmail = (user?.email.isNotEmpty ?? false)
        ? user!.email
        : "Guest";

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(displayName, displayEmail),
            const SizedBox(height: 10),
            Expanded(child: _buildMenuCards(responsive, logOutAsync)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String name, String email) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                email,
                style: GoogleFonts.poppins(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCards(
    Responsive responsive,
    AsyncValue<dynamic> logOutAsync,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        elevation: 6,
        color: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            children: [
              _buildMenuTile(
                title: LocaleKeys.accountInfo.tr(),
                icon: Icons.person_outline,
                onTap: () => _showAccountInfoDialog(),
              ),
              _buildMenuTile(
                title: LocaleKeys.orderHistory.tr(),
                icon: Icons.history,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrderHistoryListPage(),
                  ),
                ),
              ),
              _buildMenuTile(
                title: LocaleKeys.shippingMethod.tr(),
                icon: Icons.local_shipping,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShippingMethodPage()),
                ),
              ),
              _buildMenuTile(
                title: LocaleKeys.paymentMethod.tr(),
                icon: Icons.payment,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PaymentMethodPage()),
                ),
              ),
              _buildMenuTile(
                title: LocaleKeys.language.tr(),
                icon: Icons.language,
                onTap: () => _showLanguageDialog(),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: AppButton(
                    title: "Sign Out",
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => const _LogoutConfirmDialog(),
                      );
                    },

                    backgroundColor: AppColors.primary,
                    labelColor: AppColors.background,
                  ),
                ),
              ),
            ],
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

  void _showAccountInfoDialog() {
    final user = ref.watch(userProvider);
    final displayPhone = (user?.phone.isNotEmpty ?? false)
        ? user!.phone
        : "Unknown";
    final displayName = (user?.name.isNotEmpty ?? false)
        ? user!.name
        : "Pico Shop User";
    final displayEmail = (user?.email.isNotEmpty ?? false)
        ? user!.email
        : "Unknown";

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.accountInfo.tr(),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
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
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      "Close",
                      style: GoogleFonts.poppins(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLanguageDialog() {
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
                  AppColors.background.withOpacity(0.95),
                  // ignore: deprecated_member_use
                  AppColors.background.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: AppColors.primary.withOpacity(0.4),
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
                _languageButton(context, "English", const Locale('en')),

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
                _languageButton(context, "ไทย (Thai)", const Locale('th')),
                _languageButton(
                  context,
                  "မြန်မာ (Burmese)",
                  const Locale('my'),
                ),
                _languageButton(context, "中文 (Chinese)", const Locale('zh')),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
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
  }

  Widget _languageButton(BuildContext context, String label, Locale locale) {
    return SizedBox(
      width: double.infinity,

      child: MaterialButton(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onPressed: () {
          context.setLocale(locale);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Language changed to $label',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: Responsive(context).body,
                ),
              ),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 2),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutConfirmDialog extends ConsumerWidget {
  const _LogoutConfirmDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final responsive = Responsive(context);
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Colors.red.shade400,
                size: 32,
              ),
            ),
            const SizedBox(height: 18),

            Text(
              "Sign Out?",
              style: TextStyle(
                fontSize: responsive.body,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontFamily: "Poppins",
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "Are you sure you want to sign out?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: responsive.body,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 22),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: Colors.grey.shade700,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      "Cancel",
                      style: TextStyle(
                        fontSize: responsive.body,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: AppButton(
                    title: "Sign Out",
                    onTap: () async {
                      if (!ref.read(logOutNotifierProvider).isLoading) {
                        ref.read(logOutNotifierProvider.notifier).logOut();
                      }
                    },
                    isLoading: ref.watch(logOutNotifierProvider).isLoading,
                    backgroundColor: AppColors.primary,
                    labelColor: AppColors.background,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
