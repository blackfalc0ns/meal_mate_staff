import 'package:flutter/material.dart';

import '../../../config/theme/font_manager.dart';
import '../../../config/theme/spacing.dart';
import '../../../config/theme/styles_manager.dart';
import '../../extensions/extensions.dart';

class AppBottomNavItem extends StatelessWidget {
  const AppBottomNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    if (isSelected) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xs,
            vertical: Spacing.sm,
          ),
          decoration: BoxDecoration(
            color: color.primary,
            borderRadius: BorderRadius.circular(Spacing.radiusPill),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                const SizedBox(height: Spacing.xs / 2),
                Text(
                  label,
                  style: getSemiBoldStyle(
                    color: color.onPrimary,
                    fontSize: FontSize.size11,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.radiusPill),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.xs,
          vertical: Spacing.sm,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(height: Spacing.xs / 2),
              Text(
                label,
                style: getSemiBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
