import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';

class SectionHeader extends StatelessWidget {
  final String header;
  final VoidCallback onTap;
  const SectionHeader({super.key,required this.header,required this.onTap});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          header,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: responsive.value(mobile: 10, tablet: 13, desktop:15),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'See All',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: responsive.value(mobile: 10, tablet: 13, desktop: 15),
            ),
          ),
        ),
      ],
    );
  }
}
