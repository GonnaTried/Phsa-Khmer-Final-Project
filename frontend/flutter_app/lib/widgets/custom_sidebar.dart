import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';

class CustomSidebar extends StatelessWidget {
  static const double sidebarWidth = 250.0;

  const CustomSidebar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sidebarWidth,
      height: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surfaceColor,
        border: Border(
          right: BorderSide(color: AppColors.dividerColor, width: 1.0),
        ),
      ),
      padding: const EdgeInsets.all(AppConstants.kDefaultPadding),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product Categories',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          AppSpaces.mediumVertical,

          _buildCategoryItem(context, 'Electronics', Icons.devices),
          _buildCategoryItem(context, 'Apparel', Icons.checkroom),
          _buildCategoryItem(context, 'Home & Kitchen', Icons.kitchen),
          _buildCategoryItem(context, 'Books', Icons.book),
          AppSpaces.mediumVertical,

          const Divider(),
          AppSpaces.mediumVertical,

          _buildCategoryItem(
            context,
            'Promotions',
            Icons.local_offer,
            isPrimary: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(
    BuildContext context,
    String title,
    IconData icon, {
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: () => print('Selected category: $title'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isPrimary
                  ? AppColors.primaryColor
                  : AppColors.textSecondary,
            ),
            AppSpaces.smallHorizontal,
            Text(
              title,
              style: TextStyle(
                fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                color: isPrimary
                    ? AppColors.primaryColor
                    : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
