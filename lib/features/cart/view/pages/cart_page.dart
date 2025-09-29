import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/images/app_image.dart';
import 'package:picoshop_theme2/features/cart/view/widgets/cart_app_bar.dart';
import 'package:picoshop_theme2/features/shipping/view/shipping_method_page.dart';

class CartPage extends ConsumerStatefulWidget {
  const CartPage({super.key});

  @override
  ConsumerState<CartPage> createState() => _CartPageState();
}

class _CartPageState extends ConsumerState<CartPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue.shade400,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            height: double.infinity,
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
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                children: [
                  CartAppBar(),
                  Expanded(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        child: ListView.builder(
                          itemCount: 20,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(8),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    AppImage.emptyContainer,
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 50,
                                  ),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Orange',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Fruits',
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    Text(
                                      '5\$',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Expanded(
                                      child: IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: BoxConstraints(),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            onPressed: () {},
                                            icon: Icon(Icons.remove, size: 18),
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints(),
                                          ),
                                          Text(
                                            '4',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                            ),
                                          ),
                                          IconButton(
                                            onPressed: () {},
                                            icon: Icon(Icons.add, size: 18),
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '1500\$',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Discount',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                            Text(
                              '0\$',
                              style: GoogleFonts.poppins(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 45,
                    margin: const EdgeInsets.all(6),
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=> ShippingMethodPage()));
                      },
                      child: Text(
                        'Shipping',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
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
    );
  }
}
