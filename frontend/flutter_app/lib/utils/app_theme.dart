import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_colors.dart';

class AppTheme {
  static const TextStyle _baseTextStyle = TextStyle(
    fontFamily: 'Roboto',
    color: AppColors.surfaceColor,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      // --- Core Color Scheme ---
      brightness: Brightness.light,
      primaryColor: AppColors.primaryColor,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryColor,
        secondary: AppColors.secondaryColor,
        error: AppColors.danger,
        surface: AppColors.surfaceColor,
        onPrimary: AppColors.surfaceColor,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.backgroundColor,

      // --- Typography Theme ---
      fontFamily: _baseTextStyle.fontFamily,
      textTheme: TextTheme(
        headlineLarge: _baseTextStyle.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: _baseTextStyle.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: _baseTextStyle.copyWith(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        bodyMedium: _baseTextStyle.copyWith(
          fontSize: 14,
          color: AppColors.textPrimary,
        ),
        labelLarge: _baseTextStyle.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),

      // --- Widget Styling ---

      // 1. Elevated Button (Primary Button)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.surfaceColor,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          textStyle: _baseTextStyle.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          elevation: 0,
        ),
      ),

      // 2. Text Button (Link/Outline Button)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryColor,
          textStyle: _baseTextStyle.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),

      // 3. Card Styling (Product Cards, etc.)
      cardTheme: const CardThemeData(
        color: AppColors.surfaceColor,
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),

      // 4. Input Decoration (Text Fields)
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: _baseTextStyle.copyWith(color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(
            color: AppColors.primaryColor,
            width: 2.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: AppColors.dividerColor),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        fillColor: AppColors.surfaceColor,
        filled: true,
      ),

      // 5. AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surfaceColor,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        shadowColor: AppColors.dividerColor,
        titleTextStyle: _baseTextStyle.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
