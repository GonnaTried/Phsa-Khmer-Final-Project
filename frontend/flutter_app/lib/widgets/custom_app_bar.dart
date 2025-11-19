import 'package:flutter/material.dart';
import 'package:flutter_app/screens/cart/cart_page.dart';
import 'package:flutter_app/utils/navigation_utils.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/app_styles.dart';

// --- Note on Dependencies ---
// This code assumes AppConstants.kTabletBreakpoint, AppConstants.kMaxContentWidth,
// AppStyles.cardShadow, and AppSpaces (for spacing in the web view) are defined.

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? titleText;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;

  final double height;

  static const double _webAppBarHeight = 60.0;

  const CustomAppBar({
    Key? key,
    this.titleText,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.height = kToolbarHeight,
  }) : super(key: key);

  // --- Responsive Check ---
  bool _isBigScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.kTabletBreakpoint;
  }

  // --- BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    if (_isBigScreen(context)) {
      return _buildWebAppBar(context);
    } else {
      return _buildMobileAppBar(context);
    }
  }

  // --- MOBILE/TABLET APP BAR (Standard AppBar) ---
  AppBar _buildMobileAppBar(BuildContext context) {
    return AppBar(
      title: titleText != null
          ? Text(
              titleText!,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
      centerTitle: true,
      elevation: Theme.of(context).appBarTheme.elevation,
    );
  }

  // --- WEB/DESKTOP APP BAR (Custom PreferredSize Wrapper) ---
  PreferredSizeWidget _buildWebAppBar(BuildContext context) {
    final Widget? leadingWidget =
        automaticallyImplyLeading && Navigator.of(context).canPop()
        ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            color: AppColors.textPrimary,
          )
        : null;
    return PreferredSize(
      preferredSize: const Size.fromHeight(_webAppBarHeight),
      child: Container(
        height: _webAppBarHeight,
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          boxShadow: AppStyles.cardShadow,
        ),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.kMaxContentWidth,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.kDefaultPadding,
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                if (leadingWidget != null) leadingWidget,

                _buildWebLogo(context),

                // 2. Navigation Links Placeholder
                const Spacer(),

                // 3. Actions (Search, Cart, Profile)
                Row(mainAxisSize: MainAxisSize.min, children: actions ?? []),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget for the Web Logo/Title
  Widget _buildWebLogo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        titleText ?? AppConstants.kAppName,
        style: AppStyles.headingPrimary.copyWith(
          color: AppColors.primaryColor,
          fontSize: 22,
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    return Size.fromHeight(
      height > _webAppBarHeight ? height : _webAppBarHeight,
    );
  }
}

class CartActionButton extends StatelessWidget {
  final int itemCount;
  const CartActionButton({Key? key, this.itemCount = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Badge(
        isLabelVisible: itemCount > 0,
        label: Text('$itemCount'),
        backgroundColor: AppColors.danger,
        child: const Icon(Icons.shopping_cart_outlined),
      ),
      onPressed: () {
        NavigationUtils.push(context, const CartPage());
      },
    );
  }
}
