import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/product/view/pages/product_search_page.dart';


class ProductAppBar extends ConsumerWidget {
  const ProductAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  

    final responsive = Responsive(context);

    return Container(
      margin: const EdgeInsets.only(top: 9),
      height: responsive.value(mobile: 40, tablet: 50, desktop: 70),

      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),
          Text(
            'Products',
            style: GoogleFonts.poppins(
              fontSize: responsive.value(mobile: 19, tablet: 23, desktop: 25),
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
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> ProductSearchPage(initialQuery: '')));
            },
            icon: Icon(
              Icons.search,
              color: Colors.white,
              size: responsive.value(mobile: 16, tablet: 20, desktop: 30),
            ),
          )
        ],
      ),
    );
  }
}
