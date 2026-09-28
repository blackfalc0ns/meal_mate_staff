import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_daily_performance_entity.dart';

import 'driver_daily_performance_card.dart';

class DriverDailyPerformanceSection extends StatelessWidget {
  const DriverDailyPerformanceSection({
    super.key,
    required this.performance,
  });

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
        Row(
          children: [
            Expanded(
              child: DriverDailyPerformanceCard(
                value: performance.averageDeliveryTime,
                label: locale.driverAvgDeliveryTime,
                iconAsset: AppAssets.driverPerfClock,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: DriverDailyPerformanceCard(
                value: performance.distanceCovered,
                label: locale.driverDistanceCovered,
                iconAsset: AppAssets.driverPerfPins,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: DriverDailyPerformanceCard(
                value: performance.onTimeRate,
                label: locale.driverOnTimeRate,
                iconAsset: AppAssets.driverPerfCheck,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
