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

    return Material(
      color: color.surface,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: color.shadow.withValues(alpha: 0.12),
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: Icon(
              icon,
              size: Spacing.iconSm,
              color: isEnabled
                  ? color.primary
                  : color.primary.withValues(alpha: 0.35),
            ),
          ),
        ),
      ),
    );
  }
}
