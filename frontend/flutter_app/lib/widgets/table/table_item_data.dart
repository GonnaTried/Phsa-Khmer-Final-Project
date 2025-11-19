import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_colors.dart';

class TableItemData {
  final Widget? leadingWidget;
  final String? primaryText;
  final String? secondaryText;
  final String? rightText;
  final int? badgeCount;
  final Function(BuildContext context)? onTap;

  final Color? primaryTextColor;
  final Color? secondaryTextColor;
  final Color? rightTextColor;
  final Color? badgeColorOverride;
  final Color? badgeTextColorOverride;

  TableItemData({
    this.leadingWidget,
    this.primaryText,
    this.secondaryText,
    this.rightText,
    this.badgeCount,
    this.onTap,
    this.primaryTextColor,
    this.secondaryTextColor,
    this.rightTextColor,
    this.badgeColorOverride,
    this.badgeTextColorOverride,
  });
}

class EcomTableItem extends StatelessWidget {
  final TableItemData data;

  final Color defaultTitleColor;
  final Color defaultSubtitleColor;
  final Color defaultRightTextColor;
  final Color defaultBadgeColor;
  final Color defaultBadgeTextColor;

  final double height;
  final double titleFontSize;
  final double subtitleFontSize;

  const EcomTableItem({
    super.key,
    required this.data,
    this.defaultTitleColor = AppColors.textPrimary,
    this.defaultSubtitleColor = AppColors.textSecondary,
    this.defaultRightTextColor = AppColors.textPrimary,
    this.defaultBadgeColor = AppColors.danger,
    this.defaultBadgeTextColor = AppColors.white,
    this.height = 70.0,
    this.titleFontSize = 16.0,
    this.subtitleFontSize = 12.0,
  });

  Color get _primaryTextColor => data.primaryTextColor ?? defaultTitleColor;
  Color get _secondaryTextColor =>
      data.secondaryTextColor ?? defaultSubtitleColor;
  Color get _rightTextColor => data.rightTextColor ?? defaultRightTextColor;
  Color get _badgeColor => data.badgeColorOverride ?? defaultBadgeColor;
  Color get _badgeTextColor =>
      data.badgeTextColorOverride ?? defaultBadgeTextColor;

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
        color: _badgeColor, // Use custom color
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
          color: _badgeTextColor,
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
              if (data.leadingWidget != null) ...[
                data.leadingWidget!,
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
                          color: _primaryTextColor, // Use custom color
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                    if (data.secondaryText != null)
                      Text(
                        data.secondaryText!,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: _secondaryTextColor, // Use custom color
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
                        color: _rightTextColor, // Use custom color
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
