import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_entity.dart';
import 'dispatcher_drivers_card_metric_item.dart';

class DispatcherDriversCardMetricsRow extends StatelessWidget {
  const DispatcherDriversCardMetricsRow({super.key, required this.driver});

  final DispatcherDriverEntity driver;

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    final currentOrdersAsset = driver.activeOrdersCount > 0
        ? AppAssets.dispatcherMetricBoxActive
        : AppAssets.dispatcherMetricBoxInactive;

    final distanceDisplay =
        (driver.distanceText != null && driver.distanceText!.isNotEmpty)
        ? driver.distanceText!
        : locale.driversDistanceKm(driver.distanceKm.toStringAsFixed(1));

    return Row(
      children: [
        Expanded(
          child: DispatcherDriversCardMetricItem(
            assetPath: currentOrdersAsset,
            value: driver.activeOrdersCount.toString(),
            label: locale.driversCurrentOrders,
          ),
        ),
        const SizedBox(width: Spacing.xs),
        Expanded(
          child: DispatcherDriversCardMetricItem(
            assetPath: AppAssets.dispatcherMetricBoxActive,
            value: driver.completedOrdersTodayCount.toString(),
            label: locale.driversCompletedToday,
          ),
        ),
        const SizedBox(width: Spacing.xs),
        Expanded(
          child: DispatcherDriversCardMetricItem(
            assetPath: AppAssets.dispatcherMetricCar,
            value: distanceDisplay,
            label: locale.driversDistanceFromYou,
          ),
        ),
      ],
    );
  }
}
