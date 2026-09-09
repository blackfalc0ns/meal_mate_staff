import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherDriversCardActionButton extends StatelessWidget {
  const DispatcherDriversCardActionButton({
    super.key,
    required this.isAvailable,
    this.onTap,
  });

  final bool isAvailable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    if (isAvailable) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.sm,
            vertical: Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: color.primary,
            borderRadius: BorderRadius.circular(Spacing.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add_rounded,
                size: Spacing.iconXs,
                color: color.onPrimary,
              ),
              const SizedBox(width: Spacing.border + Spacing.border),
              Text(
                locale.driversSelect,
                style: getSemiBoldStyle(
                  fontSize: FontSize.size11,
                  color: color.onPrimary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.dispatcherBadgeHorizontal,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: Spacing.hairline + Spacing.border / 10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.block_rounded,
            size: Spacing.iconSm - Spacing.xs - Spacing.border,
            color: color.onSurfaceVariant,
          ),
          const SizedBox(width: Spacing.border + Spacing.border),
          Text(
            locale.driversUnavailable,
            style: getRegularStyle(
              fontSize: FontSize.size10,
              color: color.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
