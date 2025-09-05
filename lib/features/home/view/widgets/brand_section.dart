import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:picoshop_theme2/features/brands/viewmodel/brand_notifier.dart';
import 'package:shimmer/shimmer.dart';

class BrandSection extends ConsumerStatefulWidget {
  const BrandSection({super.key});

  @override
  ConsumerState<BrandSection> createState() => _BrandListWidgetState();
}

class _BrandListWidgetState extends ConsumerState<BrandSection> {
  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    final brandListAsync = ref.watch(brandListNotifierProvider);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: responsive.value(mobile: 80, tablet: 120, desktop: 120),
        padding: EdgeInsets.all(2),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: brandListAsync.when(
          data: (brandListData) {
            final brandList = brandListData?.data.data ?? [];
            if (brandList.isEmpty) {
              return SizedBox.shrink();
            }
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: brandList.length,
              itemBuilder: (context, index) {
                final brandName = brandList[index].name;

                return Container(
                  margin: EdgeInsets.all(3),
                  height: responsive.value(
                    mobile: 70,
                    tablet: 110,
                    desktop: 110,
                  ),
                  width: responsive.value(mobile: 70, tablet: 90, desktop: 110),
                  child: Card(
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Text(
                              brandName,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: responsive.value(
                                  mobile: 10,
                                  tablet: 12,
                                  desktop: 15,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 3,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomLeft: Radius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Brands',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: responsive.value(
                                  mobile: 9,
                                  tablet: 10,
                                  desktop: 15,
                                ),
                                fontWeight: FontWeight.w400,
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
          error: (error, _) => const BrandListLoading(),
          loading: () => const BrandListLoading(),
        ),
      ),
    );
  }
}

class BrandListLoading extends StatelessWidget {
  const BrandListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: 20,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.all(3),
          height: responsive.value(mobile: 90, tablet: 90, desktop: 110),
          width: responsive.value(mobile: 90, tablet: 90, desktop: 110),
          child: Card(
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade400,
                      highlightColor: Colors.grey.shade100,
                      child: Text(
                        'Brand Name',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade400,
                          fontWeight: FontWeight.w400,
                          fontSize: responsive.value(
                            mobile: 10,
                            tablet: 13,
                            desktop: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Shimmer.fromColors(
                    baseColor: Colors.red,
                    highlightColor: Colors.red.shade400,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Brands',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: responsive.value(
                            mobile: 5,
                            tablet: 10,
                            desktop: 15,
                          ),
                          fontWeight: FontWeight.w400,
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
  }
}
