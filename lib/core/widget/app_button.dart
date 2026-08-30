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
    this.height,
    this.borderRadius,
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
  final double? height;
  final double? borderRadius;
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
            color:
                textColor ??
                (variant == AppButtonVariant.filled
                    ? AppColors.textOnPrimary
                    : effectiveColor),
            textStyle: textStyle,
          );

    final button = switch (variant) {
      AppButtonVariant.filled => ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveColor,
          foregroundColor: AppColors.textOnPrimary,
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
          side: BorderSide(color: effectiveColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: isLoading ? null : onPressed,
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
    this.textStyle,
  });

  final String text;
  final Color color;
  final IconData? icon;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final style =
        textStyle ??
        getSemiBoldStyle(
          fontSize: FontSize.size16,
          fontFamily: FontConstant.alexandria,
          color: color,
        );

    if (icon == null) {
      return Text(text, style: style, textAlign: TextAlign.center);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: Spacing.iconMd, color: color),
        const SizedBox(width: Spacing.sm),
        Flexible(
          child: Text(text, style: style, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
