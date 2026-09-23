import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DeliverySuccessHeroBanner extends StatelessWidget {
  const DeliverySuccessHeroBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xl,
      ),
      decoration: BoxDecoration(
        color: color.tertiaryContainer,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.tertiary.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.shadow,
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.check_circle, size: 44, color: color.tertiary),
          ),
          const SizedBox(height: Spacing.base),
          Text(
            locale.driverDeliverySuccessTitle,
            style: getBoldStyle(
              fontSize: FontSize.size18,
              color: color.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            locale.driverDeliverySuccessSubtitle,
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
