/*
import 'package:flutter/material.dart';

class AppColors {
  // Background ( Lineaar Gradient )
  static const backgroundGradientStart = Color(0xFF1F3B4D);
  static const backgroundGradientEnd = Color(0xFF2C5364);

  // --- Banner / Home Page
  static const bannerTextPrimary = Color(0xFFFFFFFF);
  static const bannerTextSecondary = Color(0xFFB0C4DE);

  // --- Section Header Text Colors
  static const sectionHeaderText = Color(0xFF3E5060);

  // --- AppBar Text
  static const appBarWelcomeText = Colors.amber;
  static const appBarEmailText = Colors.white;

  // --- Glass Card
  static const glassCardBackground = Colors.white;

  // Brand Preview ( item background color & text color ) - homepage
  static const brandCardBackground = Color(0x80FFFFFF);
  static const brandCardText = Colors.black;

  // Category Preview ( item background color & text color ) - homepage
  static const categoryCardBackground = Color(0x80FFFFFF);
  static const categoryCardText = Colors.black;

  // Prodduct Preview item background color
  static const productPreviewBackground = Colors.white;

  // search widget
  // --- Search Widget ---
  static const searchFill = Colors.white; // Background of the TextField
  static const searchText = Color(0xFF000000); // Typed text
  static const searchHint = Color(0xFF888888); // Hint text
  static const searchIcon = Color(0xFFB0C4DE); // Search icon color
  static const searchBorder = Color(0xFFCCCCCC); // Border color
  static const searchBorderFocused = Color(
    0xFF3DDC97,
  ); // Focused border (accent)

  // Empty state / Shimmer / Fallbacks
  static const emptyStateIcon = Color(0xFF6E6E6E);
  static const emptyStateText = Color(0xFF6E6E6E);
  static const shimmerBase = Color(0xFFDADADA);
  static const shimmerHighlight = Color(0xFFF5F5F5);
  static const sectionHeaderLabel = Color(0xFF3E5060);
}
*/

import 'package:flutter/material.dart';

class AppColors {
  // Theme control
  static bool _isDark = true;

  static void switchTheme(bool isDark) {
    _isDark = isDark;
  }

  static bool get isDark => _isDark;

  // === Background (Linear Gradient) ===
  static Color get backgroundGradientStart =>
      _isDark ? const Color(0xFF1F3B4D) : const Color(0xFFF0F0F0);
  static Color get backgroundGradientEnd =>
      _isDark ? const Color(0xFF2C5364) : const Color(0xFFE0E0E0);

  // === Banner / Home Page ===
  static Color get bannerTextPrimary =>
      _isDark ? const Color(0xFFFFFFFF) : Colors.black;
  static Color get bannerTextSecondary =>
      _isDark ? const Color(0xFFB0C4DE) : Colors.grey;

  // === Section Header Text Colors ===
  static Color get sectionHeaderText =>
      _isDark ? const Color(0xFF3E5060) : Colors.black87;

  // === AppBar Text ===
  static Color get appBarWelcomeText =>
      _isDark ? Colors.amber : Colors.blueAccent;
  static Color get appBarEmailText => _isDark ? Colors.white : Colors.black;

  // === Glass Card ===
  static Color get glassCardBackground =>
      _isDark ? Colors.white : const Color(0xFFF5F5F5);

  // === Brand / Category Cards ===
  static Color get brandCardBackground =>
      _isDark ? const Color(0x80FFFFFF) : const Color(0xFFE0E0E0);
  static Color get brandCardText => _isDark ? Colors.black : Colors.black87;

  static Color get categoryCardBackground =>
      _isDark ? const Color(0x80FFFFFF) : const Color(0xFFE0E0E0);
  static Color get categoryCardText => _isDark ? Colors.black : Colors.black87;

  // === Product Preview ===
  static Color get productPreviewBackground =>
      _isDark ? Colors.white : const Color(0xFFF5F5F5);

  static Color get selectedColor =>
      _isDark ? const Color(0xFF1F3B4D) : const Color(0xFF1F3B4D);
  static Color get unselectedColor =>
      _isDark ? const Color(0xFF2C5364) : const Color(0xFF2C5364);
  static Color get buttonColor =>
      _isDark ? const Color(0xFF1F3B4D) :  const Color(0xFF1F3B4D);
  static Color get navBackgroundColor =>
      _isDark ? const Color(0xFFF0F0F0) : const Color(0xFFF0F0F0);

  // === Search Widget ===
  static Color get searchFill => _isDark ? Colors.white : Colors.white;
  static Color get searchText =>
      _isDark ? const Color(0xFF000000) : Colors.black;
  static Color get searchHint =>
      _isDark ? const Color(0xFF888888) : Colors.grey;
  static Color get searchIcon =>
      _isDark ? const Color(0xFFB0C4DE) : Colors.grey;
  static Color get searchBorder =>
      _isDark ? const Color(0xFFCCCCCC) : Colors.grey[300]!;
  static Color get searchBorderFocused =>
      _isDark ? const Color(0xFF3DDC97) : Colors.blueAccent;

  // === Empty State / Shimmer ===
  static Color get emptyStateIcon =>
      _isDark ? const Color(0xFF6E6E6E) : Colors.grey;
  static Color get emptyStateText =>
      _isDark ? const Color(0xFF6E6E6E) : Colors.grey;
  static Color get shimmerBase =>
      _isDark ? const Color(0xFFDADADA) : Colors.grey[300]!;
  static Color get shimmerHighlight =>
      _isDark ? const Color(0xFFF5F5F5) : Colors.white;
  static Color get sectionHeaderLabel =>
      _isDark ? const Color(0xFF3E5060) : Colors.black87;
}
