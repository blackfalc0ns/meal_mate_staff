import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverBoxNotAssignedCard extends StatelessWidget {
  const DriverBoxNotAssignedCard({super.key, required this.boxCode});

  final String boxCode;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.cardPadding),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.outlineVariant, width: Spacing.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: color.errorContainer,
              borderRadius: BorderRadius.circular(Spacing.radiusPill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: Spacing.iconXs,
                  color: color.error,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  locale.driverBoxNotAssignedStatusBadge,
                  style: getMediumStyle(
                    color: color.error,
                    fontSize: FontSize.size11,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                boxCode,
                style: getBoldStyle(
                  color: color.primary,
                  fontSize: FontSize.size16,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                locale.driverBoxNumberLabel,
                style: getRegularStyle(
                  color: color.onSurfaceVariant,
                  fontSize: FontSize.size11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
