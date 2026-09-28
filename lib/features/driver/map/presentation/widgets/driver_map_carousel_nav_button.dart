import 'package:flutter/material.dart';
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
        size: 28,
        color: isEnabled
            ? color.primary
            : color.primary.withValues(alpha: 0.35),
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      splashRadius: 20,
    );
  }
}
