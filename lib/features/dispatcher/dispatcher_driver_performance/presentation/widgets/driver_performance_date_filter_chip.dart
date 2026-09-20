import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverPerformanceDateFilterChip extends StatelessWidget {
  const DriverPerformanceDateFilterChip({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xs,
            vertical: Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: color.surface,
            borderRadius: BorderRadius.circular(Spacing.radiusSm),
            border: Border.all(
              color: color.outlineVariant.withValues(alpha: 0.7),
              width: Spacing.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: Spacing.iconXs,
                color: color.primary,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                locale.driverPerformanceLast7Days,
                style: getMediumStyle(
                  fontSize: FontSize.size11,
                  color: color.onSurface,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: Spacing.iconSm,
                color: color.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
