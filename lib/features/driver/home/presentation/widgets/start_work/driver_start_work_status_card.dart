import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/colors.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DriverStartWorkStatusCard extends StatelessWidget {
  const DriverStartWorkStatusCard({super.key});

  static const double _dotSize = 8;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.cardPadding,
        vertical: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.driverCardBorder,
          width: Spacing.hairline,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            locale.driverStatusNow,
            style: getRegularStyle(
              fontSize: FontSize.size12,
              color: color.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: _dotSize,
                height: _dotSize,
                decoration: BoxDecoration(
                  color: color.error,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                locale.driverStatusOffline,
                style: getBoldStyle(
                  fontSize: FontSize.size16,
                  color: color.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            locale.driverNotAvailableDescription,
            style: getRegularStyle(
              fontSize: FontSize.size11,
              color: color.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
