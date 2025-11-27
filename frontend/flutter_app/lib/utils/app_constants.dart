import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_colors.dart';

class AppConstants {
  // --- APPLICATION TEXT & METADATA ---
  static const String kAppName = 'Phsa Khmer';
  static const String kAppVersion = '1.0.0';

  // --- API / SERVICE CONFIGURATION ---
  static const String kBaseUrl = 'https://api.yourecomsite.com/v1/';
  static const String kBasePaywayUrl =
      'https://checkout-sandbox.payway.com.kh/';
  static const String kApiHostSpring =
      'https://which-responsibility-rover-vocational.trycloudflare.com';
  static const String kApiHostDjango =
      'https://tinderlike-bullheadedly-lillianna.ngrok-free.dev';

  // --- ROUTE NAMES ---
  static const String routeHome = '/';
  static const String routeProfile = '/profile';
  static const String routeLogin = '/login';

  // --- PADDING & SPACING (The core of consistent UI) ---

  // Base padding size. All other spacings are often derived from this.
  static const double kDefaultPadding = 16.0;

  // Vertical and Horizontal Spacing definitions
  static const double kSpacingSmall = 8.0;
  static const double kSpacingMedium = 16.0;
  static const double kSpacingLarge = 24.0;
  static const double kSpacingExtraLarge = 32.0;

  // Consistent radius for borders
  static const double kBorderRadius = 12.0;
  static const double kSmallBorderRadius = 8.0;

  // Consistent elevation for shadows
  static const double kDefaultElevation = 4.0;
  static const double kSearchWidth = 20.0;

  // --- UI DIMENSIONS ---

  // Standard height for primary action buttons
  static const double kButtonHeight = 50.0;

  // Standard size for large icons
  static const double kIconSizeLarge = 30.0;
  // Standard size for small icons
  static const double kIconSizeSmall = 20.0;

  // Standard size for Text
  static const double kTextSize = 16.0;
  static const double kSmallTextSize = 14.0;
  static const double kLargeTextSize = 20.0;
  static const double kTitleTextSize = 24.0;

  // --- ANIMATION & TIME ---

  // Standard duration for most UI animations
  static const Duration kAnimationDuration = Duration(milliseconds: 300);

  // Duration for a temporary message
  static const Duration kSnackbarDuration = Duration(seconds: 4);

  static const Duration kCarouselAutoPlayDuration = Duration(seconds: 5);
  // --- DEVICE & RESPONSIVENESS ---

  // Maximum width for content when viewed on large screens (web/tablet)
  static const double kMaxContentWidth = 1200.0;

  // Standard breakpoint for switching from mobile to tablet/desktop layouts
  static const double kTabletBreakpoint = 600.0;

  // --- REGEX AND VALIDATION ---

  // Basic email validation regex
  static const String kEmailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

  // Minimum length for a password
  static const int kMinPasswordLength = 8;
}

class AppSpaces {
  static const Widget smallVertical = SizedBox(
    height: AppConstants.kSpacingSmall,
  );
  static const Widget mediumVertical = SizedBox(
    height: AppConstants.kSpacingMedium,
  );
  static const Widget largeVertical = SizedBox(
    height: AppConstants.kSpacingLarge,
  );

  static const Widget smallHorizontal = SizedBox(
    width: AppConstants.kSpacingSmall,
  );
  static const Widget mediumHorizontal = SizedBox(
    width: AppConstants.kSpacingMedium,
  );
  static const Widget largeHorizontal = SizedBox(
    width: AppConstants.kSpacingLarge,
  );

  static const Divider smallDivider = Divider(
    height: AppConstants.kSpacingSmall * 2,
    color: AppColors.textPrimary,
  );
  static const Divider mediumDivider = Divider(
    height: AppConstants.kSpacingMedium * 2,
    color: AppColors.textPrimary,
  );
  static const Divider largeDivider = Divider(
    height: AppConstants.kSpacingLarge * 2,
    color: AppColors.textPrimary,
  );
}
