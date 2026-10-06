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

    return InkWell(
      onTap: isEnabled ? onPressed : null,
      child: Center(
        child: Icon(
          icon,
          size: Spacing.iconMd,
          color: isEnabled
              ? color.primary
              : color.primary.withValues(alpha: 0.35),
        ),
      ),
    );
  }
}
