import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Widget SectionHeader(String title, VoidCallback onTap) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            color: Color(0xFF2ECC71),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            'See All',
            style: GoogleFonts.poppins(
              color: Color(0xFF2ECC71),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
