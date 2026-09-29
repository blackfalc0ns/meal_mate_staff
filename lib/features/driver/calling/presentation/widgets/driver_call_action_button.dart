import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverCallActionButton extends StatelessWidget {
  const DriverCallActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  static const double _buttonSize = 58.0;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.radiusPill),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: _buttonSize,
              height: _buttonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive
                    ? color.primary.withValues(alpha: 0.35)
                    : color.primary.withValues(alpha: 0.15),
                border: Border.all(
                  color: isActive
                      ? color.primary
                      : color.primary.withValues(alpha: 0.25),
                  width: Spacing.border,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: Spacing.iconMd,
                  color: isActive ? color.primary : color.onPrimary,
                ),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              label,
              style: getRegularStyle(
                fontSize: FontSize.size12,
                color: color.onPrimary.withValues(alpha: 0.75),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
