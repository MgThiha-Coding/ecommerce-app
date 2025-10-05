import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/features/category/model/categories_list_response.dart';

Widget categoryPreview(
  BuildContext context,
  List<CategoryDataModel?> categoryList,
) {
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: categoryList.length,
    itemBuilder: (context, index) {
      final categoryName = categoryList[index]?.name ?? '';
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Container(
          width: 80,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              categoryName,
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
  );
}
