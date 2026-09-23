import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DeliveryDelayHeroBanner extends StatelessWidget {
  const DeliveryDelayHeroBanner({super.key});

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
        color: color.secondaryContainer,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.secondary.withValues(alpha: 0.3)),
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
            child: Icon(
              Icons.access_time_filled,
              size: 40,
              color: color.secondary,
            ),
          ),
          const SizedBox(height: Spacing.base),
          Text(
            locale.driverDeliveryDelayTitle,
            style: getBoldStyle(
              fontSize: FontSize.size18,
              color: color.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            locale.driverDelayNoticeTime,
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
