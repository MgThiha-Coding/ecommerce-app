import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/features/brands/model/brand_list_response.dart';

Widget brandPreview(BuildContext context, List<BrandDataModel?> brandList) {
  return SizedBox(
    height: 70,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: brandList.length,
      itemBuilder: (context, index) {
        final brandName = brandList[index]?.name ?? '';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Container(
            height: 60,
            width: 60,
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
                bottomLeft: Radius.circular(6),
              ),
            ),
            child: Center(
              child: Text(
                brandName,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ),
        );
      },
    ),
  );
}
