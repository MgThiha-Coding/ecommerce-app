import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    Future.microtask(() {
      ref.read(shippingMethodNotifierProvider.notifier).getShippingMethod();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dummy data
    final shippingList = [
      {'name': 'Express Delivery', 'channel': 'Air', 'amount': 2000},
      {'name': 'Standard Delivery', 'channel': 'Road', 'amount': 1000},
      {'name': 'Economy Delivery', 'channel': 'Rail', 'amount': 500},
    ];

    return Container(
      color: Color(0xFF2ECC71),
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            scrolledUnderElevation: 0,
            centerTitle: true,
            backgroundColor: Color(0xFF2ECC71),
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.arrow_back),
            ),
            title: Text(
              'Shipping',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
            ),
          ),
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF2ECC71), Color(0xFF27AE60)],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: ListView.builder(
                      itemCount: shippingList.length,
                      itemBuilder: (context, index) {
                        final method = shippingList[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Icon(
                                Icons.local_shipping,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            title: Text(
                              '${method['name']}',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: Colors.grey.shade900,
                              ),
                            ),
                            subtitle: Text(
                              "${method['channel']} • ${method['amount']} Ks",
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      PaymentMethodPage(shippingMethod: '1'),
                                ),
                              );
                            },
                          ),
                        );
                      },
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
