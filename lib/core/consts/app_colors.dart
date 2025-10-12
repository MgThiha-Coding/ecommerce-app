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
