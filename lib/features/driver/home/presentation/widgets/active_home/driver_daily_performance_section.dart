import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_daily_performance_entity.dart';

import 'driver_daily_performance_card.dart';

class DriverDailyPerformanceSection extends StatelessWidget {
  const DriverDailyPerformanceSection({super.key, required this.performance});

  final DriverDailyPerformanceEntity performance;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          locale.driverDailyPerformanceTitle,
          style: getBoldStyle(
            fontSize: FontSize.size14,
            color: color.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.xs,
            vertical: Spacing.md,
          ),
          decoration: BoxDecoration(
            color: color.surface,
            borderRadius: BorderRadius.circular(Spacing.cardRadius),
            border: Border.all(
              color: color.outlineVariant.withValues(alpha: 0.5),
              width: Spacing.hairline,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: DriverDailyPerformanceCard(
                    value: performance.averageDeliveryTime,
                    label: locale.driverAvgDeliveryTime,
                    icon: Icons.access_time_filled_rounded,
                  ),
                ),
                VerticalDivider(
                  color: color.outlineVariant.withValues(alpha: 0.4),
                  thickness: Spacing.hairline,
                  width: Spacing.xs,
                ),
                Expanded(
                  child: DriverDailyPerformanceCard(
                    value: performance.distanceCovered,
                    label: locale.driverDistanceCovered,
                    icon: Icons.alt_route_rounded,
                  ),
                ),
                VerticalDivider(
                  color: color.outlineVariant.withValues(alpha: 0.4),
                  thickness: Spacing.hairline,
                  width: Spacing.xs,
                ),
                Expanded(
                  child: DriverDailyPerformanceCard(
                    value: performance.onTimeRate,
                    label: locale.driverOnTimeRate,
                    icon: Icons.gps_fixed_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
