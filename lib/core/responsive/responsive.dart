import 'package:flutter/material.dart';

class Responsive {
  final BuildContext context;
  late double screenWidth;

  Responsive(this.context) {
    screenWidth = MediaQuery.of(context).size.width;
  }

  // Device type checks
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth <= 1100;
  bool get isDesktop => screenWidth > 1100;

  // General values
  double value({
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }

  // Text sizes
  double get heading => value(mobile: 18, tablet: 22, desktop: 26);
  double get subHeading => value(mobile: 14, tablet: 14, desktop: 18);
  double get body => value(mobile: 12, tablet: 12, desktop: 16);
  double get caption => value(mobile: 10, tablet: 10, desktop: 14);

  // Padding/margin
  double get paddingSmall => value(mobile: 8, tablet: 12, desktop: 16);
  double get paddingMedium => value(mobile: 12, tablet: 16, desktop: 24);
  double get paddingLarge => value(mobile: 16, tablet: 24, desktop: 32);

  // Icon sizes
  double get iconSmall => value(mobile: 16, tablet: 20, desktop: 24);
  double get iconMedium => value(mobile: 24, tablet: 28, desktop: 32);
  double get iconLarge => value(mobile: 32, tablet: 36, desktop: 40);

  // get started button onboarding page
  double get buttonHeight => value(mobile: 33, tablet: 28, desktop: 30);
  double get buttonWidth => value(mobile: 130, tablet: 100, desktop: 30);

  // nav label
  double get navLabel => value(mobile: 10, tablet: 10, desktop: 14);
   double get navIcon => value(mobile: 10, tablet: 18, desktop: 30);

  // AuthPage
  double get authButtonHeight => value(mobile: 50, tablet: 40, desktop: 30);


  double get authHorizontalPadding {
    if (screenWidth >= 1400) return 600;
    if (screenWidth >= 1024) return 100;
    if (screenWidth >= 768) return 100;
    return 15;
  }
}
