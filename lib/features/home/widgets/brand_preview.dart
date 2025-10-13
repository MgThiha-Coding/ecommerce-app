import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/features/brands/model/brand_list_response.dart';

Widget brandPreview(BuildContext context, List<BrandDataModel?> brandList) {
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: brandList.length,
    itemBuilder: (context, index) {
      final brandName = brandList[index]?.name ?? '';
      return Card(
        elevation: 0.3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9.0),
        ),
        child: Container(
          width: 120,
          decoration: BoxDecoration(
            color: AppColors.brandCardBackground,
            borderRadius: BorderRadius.circular(9.0),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              brandName,
              style: GoogleFonts.poppins(
                color: AppColors.brandCardText,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ),
      );
    },
  );
}
