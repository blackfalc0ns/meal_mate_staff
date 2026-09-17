import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverVehicleNoticeCard extends StatelessWidget {
  const DriverVehicleNoticeCard({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: color.primary.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.primary.withValues(alpha: 0.15),
          width: Spacing.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_rounded, color: color.primary, size: Spacing.iconMd),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  locale.driverVehicleNoticeTitle,
                  style: getBoldStyle(
                    color: color.primary,
                    fontSize: FontSize.size13,
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  locale.driverVehicleNoticeBody,
                  style: getRegularStyle(
                    color: color.onSurfaceVariant,
                    fontSize: FontSize.size11,
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
