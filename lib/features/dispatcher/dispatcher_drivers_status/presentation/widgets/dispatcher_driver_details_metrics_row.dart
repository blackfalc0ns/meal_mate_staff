import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_details_entity.dart';
import 'dispatcher_driver_details_metric_card.dart';

class DispatcherDriverDetailsMetricsRow extends StatelessWidget {
  const DispatcherDriverDetailsMetricsRow({super.key, required this.details});

  final DispatcherDriverDetailsEntity details;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Row(
        children: [
          Expanded(
            child: DispatcherDriverDetailsMetricCard(
              icon: Icons.inventory_2_outlined,
              value: details.totalOrdersToday.toString(),
              label: locale.driverDetailsTotalOrders,
              iconColor: color.primary,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: DispatcherDriverDetailsMetricCard(
              icon: Icons.access_time_rounded,
              value: locale.driverDetailsMinutesShort(
                details.workTimeMinutesToday,
              ),
              label: locale.driverDetailsWorkTimeToday,
              iconColor: color.primary,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: DispatcherDriverDetailsMetricCard(
              icon: Icons.directions_car_outlined,
              value: locale.driverDetailsKmShort(
                details.distanceKmToday.toString(),
              ),
              label: locale.driverDetailsDistanceToday,
              iconColor: color.primary,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: DispatcherDriverDetailsMetricCard(
              icon: Icons.shopping_bag_outlined,
              value: details.activeOrdersToday.toString(),
              label: locale.driverDetailsActiveOrders,
              iconColor: color.primary,
            ),
          ),
        ],
      ),
    );
  }
}
