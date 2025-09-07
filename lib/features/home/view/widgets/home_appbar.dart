import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    
    final responsive = Responsive(context);

    return Container(  
      margin: EdgeInsets.only(top: 18),
      height: responsive.value(mobile: 40, tablet: 50, desktop: 70),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          responsive.isMobile?
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
              Icons.menu,
              color: Colors.white,
              size: responsive.value(mobile: 15, tablet: 20, desktop: 30),
            ),
          ): SizedBox( width: 48,),
          Text(
            'Pico Care',
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
              Icons.notifications,
              color: Colors.white,
              size: responsive.value(mobile: 15, tablet: 20, desktop: 30),
            ),
          ),
        ],
      ),
    );
  }
}
