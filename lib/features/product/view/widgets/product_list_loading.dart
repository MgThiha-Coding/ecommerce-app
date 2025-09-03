
import 'package:flutter/material.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:shimmer/shimmer.dart';

class ProductListLoading extends StatelessWidget {
  const ProductListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);

    return GridView.builder(
      padding: EdgeInsets.zero,
      itemCount: 20,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: responsive.isMobile ? 2 : responsive.isTablet ? 5 : 6,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
        childAspectRatio: 110 / 130,
      ),
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Container(
            child: Stack(
              children: [
                Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(12),
                              topRight: Radius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Shimmer.fromColors(
                          baseColor: Colors.grey.shade300,
                          highlightColor: Colors.grey.shade100,
                          child: Container(
                            height: responsive.value(mobile: 10, tablet: 13, desktop: 15),
                            width: double.infinity,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Shimmer.fromColors(
                    baseColor: Colors.green.shade700,
                    highlightColor: Colors.green.shade400,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Product',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: responsive.value(mobile: 9, tablet: 10, desktop: 15),
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
