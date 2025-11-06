import 'package:flutter/material.dart';
import 'package:picoshop_theme2/core/consts/app_colors.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/category/model/categories_list_response.dart';
import 'package:picoshop_theme2/features/category/view/pages/category_detail_page.dart';

ListView categoryListView(
  BuildContext context,
  List<CategoryDataModel?> categories,
  bool isNoMore,
  ScrollController scrollController,
  Responsive responsive,
) {
  return ListView.separated(
    controller: scrollController,
    itemCount: categories.length,
    separatorBuilder: (_, __) => SizedBox(height: responsive.body),
    itemBuilder: (context, index) {
      final categoryName = categories[index]?.name ?? '';
      final description = categories[index]?.description ?? '';
      final categoryId = categories[index]?.id;
      return Card(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
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
                      categoryName,
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
                      builder: (context) =>
                          CategoryDetailPage(categoryId: categoryId!),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(responsive.body * 2),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.body * 2,
                    vertical: responsive.body * 0.8,
                  ),
                ),
                child: Text(
                  'See Detail',
                  style: TextStyle(
                    fontSize: responsive.caption,
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
