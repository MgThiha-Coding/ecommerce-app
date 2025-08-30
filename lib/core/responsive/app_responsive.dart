import 'package:flutter/material.dart';

class AppResponsive extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;
  const AppResponsive({super.key, this.mobile, this.tablet, this.desktop});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return mobile!;
    } else if (screenWidth >= 600 && screenWidth < 1100) {
      return tablet!;
    } else {
      return desktop!;
    }
  }
}
