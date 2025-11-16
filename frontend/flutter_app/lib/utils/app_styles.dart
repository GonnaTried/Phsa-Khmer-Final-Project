import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_constants.dart';

class AppStyles {
  // --- CUSTOM TEXT STYLES ---

  // 1. Primary Heading
  static const TextStyle headingPrimary = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w800, // Extra bold
    color: AppColors.textPrimary,
  );

  // 2. Product Title Style
  static const TextStyle productTitle = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // 3. Price Styles

  static const TextStyle priceRegular = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // Sale/Discounted price style
  static const TextStyle priceSale = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    color: AppColors.danger,
  );

  // Strikethrough style for the original price
  static TextStyle priceOriginal = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    decoration: TextDecoration.lineThrough,
  );

  // 4. Badge/Tag Styles
  static const TextStyle badgeTextStyle = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.bold,
    color: AppColors.surfaceColor,
  );

  // 5. Star Rating Text
  static const TextStyle ratingTextStyle = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  // --- BOX SHADOWS ---

  // 1. Default Card Shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.05),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  // 2. Elevated Shadow
  static const List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.1),
      blurRadius: 10,
      offset: Offset(0, 4),
    ),
  ];

  // --- GRADIENTS ---

  // Primary Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primaryColor, AppColors.primaryDark],
  );

  // Secondary Gradient
  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.secondaryColor, AppColors.secondaryLight],
  );
}
