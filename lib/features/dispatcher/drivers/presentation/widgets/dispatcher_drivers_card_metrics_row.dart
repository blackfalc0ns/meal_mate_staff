import 'package:flutter/material.dart';

import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_entity.dart';
import 'dispatcher_drivers_card_metric_item.dart';

class DispatcherDriversCardMetricsRow extends StatelessWidget {
  const DispatcherDriversCardMetricsRow({
    super.key,
    required this.driver,
  });

  final DispatcherDriverEntity driver;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Row(
      children: [
        Expanded(
          child: DispatcherDriversCardMetricItem(
            icon: Icons.inventory_2_outlined,
            iconColor: color.onSurfaceVariant,
            value: driver.currentOrdersCount.toString(),
            label: locale.driversCurrentOrders,
          ),
        ),
        Expanded(
          child: DispatcherDriversCardMetricItem(
            icon: Icons.inventory_2_rounded,
            iconColor: color.primary,
            value: driver.completedOrdersTodayCount.toString(),
            label: locale.driversCompletedToday,
          ),
        ),
        Expanded(
          child: DispatcherDriversCardMetricItem(
            icon: Icons.directions_car_outlined,
            iconColor: color.onSurfaceVariant,
            value: locale.driversDistanceKm(driver.distanceKm.toStringAsFixed(0)),
            label: locale.driversDistanceFromYou,
          ),
        ),
      ],
    );
  }
}
