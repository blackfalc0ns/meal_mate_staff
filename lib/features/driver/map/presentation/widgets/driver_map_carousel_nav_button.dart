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

    if (!isEnabled) {
      return const SizedBox(width: 28, height: 28);
    }

    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 24,
        color: color.primary,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
      splashRadius: 20,
    );
  }
}
