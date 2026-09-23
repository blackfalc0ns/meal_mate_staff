import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class FailedDeliveryHeroCard extends StatelessWidget {
  const FailedDeliveryHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.lg,
      ),
      decoration: BoxDecoration(
        color: color.errorContainer,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.shadow,
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.cancel, size: 36, color: color.error),
          ),
          const SizedBox(height: Spacing.base),
          Text(
            locale.driverFailedDeliveryTitle,
            style: getBoldStyle(
              fontSize: FontSize.size18,
              color: color.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            locale.driverFailedDeliverySubtitle,
            style: getMediumStyle(
              fontSize: FontSize.size13,
              color: color.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
