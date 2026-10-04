import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverBoxNotAssignedInfoCard extends StatelessWidget {
  const DriverBoxNotAssignedInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: color.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.outlineVariant, width: Spacing.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: Spacing.iconMd,
            color: color.primary,
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  locale.driverBoxNotAssignedInfoTitle,
                  style: getBoldStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size12,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  locale.driverBoxNotAssignedInfoSubtitle,
                  style: getRegularStyle(
                    color: color.onSurfaceVariant,
                    fontSize: FontSize.size11,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
