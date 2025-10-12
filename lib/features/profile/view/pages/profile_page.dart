import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/storage/user_provider.dart';
import 'package:picoshop_theme2/features/auth/view/pages/login_or_register.dart';
import 'package:picoshop_theme2/features/auth/viewmodel/auth_notifier.dart';
import 'package:picoshop_theme2/core/storage/storage.dart';
import 'package:picoshop_theme2/features/payment/view/payment_method_page.dart';
import 'package:picoshop_theme2/features/shipping/view/shipping_method_page.dart';

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
      backgroundColor: const Color(0xFF2ECC71),
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 100,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2ECC71)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(5),
                    bottomRight: Radius.circular(5),
                  ),
                ),
              ),
              const Positioned(
                bottom: -40,
                left: 10,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Color(0xFF2ECC71)),
                ),
              ),
              Positioned(
                left: 120,
                bottom: -28,
                child: Consumer(
                  builder: (context, ref, _) {
                    final user = ref.watch(userProvider);
                    final displayName = (user?.name.isNotEmpty ?? false)
                        ? user!.name
                        : "Pico Care User";
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
                            color: Colors.amber,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          displayEmail,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 70),
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
                        title: "Account Information",
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
                                            "Account Information",
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight:
                                                  FontWeight.w500, // lighter
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
                        title: "Order History",
                        icon: Icons.history,
                        onTap: () {},
                      ),
                      _buildMenuTile(
                        title: "Shipping Methods",
                        icon: Icons.local_shipping,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ShippingMethodPage(),
                            ),
                          );
                        },
                      ),
                      _buildMenuTile(
                        title: "Payment Methods",
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
                        title: "Payment Information",
                        icon: Icons.credit_card,
                        onTap: () {},
                      ),
                      _buildMenuTile(
                        title: "Settings",
                        icon: Icons.settings,
                        onTap: () {},
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
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2ECC71),
                                    Color(0xFF27AE60),
                                  ],
                                ),
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
                                          fontSize: 15,
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
    );
  }

  Widget _buildMenuTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: const Color(0xFF2ECC71)),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade800,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
    );
  }
}
