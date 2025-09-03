import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HorizontalLineLoading extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  const HorizontalLineLoading({
    super.key,
    this.width = double.infinity,
    this.height = 8,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.blue.shade300,
      highlightColor: Colors.white,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.blue.shade300,
          borderRadius: borderRadius ?? BorderRadius.circular(4),
        ),
      ),
    );
  }
}
