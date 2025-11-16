import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_colors.dart';

class TableItemData {
  final Widget? leadingIcon;
  final String? primaryText;
  final String? secondaryText;
  final String? rightText;
  final int? badgeCount;
  final Function(BuildContext context)? onTap;

  TableItemData({
    this.leadingIcon,
    this.primaryText,
    this.secondaryText,
    this.rightText,
    this.badgeCount,
    this.onTap,
  });
}

class EcomTableItem extends StatelessWidget {
  final TableItemData data;

  final Color titleColor;
  final Color subtitleColor;
  final Color rightTextColor;
  final Color badgeColor;
  final Color badgeTextColor;
  final double height;
  final double titleFontSize;
  final double subtitleFontSize;

  const EcomTableItem({
    super.key,
    required this.data,
    this.titleColor = AppColors.textPrimary,
    this.subtitleColor = AppColors.textSecondary,
    this.rightTextColor = AppColors.textPrimary,
    this.badgeColor = AppColors.danger,
    this.badgeTextColor = AppColors.white,
    this.height = 70.0,
    this.titleFontSize = 16.0,
    this.subtitleFontSize = 12.0,
  });

  Widget _buildBadge() {
    if (data.badgeCount == null || data.badgeCount! <= 0) {
      return const SizedBox.shrink();
    }
    final String countText = data.badgeCount! > 99
        ? '99+'
        : data.badgeCount.toString();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(50),
      ),
      constraints: const BoxConstraints(
        minWidth: 20,
        minHeight: 20,
        maxHeight: 40,
        maxWidth: 40,
      ),
      alignment: Alignment.center,
      child: Text(
        countText,
        style: TextStyle(
          color: badgeTextColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          height: 1.0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isClickable = data.onTap != null;

    return Material(
      color: AppColors.surfaceColor,
      child: InkWell(
        onTap: isClickable ? () => data.onTap!(context) : null,
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.dividerColor, width: 1.0),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (data.leadingIcon != null) ...[
                data.leadingIcon!,
                const SizedBox(width: 12),
              ],

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (data.primaryText != null)
                      Text(
                        data.primaryText!,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: titleColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                    if (data.secondaryText != null)
                      Text(
                        data.secondaryText!,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: subtitleColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildBadge(),
                  if (data.badgeCount != null && data.badgeCount! > 0)
                    const SizedBox(width: 8),

                  if (data.rightText != null)
                    Text(
                      data.rightText!,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color: rightTextColor,
                      ),
                    ),

                  if (isClickable) ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: titleFontSize,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
