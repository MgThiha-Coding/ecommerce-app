import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/features/payment/view/payment_method_page.dart';
import 'package:picoshop_theme2/features/shipping/viewmodel/shipping_method_notifier.dart';

class ShippingMethodPage extends ConsumerStatefulWidget {
  const ShippingMethodPage({super.key});

  @override
  ConsumerState<ShippingMethodPage> createState() => _ShippingMethodPageState();
}

class _ShippingMethodPageState extends ConsumerState<ShippingMethodPage> {
  @override
  void initState() {
    super.initState();
    // Fetch shipping methods when the page loads
    Future.microtask(() {
      ref.read(shippingMethodNotifierProvider.notifier).getShippingMethod();
    });
  }

  @override
  Widget build(BuildContext context) {
    final shippingAsync = ref.watch(shippingMethodNotifierProvider);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade600,
              Colors.blue.shade200,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const AppBarWidget(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: shippingAsync.when(
                    data: (shippingMethodData) {
                      final shippingList = shippingMethodData?.data ?? [];
                      if (shippingList.isEmpty) {
                        return Center(
                          child: Text(
                            "No shipping methods available",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: shippingList.length,
                        itemBuilder: (context, index) {
                          final method = shippingList[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 4,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Icon(
                                  Icons.local_shipping,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              title: Text(
                                method.name,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.grey.shade900,
                                ),
                              ),
                              subtitle: Text(
                                "${method.deliveryChannelName} • ${method.amount} Ks",
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey.shade500,
                              ),
                              onTap: () {
                                // Navigate to PaymentMethodPage
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentMethodPage(
                                      shippingMethod: method.name,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: SpinKitCircle(size: 40, color: Colors.white),
                    ),
                    error: (error, _) => Center(
                      child: Text(
                        error.toString(),
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AppBarWidget extends StatelessWidget {
  const AppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    double responsiveTitle() {
      if (screenWidth < 600) return 18;
      if (screenWidth <= 1100) return 20;
      return 25;
    }

    double responsiveHeight() {
      if (screenWidth < 600) return 60;
      if (screenWidth <= 1100) return 70;
      return 80;
    }

    return Container(
      height: responsiveHeight(),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: responsiveTitle(),
            ),
          ),
          Text(
            'Delivery',
            style: GoogleFonts.poppins(
              fontSize: responsiveTitle(),
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 48), // keep alignment balance
        ],
      ),
    );
  }
}
