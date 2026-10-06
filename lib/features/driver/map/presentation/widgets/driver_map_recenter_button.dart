import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DriverMapRecenterButton extends StatelessWidget {
  const DriverMapRecenterButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Material(
      color: color.surface.withValues(alpha: 0),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.shadow.withValues(alpha: 0.14),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.my_location_rounded,
            size: Spacing.iconMd,
            color: color.primary,
          ),
        ),
      ),
    );
  }
}
