import 'package:flutter/material.dart';

class AppTheme {
  // Dark mode colors based on the premium UI screenshot reference
  static const Color primaryColor = Color(
    0xFFE50914,
  ); // A cinematic accent color (e.g. Netflix Red)
  static const Color primaryDark = Color(0xFFB81D24);
  static const Color secondaryColor = Color(0xFFF0F0F0);
  static const Color backgroundColor = Color(
    0xFF000000,
  ); // Deep black background
  static const Color surfaceColor = Color(0xFF1C1C1E); // Elevated dark gray
  static const Color surfaceLightColor = Color(
    0xFF2C2C2E,
  ); // Lighter gray for highlights
  static const Color errorColor = Color(0xFFCF6679);

  static const Color textPrimaryColor = Color(0xFFFFFFFF); // White text
  static const Color textSecondaryColor = Color(0xFFAAAAAA); // Light gray text
  static const Color textTertiaryColor = Color(
    0xFF757575,
  ); // Darker gray for less important info

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      cardTheme: const CardThemeData(
        color: surfaceColor,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: textPrimaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundColor,
        selectedItemColor: textPrimaryColor,
        unselectedItemColor: textSecondaryColor,
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        error: errorColor,
        surface: surfaceColor,
        onSurface: textPrimaryColor,
        onPrimary: Colors.white,
      ),
      iconTheme: const IconThemeData(color: textPrimaryColor),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: textPrimaryColor),
        bodyMedium: TextStyle(color: textSecondaryColor),
        titleLarge: TextStyle(
          color: textPrimaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: textPrimaryColor,
          foregroundColor: backgroundColor, // Dark text on light button
          elevation: 0,
        ),
      ),
    );
  }
}
