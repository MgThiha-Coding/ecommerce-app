import 'package:flutter/material.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/brands/model/brand_list_response.dart';
import 'package:picoshop_theme2/features/brands/view/pages/brand_detail_page.dart';

ListView brandListView(
  BuildContext context,
  List<BrandDataModel?> brands,
  bool isNoMore,
  ScrollController scrollController,
  Responsive responsive,
) {
  return ListView.separated(
    controller: scrollController,
    itemCount: brands.length,
    separatorBuilder: (_, __) => SizedBox(height: responsive.body),
    itemBuilder: (context, index) {
      final brandName = brands[index]?.name ?? '';
      final description = brands[index]?.description ?? '';
      final brandId = brands[index]?.id;
      return Card(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(responsive.body),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: responsive.body,
            vertical: responsive.body * 1.2,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      brandName,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: responsive.subHeading,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: responsive.caption),
                    Text(
                      description.isEmpty
                          ? "No description available"
                          : description,
                      style: TextStyle(
                        fontFamily: "Poppins",
                        fontSize: responsive.caption,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: responsive.body),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BrandDetailPage(brandId: brandId!),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.body * 1),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.body * 2,
                    vertical: responsive.body * 0.8,
                  ),
                ),
                child: Text(
                  'See Detail',
                  style: TextStyle(
                    fontSize: responsive.caption * 1,
                    color: AppColors.background,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
