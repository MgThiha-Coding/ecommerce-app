import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color primary = Color(0xFF1F3B4D); // Dark blue-grey
  static const Color secondary = Color(0xFF2C5364); // Gradient complement
  static const Color accent = Color(0xFF3DDC97); // Cool green accent
  static const Color scaffoldBackground = Color(0xFFF4F7FA); // Light neutral
  static const Color cardBackground = Colors.white; // Glass card
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0C4DE); // Light steel blue
  static const Color sectionHeader = Color(0xFF3E5060); // Slightly deeper

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: scaffoldBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardColor: cardBackground,
    colorScheme: ColorScheme.fromSeed(seedColor: primary)
        .copyWith(secondary: accent, brightness: Brightness.light),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textPrimary),
      displayMedium: TextStyle(color: textPrimary),
      displaySmall: TextStyle(color: textPrimary),
      titleLarge: TextStyle(color: textSecondary),
      titleMedium: TextStyle(color: sectionHeader),
      bodyLarge: TextStyle(color: textSecondary),
      bodyMedium: TextStyle(color: sectionHeader),
      bodySmall: TextStyle(color: sectionHeader),
      labelLarge: TextStyle(color: accent),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: accent,
      textTheme: ButtonTextTheme.primary,
    ),
  );

  // Dark Theme
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primary,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      elevation: 0,
      iconTheme: IconThemeData(color: textPrimary),
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardColor: const Color(0xFF1E1E1E),
    colorScheme: ColorScheme.fromSeed(seedColor: primary, brightness: Brightness.dark)
        .copyWith(secondary: accent),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: textPrimary),
      displayMedium: TextStyle(color: textPrimary),
      displaySmall: TextStyle(color: textPrimary),
      titleLarge: TextStyle(color: textSecondary),
      titleMedium: TextStyle(color: sectionHeader),
      bodyLarge: TextStyle(color: textSecondary),
      bodyMedium: TextStyle(color: sectionHeader),
      bodySmall: TextStyle(color: sectionHeader),
      labelLarge: TextStyle(color: accent),
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: accent,
      textTheme: ButtonTextTheme.primary,
    ),
  );
}
