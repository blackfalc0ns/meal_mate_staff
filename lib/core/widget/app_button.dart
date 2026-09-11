import 'package:flutter/material.dart';

import '../../config/theme/colors.dart';
import '../../config/theme/font_manager.dart';
import '../../config/theme/spacing.dart';
import '../../config/theme/styles_manager.dart';

enum AppButtonVariant { filled, outlined, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.filled,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
    this.iconWidget,
    this.height,
    this.borderRadius,
    this.padding,
    this.iconSize,
    this.iconGap,
    this.color,
    this.textColor,
    this.textStyle,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;
  final Widget? iconWidget;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final double? iconSize;
  final double? iconGap;
  final Color? color;
  final Color? textColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    final buttonHeight = height ?? Spacing.buttonHeight;
    final radius = borderRadius ?? Spacing.buttonRadius;
    final child = isLoading
        ? const SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          )
        : _ButtonContent(
            text: text,
            icon: icon,
            iconWidget: iconWidget,
            color:
                textColor ??
                (variant == AppButtonVariant.filled
                    ? AppColors.textOnPrimary
                    : effectiveColor),
            textStyle: textStyle,
            iconSize: iconSize,
            iconGap: iconGap,
          );

    final button = switch (variant) {
      AppButtonVariant.filled => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveColor,
          foregroundColor: AppColors.textOnPrimary,
          minimumSize: Size(isExpanded ? double.infinity : 0, buttonHeight),
          padding: padding,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: child,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: effectiveColor,
          minimumSize: Size(isExpanded ? double.infinity : 0, buttonHeight),
          padding: padding,
          side: BorderSide(color: effectiveColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          minimumSize: Size(isExpanded ? double.infinity : 0, buttonHeight),
          padding: padding,
        ),
        child: child,
      ),
    };

    return SizedBox(
      height: buttonHeight,
      width: isExpanded ? double.infinity : null,
      child: button,
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.text,
    required this.color,
    this.icon,
    this.iconWidget,
    this.textStyle,
    this.iconSize,
    this.iconGap,
  });

  final String text;
  final Color color;
  final IconData? icon;
  final Widget? iconWidget;
  final TextStyle? textStyle;
  final double? iconSize;
  final double? iconGap;

  @override
  Widget build(BuildContext context) {
    final style =
        textStyle ??
        getSemiBoldStyle(
          fontSize: FontSize.size16,
          fontFamily: FontConstant.alexandria,
          color: color,
        );

    final effectiveIcon = iconWidget ??
        (icon != null
            ? Icon(icon, size: iconSize ?? Spacing.iconMd, color: color)
            : null);

    if (effectiveIcon == null) {
      return Text(text, style: style, textAlign: TextAlign.center);
    }

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          effectiveIcon,
          SizedBox(width: iconGap ?? Spacing.sm),
          Text(text, style: style, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
