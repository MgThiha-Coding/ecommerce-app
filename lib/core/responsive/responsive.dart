import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;
  late double screenWidth;

  Responsive(this.context) {
    screenWidth = MediaQuery.of(context).size.width;
  }

  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth <= 1100;
  bool get isDesktop => screenWidth > 1100;

  double value({required double mobile, required double tablet, required double desktop}) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }
}
