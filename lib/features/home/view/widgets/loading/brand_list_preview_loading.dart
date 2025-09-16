import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:shimmer/shimmer.dart';

class BrandListPreviewLoading extends StatelessWidget {
  const BrandListPreviewLoading({super.key});

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
