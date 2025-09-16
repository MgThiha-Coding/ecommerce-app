import 'package:flutter/material.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';
import 'package:shimmer/shimmer.dart';

class ProductSliderLoadingWidget extends StatelessWidget {
  const ProductSliderLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = Responsive(context);
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: responsive.value(mobile: 130, tablet: 140, desktop: 210),
          width: double.infinity,
          color: Colors.grey.shade300,
        ),
      ),
    );
  }
}