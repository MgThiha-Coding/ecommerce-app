import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/category/viewmodel/category_notifier.dart';
import 'package:shimmer/shimmer.dart';

class CategoriesListWidget extends ConsumerStatefulWidget {
  const CategoriesListWidget({super.key});

  @override
  ConsumerState<CategoriesListWidget> createState() =>
      _CategoriesListWidgetState();
}

class _CategoriesListWidgetState extends ConsumerState<CategoriesListWidget> {
  @override
  Widget build(BuildContext context) {
    final categoriesListAsync = ref.watch(categoriesListNotifierProvider);
    final responsive = Responsive(context);
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(12),
      ),
      child: Container(
        height: responsive.value(mobile: 130, tablet: 120, desktop: 130),
        width: double.infinity,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: categoriesListAsync.when(
          data: (categoryListData) {
            final categoryList = categoryListData?.data.data ?? [];
            if (categoryList.isEmpty) {
              return SizedBox.shrink();
            }
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: categoryList.length,
              itemBuilder: (context, index) {
                final categoryName = categoryList[index].name;
                return Card(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    height: responsive.value(
                      mobile: 100,
                      tablet: 110,
                      desktop: 120,
                    ),
                    width: responsive.value(
                      mobile: 110,
                      tablet: 120,
                      desktop: 130,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          categoryName,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: responsive.value(
                              mobile: 10,
                              tablet: 13,
                              desktop: 15,
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: SizedBox(
                            height: responsive.value(
                              mobile: 22,
                              tablet: 20,
                              desktop: 20,
                            ),
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade500,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 3,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'View',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: responsive.value(
                                    mobile: 9,
                                    tablet: 9,
                                    desktop: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          error: (error, _) {
            return CategoriesListLoading();
          },
          loading: () {
            return CategoriesListLoading();
          },
        ),
      ),
    );
  }
}

class CategoriesListLoading extends StatelessWidget {
  const CategoriesListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 20,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.all(3),
          height: responsive.value(mobile: 80, tablet: 110, desktop: 120),
          width: responsive.value(mobile: 90, tablet: 120, desktop: 130),
          child: Card(
            child: Container(
              padding: EdgeInsets.all(5),
              height: responsive.value(mobile: 80, tablet: 110, desktop: 120),
              width: responsive.value(mobile: 90, tablet: 120, desktop: 130),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Shimmered text
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade400,
                    highlightColor: Colors.grey.shade100,
                    child: Text(
                      'Category',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: GoogleFonts.poppins(
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w600,
                        fontSize: responsive.value(
                          mobile: 10,
                          tablet: 13,
                          desktop: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Shimmered button
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade400,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: responsive.value(
                          mobile: 15,
                          tablet: 20,
                          desktop: 20,
                        ),
                        width: responsive.value(
                          mobile: 35,
                          tablet: 45,
                          desktop: 50,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'View',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: responsive.value(
                              mobile: 8,
                              tablet: 9,
                              desktop: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
