/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/features/payment/viewmodel/payment_notifier.dart';

class PaymentMethodPage extends ConsumerStatefulWidget {
  final String shippingMethod;
  final int addressId;
  const PaymentMethodPage(
    this.addressId, {
    super.key,
    required this.shippingMethod,
  });

  @override
  ConsumerState<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends ConsumerState<PaymentMethodPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(paymentMethodNotifierProvider.notifier).getPaymentMethod();
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentAsync = ref.watch(paymentMethodNotifierProvider);

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
              const AppBarWidget(title: "Payment"),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Container(
                  height: 40,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      widget.shippingMethod,
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: paymentAsync.when(
                    data: (paymentData) {
                      final paymentList = paymentData?.data ?? [];
                      if (paymentList.isEmpty) {
                        return Center(
                          child: Text(
                            "No payment methods available",
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: paymentList.length,
                        itemBuilder: (context, index) {
                          final method = paymentList[index];
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
                                  Icons.payment,
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

                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: Colors.grey.shade500,
                              ),
                              onTap: () {
                               
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

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {},
                    child: Text(
                      'Checkout',
                      style: GoogleFonts.poppins(color: Colors.white),
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
  final String title;
  const AppBarWidget({super.key, required this.title});

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
            title,
            style: GoogleFonts.poppins(
              fontSize: responsiveTitle(),
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 48), // balance
        ],
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/features/create_address/view/pages/create_address_page.dart';

class PaymentMethodPage extends ConsumerStatefulWidget {
  final String shippingMethod;
  const PaymentMethodPage({super.key, required this.shippingMethod});

  @override
  ConsumerState<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends ConsumerState<PaymentMethodPage> {
  @override
  Widget build(BuildContext context) {
    // Dummy payment methods
    final paymentList = [
      {'name': 'Credit Card'},
      {'name': 'Cash on Delivery'},
      {'name': 'Mobile Wallet'},
    ];

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
              const DemoAppBar(title: "Payment"),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ListView.builder(
                    itemCount: paymentList.length,
                    itemBuilder: (context, index) {
                      final method = paymentList[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
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
                              Icons.payment,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          title: Text(
                            method['name']!,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.grey.shade900,
                            ),
                          ),
                          trailing: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                          onTap: () {
                            // Demo action: show snackbar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Selected ${method['name']}'),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade800,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateAddressPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Checkout',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
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

class DemoAppBar extends StatelessWidget {
  final String title;
  const DemoAppBar({super.key, required this.title});

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
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: responsiveTitle(),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: responsiveTitle(),
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 48), // spacing
        ],
      ),
    );
  }
}
