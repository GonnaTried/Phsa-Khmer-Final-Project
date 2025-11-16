import 'package:flutter/material.dart';
import 'package:flutter_app/utils/app_colors.dart';

enum IconPosition { left, right }

class CustomButton extends StatelessWidget {
  // Required properties
  final String text;
  final VoidCallback? onPressed;

  // Customization properties
  final Color buttonColor;
  final Color textColor;
  final double? width;
  final double height;
  final bool isLoading;
  final bool isDisabled;

  // Text properties
  final TextStyle? textStyle;
  final MainAxisAlignment textAlignment;

  // Icon properties
  final Icon? icon1;
  final IconPosition icon1Position;
  final Color? icon1Color;
  final Icon? icon2;
  final IconPosition icon2Position;
  final Color? icon2Color;

  // Badge
  final int? badgeCount;
  final Color badgeColor;
  final Color badgeTextColor;

  // Border properties
  final BorderStyle borderStyle;
  final Color borderColor;
  final double borderWidth;
  final BorderRadius borderRadius;

  // Internal padding
  final EdgeInsets padding;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    // Defaults based on primary theme
    this.buttonColor = AppColors.primaryColor,
    this.textColor = AppColors.white,
    this.width,
    this.height = 48.0,
    this.isLoading = false,
    this.isDisabled = false,
    // Text
    this.textStyle = const TextStyle(fontSize: 18),
    this.textAlignment = MainAxisAlignment.center,
    // Icons
    this.icon1,
    this.icon1Position = IconPosition.left,
    this.icon1Color = AppColors.white,

    this.icon2,
    this.icon2Position = IconPosition.right,
    this.icon2Color = AppColors.white,
    //badge
    this.badgeCount,
    this.badgeColor = AppColors.danger,
    this.badgeTextColor = AppColors.white,
    // Border
    this.borderStyle = BorderStyle.solid,
    this.borderColor = AppColors.transparent,
    this.borderWidth = 0.0,
    this.borderRadius = const BorderRadius.all(Radius.circular(8.0)),
    // Padding
    this.padding = const EdgeInsets.symmetric(horizontal: 16.0),
  });

  // Determines the final button color based on state
  Color get _effectiveButtonColor {
    if (isDisabled) {
      return buttonColor.withOpacity(0.5);
    }
    return buttonColor;
  }

  Icon _applyIconColor(Icon? icon, Color? color) {
    if (icon == null) return const Icon(Icons.error);
    if (color == null) return icon;

    return Icon(
      icon.icon,
      size: icon.size,
      color: color,
      textDirection: icon.textDirection,
      key: icon.key,
    );
  }

  // Helper to build the content Row
  List<Widget> _buildContent(BuildContext context) {
    if (isLoading) {
      return [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(color: textColor, strokeWidth: 2),
        ),
        const SizedBox(width: 8),
        Text(
          'Loading...',
          style: (textStyle ?? Theme.of(context).textTheme.labelLarge)
              ?.copyWith(color: textColor),
        ),
      ];
    }

    final effectiveTextStyle =
        (textStyle ?? Theme.of(context).textTheme.labelLarge)?.copyWith(
          color: textColor,
        );

    final List<Widget> leftSideWidgets = [];
    final List<Widget> rightSideWidgets = [];

    Widget? secondaryWidget;
    IconPosition secondaryPosition = icon2Position;

    final Widget? badge = _buildBadge();

    if (badge != null) {
      secondaryWidget = badge;
    } else if (icon2 != null) {
      secondaryWidget = _applyIconColor(icon2, icon2Color ?? textColor);
    }

    if (icon1 != null) {
      final icon = _applyIconColor(icon1, icon1Color ?? textColor);
      if (icon1Position == IconPosition.left) {
        leftSideWidgets.add(icon);
      } else {
        rightSideWidgets.add(icon);
      }
    }

    if (secondaryWidget != null) {
      if (secondaryPosition == IconPosition.left) {
        leftSideWidgets.insert(0, secondaryWidget);
      } else {
        rightSideWidgets.add(secondaryWidget);
      }
    }

    final Widget textWidget = Text(
      text,
      style: effectiveTextStyle,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );

    final List<Widget> children = [];

    for (int i = 0; i < leftSideWidgets.length; i++) {
      children.add(leftSideWidgets[i]);
      if (i < leftSideWidgets.length - 1) {
        children.add(const SizedBox(width: 8));
      }
    }

    if (leftSideWidgets.isNotEmpty && text.isNotEmpty) {
      children.add(const SizedBox(width: 8));
    }

    if (textAlignment == MainAxisAlignment.start) {
      children.add(textWidget);
      if (rightSideWidgets.isNotEmpty) {
        children.add(const Spacer());
      } else {
        children.add(const Spacer());
      }
    } else if (textAlignment == MainAxisAlignment.end) {
      children.add(const Spacer());
      children.add(textWidget);
    } else {
      if (leftSideWidgets.isNotEmpty || rightSideWidgets.isNotEmpty) {
        children.add(const Spacer());
        children.add(textWidget);
        children.add(const Spacer());
      } else {
        children.add(textWidget);
      }
    }
    if (rightSideWidgets.isNotEmpty &&
        text.isNotEmpty &&
        textAlignment == MainAxisAlignment.end) {
      children.add(const SizedBox(width: 8));
    }

    for (int i = 0; i < rightSideWidgets.length; i++) {
      if (i > 0) {
        children.add(const SizedBox(width: 8));
      }
      children.add(rightSideWidgets[i]);
    }

    if (text.isEmpty && children.isEmpty) {
      children.addAll(leftSideWidgets);
      if (leftSideWidgets.isNotEmpty && rightSideWidgets.isNotEmpty) {
        children.add(const Spacer());
      }
      children.addAll(rightSideWidgets);
    }

    return children;
  }

  Widget? _buildBadge() {
    if (badgeCount == null || badgeCount! <= 0) {
      return null;
    }

    final String countText = badgeCount! > 99 ? '99+' : badgeCount.toString();

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
          fontSize: 16,
          fontWeight: FontWeight.bold,
          height: 1.0, // Ensure text is centered vertically
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !isDisabled && !isLoading;

    // Determine the border decoration
    final BoxBorder? border = borderStyle == BorderStyle.none
        ? null
        : Border.all(
            color: borderColor,
            width: borderWidth,
            style: borderStyle,
          );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _effectiveButtonColor,
        borderRadius: borderRadius,
        border: border,
      ),
      child: Material(
        color: AppColors.transparent,
        borderRadius: borderRadius,
        child: InkWell(
          onTap: enabled ? onPressed : null,
          borderRadius: borderRadius,
          child: Padding(
            padding: padding,
            child: Row(
              mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
              mainAxisAlignment: textAlignment,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: _buildContent(context),
            ),
          ),
        ),
      ),
    );
  }
}
