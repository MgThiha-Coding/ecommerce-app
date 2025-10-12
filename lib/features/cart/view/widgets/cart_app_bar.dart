import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';

class CartAppBar extends StatelessWidget {
  const CartAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return Container(
      margin: const EdgeInsets.only(top: 18, bottom: 8),
      height: responsive.value(mobile: 40, tablet: 50, desktop: 70),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),
          Text(
            'Cart',
            style: GoogleFonts.poppins(
              fontSize: responsive.value(mobile: 15, tablet: 20, desktop: 25),
              color: Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
          IconButton(
            style: IconButton.styleFrom(
              // ignore: deprecated_member_use
              backgroundColor: Colors.grey.withOpacity(0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {},
            icon: Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: responsive.value(mobile: 15, tablet: 20, desktop: 30),
            ),
          ),
        ],
      ),
    );
  }
}
