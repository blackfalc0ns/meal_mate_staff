import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_kpis_entity.dart';
import 'driver_details_kpi_card.dart';

class DriverDetailsKpiRow extends StatelessWidget {
  const DriverDetailsKpiRow({super.key, required this.kpis});

  final DriverKpisEntity kpis;

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
              value: kpis.performanceRating.toStringAsFixed(1),
              label: locale.driverDetailsKpiRating,
              iconColor: color.primary,
            ),
          ),
          const SizedBox(width: Spacing.xs * 1.5),
          Expanded(
            child: DriverDetailsKpiCard(
              svgAsset: AppAssets.driverKpiClock,
              value: kpis.avgDelayMinutes.toString(),
              label: locale.driverDetailsKpiAvgDelay,
              iconColor: color.error,
            ),
          ),
          const SizedBox(width: Spacing.xs * 1.5),
          Expanded(
            child: DriverDetailsKpiCard(
              svgAsset: AppAssets.driverKpiCheck,
              value: kpis.deliveredTodayCount.toString(),
              label: locale.driverDetailsKpiDeliveredToday,
              iconColor: color.tertiary,
            ),
          ),
          const SizedBox(width: Spacing.xs * 1.5),
          Expanded(
            child: DriverDetailsKpiCard(
              svgAsset: AppAssets.driverKpiBox,
              value: kpis.activeBoxesCount.toString(),
              label: locale.driverDetailsKpiCurrentBoxes,
              iconColor: color.primary,
            ),
          ),
        ],
      ),
    );
  }
}
