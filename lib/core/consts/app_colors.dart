import 'package:flutter/material.dart';

class AppColors {
  // main primary and secondary color
  static const Color primary = Color(0xFF1565C0);
  static const Color secondary = Color(0xFF90CAF9);

  // bottomNavigationBar Colors
  static const Color unselctedNavColor = Color(0xFF535557);
  static const Color selectedNavColor = Color(0xFF1565C0);
  static const Color centerCartButtonColor = Colors.blueAccent;
  static const Color bottomNavBackgroundColor = Colors.white;

  // text primary and secondary color
  static const Color textPrimary = primary;
  static const Color textSecondary = Color(0xFF535557);

  // app main background color and card color
  static const Color background = Colors.white;
  // static const Color background = Color(0xFFFFF9E5); // Pale yellowish-white

  static const Color card = Colors.white;

  // search bar fill color
  static final Color searchBarFillColor = Colors.grey[200]!;

  // linear gradient color
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // price lable color
  static const Color priceLabelColor = Colors.red;
  static const Color brandLabelColor = Colors.blueGrey;

  // success & error color
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
}
