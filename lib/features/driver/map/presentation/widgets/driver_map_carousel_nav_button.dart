import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DriverMapCarouselNavButton extends StatelessWidget {
  const DriverMapCarouselNavButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.isEnabled = true,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return IconButton(
      onPressed: isEnabled ? onPressed : null,
      icon: Icon(
        icon,
        size: Spacing.iconLg,
        color: isEnabled
            ? color.primary
            : color.primary.withValues(alpha: 0.35),
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: Spacing.iconLg,
        minHeight: Spacing.iconLg,
      ),
      splashRadius: Spacing.screenH,
    );
  }
}
