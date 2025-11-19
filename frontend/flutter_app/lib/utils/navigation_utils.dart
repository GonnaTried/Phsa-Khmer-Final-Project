import 'package:flutter/material.dart';
import 'package:flutter_app/screens/profile/profile_page.dart';
import 'package:flutter_app/utils/app_colors.dart';
import 'app_constants.dart';

class NavigationUtils {
  // --- 1. CORE NAVIGATION HELPERS (Standardizing push/pop) ---

  /// Pushes a new screen onto the stack.
  /// Uses MaterialPageRoute for standard transition.
  static Future<T?> push<T extends Object?>(
    BuildContext context,
    Widget screen,
  ) {
    return Navigator.of(
      context,
    ).push<T>(MaterialPageRoute(builder: (context) => screen));
  }

  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName,
  ) {
    if (routeName == AppConstants.routeProfile) {
      return push(context, const ProfilePage());
    }

    return Future.value(null);
  }

  /// Replaces the current screen with a new one
  static Future<T?> pushReplacement<T extends Object?, TO extends Object?>(
    BuildContext context,
    Widget screen,
  ) {
    return Navigator.of(
      context,
    ).pushReplacement<T, TO>(MaterialPageRoute(builder: (context) => screen));
  }

  /// Clears the entire stack and pushes a new screen
  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    BuildContext context,
    Widget screen,
  ) {
    return Navigator.of(context).pushAndRemoveUntil<T>(
      MaterialPageRoute(builder: (context) => screen),
      (Route<dynamic> route) => false,
    );
  }

  /// Pops the current screen off the stack.
  static void pop(BuildContext context, [Object? result]) {
    Navigator.of(context).pop(result);
  }

  // --- 2. USER FEEDBACK (Snackbars) ---

  static void showAppSnackbar(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    final Color backgroundColor = isError
        ? AppColors.danger
        : AppColors.success;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppColors.surfaceColor),
        ),
        backgroundColor: backgroundColor,
        duration: AppConstants.kSnackbarDuration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.kSmallBorderRadius),
        ),
        margin: const EdgeInsets.all(AppConstants.kSpacingMedium),
      ),
    );
  }

  /// Helper for showing a specific error Snackbar
  static void showErrorMessage(BuildContext context, String message) {
    showAppSnackbar(context, message, isError: true);
  }

  /// Helper for showing a specific success Snackbar
  static void showSuccessMessage(BuildContext context, String message) {
    showAppSnackbar(context, message, isError: false);
  }

  // --- 3. DIALOGS / MODALS ---

  static Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Yes',
    String cancelText = 'Cancel',
    Color confirmButtonColor = AppColors.primaryColor,
    Color cancelButtonColor = AppColors.textSecondary,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.kBorderRadius),
          ),
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () => pop(context, false),
              style: ElevatedButton.styleFrom(
                backgroundColor: cancelButtonColor,
              ),
              child: Text(cancelText),
            ),
            AppSpaces.smallVertical,
            ElevatedButton(
              onPressed: () => pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmButtonColor,
              ),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }

  static Future<T?> showCustomPopup<T extends Object?>({
    required BuildContext context,
    required Widget contentWidget,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.kBorderRadius),
          ),
          child: contentWidget,
        );
      },
    );
  }
}
