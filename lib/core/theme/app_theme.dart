import 'package:flutter/material.dart';

class AppTheme {
  // Mitsui Brand Colors
  static const Color mitsuiBlue = Color(0xFF0066CC); // Primary blue
  static const Color mitsuiDarkBlue =
      Color(0xFF004499); // Dark blue for buttons
  static const Color mitsuiLightBlue =
      Color(0xFFE6F2FF); // Light blue background
  static const Color mitsuiGrey =
      Color(0xFFF5F5F5); // Light grey for input fields
  static const Color mitsuiTextGrey = Color(0xFF666666); // Text grey

  /// Minimum readable body size (App Store Guideline 4 / iPad readability).
  static const double minFontSize = 14;

  /// Recommended Apple HIG minimum tap target.
  static const double minTapTarget = 44;

  static const Size minInteractiveSize = Size(minTapTarget, minTapTarget);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: mitsuiBlue,
        onPrimary: Colors.white,
        secondary: mitsuiDarkBlue,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: Colors.black87,
        background: mitsuiLightBlue,
        onBackground: Colors.black87,
        error: Colors.red,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor:
          mitsuiBlue, // Will be overridden by gradient in screens
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: mitsuiBlue,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      // Card styling is handled through colorScheme.surface in Material 3
      // Use Card widget with custom decoration where specific styling is needed
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: mitsuiGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: mitsuiBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: mitsuiTextGrey, fontSize: 16),
        labelStyle: const TextStyle(color: mitsuiTextGrey, fontSize: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: mitsuiDarkBlue,
          foregroundColor: Colors.white,
          minimumSize: minInteractiveSize,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: minInteractiveSize,
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: minInteractiveSize,
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: minInteractiveSize,
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      chipTheme: const ChipThemeData(
        labelPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        labelStyle: TextStyle(fontSize: 16),
      ),
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: 12,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: Colors.black87,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        labelSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: mitsuiBlue,
        onPrimary: Colors.white,
        secondary: mitsuiDarkBlue,
        onSecondary: Colors.white,
        surface: Color(0xFF1E1E1E),
        onSurface: Colors.white,
        error: Colors.red,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: mitsuiDarkBlue,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: mitsuiDarkBlue,
        foregroundColor: Colors.white,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      // Card styling is handled through colorScheme.surface in Material 3
      // Use Card widget with custom decoration where specific styling is needed
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2E2E2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: mitsuiBlue, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 16),
        labelStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: mitsuiDarkBlue,
          foregroundColor: Colors.white,
          minimumSize: minInteractiveSize,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: minInteractiveSize,
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: minInteractiveSize,
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: minInteractiveSize,
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      chipTheme: const ChipThemeData(
        labelPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        labelStyle: TextStyle(fontSize: 16),
      ),
      listTileTheme: const ListTileThemeData(
        minVerticalPadding: 12,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        titleSmall: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Colors.white,
        ),
        bodySmall: TextStyle(
          fontSize: 14,
          color: Colors.white70,
        ),
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
        labelSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}
