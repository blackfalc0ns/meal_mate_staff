import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_details_entity.dart';
import 'driver_details_kpi_card.dart';

class DriverDetailsKpiRow extends StatelessWidget {
  const DriverDetailsKpiRow({
    super.key,
    required this.driver,
  });

  final DriverDetailsEntity driver;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: Row(
        children: [
          Expanded(
            child: DriverDetailsKpiCard(
              svgAsset: AppAssets.driverKpiStar,
              value: driver.performanceRating.toString(),
              label: locale.driverDetailsKpiRating,
              iconColor: color.primary,
            ),
          ),
          const SizedBox(width: Spacing.xs * 1.5),
          Expanded(
            child: DriverDetailsKpiCard(
              svgAsset: AppAssets.driverKpiClock,
              value: driver.avgDelayMinutes.toString(),
              label: locale.driverDetailsKpiAvgDelay,
              iconColor: color.error,
            ),
          ),
          const SizedBox(width: Spacing.xs * 1.5),
          Expanded(
            child: DriverDetailsKpiCard(
              svgAsset: AppAssets.driverKpiCheck,
              value: driver.deliveredTodayCount.toString(),
              label: locale.driverDetailsKpiDeliveredToday,
              iconColor: color.tertiary, // Green
            ),
          ),
          const SizedBox(width: Spacing.xs * 1.5),
          Expanded(
            child: DriverDetailsKpiCard(
              svgAsset: AppAssets.driverKpiBox,
              value: driver.currentBoxesCount.toString(),
              label: locale.driverDetailsKpiCurrentBoxes,
              iconColor: color.primary,
            ),
          ),
        ],
      ),
    );
  }
}
