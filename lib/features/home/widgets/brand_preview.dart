import 'package:flutter/material.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/brands/model/brand_list_response.dart';

Widget brandPreview(BuildContext context, List<BrandDataModel?> brandList) {
  return ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: brandList.length,
    itemBuilder: (context, index) {
      final brandName = brandList[index]?.name ?? '';
      return Card(
        elevation: 0.4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9.0),
        ),
        child: Container(
          width: 100,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(9.0),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              brandName,
              style: TextStyle(
                fontFamily: "Poppins",
                fontSize: Responsive(context).caption,
                color: AppColors.textSecondary
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
