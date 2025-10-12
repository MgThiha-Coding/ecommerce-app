import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
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
      return Card(
        elevation: 0.3,
        shape: RoundedRectangleBorder( 
           borderRadius: BorderRadius.circular(9.0)
        ),
        child: Container(
          width: 80,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: AppColors.categoryCardBackground,
            borderRadius: BorderRadius.circular(9.0),
          ),
          child: Center(
            child: Text(
              categoryName,
              style: GoogleFonts.poppins(
                color: AppColors.categoryCardText,
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
