import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_performance_entity.dart';
import 'driver_performance_summary_column.dart';

class DriverPerformanceSummaryCard extends StatelessWidget {
  const DriverPerformanceSummaryCard({
    super.key,
    required this.performance,
  });

  final DriverPerformanceEntity performance;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final divider = Container(
      width: 1,
      height: 60,
      color: color.onInverseSurface.withValues(alpha: 0.15),
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: color.inverseSurface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: DriverPerformanceSummaryColumn(
              label: locale.driverPerformanceTotalOrders,
              icon: Icons.shopping_bag_outlined,
              value: '${performance.totalOrders}',
              unit: locale.driverPerformanceOrdersUnit,
            ),
          ),
          divider,
          Expanded(
            child: DriverPerformanceSummaryColumn(
              label: locale.driverPerformanceOnTimeRate,
              icon: Icons.access_time_rounded,
              value: performance.onTimeRate,
              unit: locale.driverPerformanceOnTimeLabel,
            ),
          ),
          divider,
          Expanded(
            child: DriverPerformanceSummaryColumn(
              label: locale.driverPerformanceDeliveries,
              subtitle: locale.driverPerformanceHandover,
              icon: Icons.handshake_outlined,
              value: '${performance.deliveriesCount}',
              unit: locale.driverPerformanceDeliveriesUnit,
            ),
          ),
          divider,
          Expanded(
            child: DriverPerformanceSummaryColumn(
              label: locale.driverPerformanceTotalDistance,
              icon: Icons.location_on_outlined,
              value: performance.totalDistance,
              unit: locale.driverPerformanceDistanceKmUnit,
            ),
          ),
        ],
      ),
    );
  }
}
