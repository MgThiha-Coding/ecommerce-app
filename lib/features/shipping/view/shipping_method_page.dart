import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/features/payment/view/payment_method_page.dart';

class ShippingMethodPage extends StatelessWidget {
  const ShippingMethodPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data
    final shippingList = [
      {'name': 'Express Delivery', 'channel': 'Air', 'amount': 2000},
      {'name': 'Standard Delivery', 'channel': 'Road', 'amount': 1000},
      {'name': 'Economy Delivery', 'channel': 'Rail', 'amount': 500},
    ];

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0,
          centerTitle: true,
          backgroundColor: Color(0xFFFFC107),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back),
          ),
          title: Text('Shipping', style: GoogleFonts.poppins(fontSize: 14)),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFC107), Color(0xFFFFE082), Color(0xFFA5D6A7)],
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
    );
  }
}
