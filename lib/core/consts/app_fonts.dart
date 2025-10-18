import 'package:flutter/material.dart';
import 'package:picoshop_theme2/core/responsive/responsive.dart';

class AppFonts {
  final BuildContext context;
  late final Responsive _responsive;

  AppFonts(this.context) {
    _responsive = Responsive(context);
  }

  double get title => _responsive.value(mobile: 17, tablet: 24, desktop: 28);

  double get subTitle => _responsive.value(mobile: 16, tablet: 18, desktop: 20);

  double get body => _responsive.value(mobile: 14, tablet: 16, desktop: 18);

  double get caption => _responsive.value(mobile: 12, tablet: 14, desktop: 16);

  double get small => _responsive.value(mobile: 10, tablet: 12, desktop: 14);
}
