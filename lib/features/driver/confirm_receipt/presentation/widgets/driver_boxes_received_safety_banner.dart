import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverBoxesReceivedSafetyBanner extends StatelessWidget {
  const DriverBoxesReceivedSafetyBanner({super.key});

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
        color: color.primaryContainer,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.outlineVariant, width: Spacing.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: Spacing.iconSm,
            color: color.primary,
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Text(
              locale.driverBoxesDeliverySafetyTip,
              style: getRegularStyle(
                color: color.primary,
                fontSize: FontSize.size12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
