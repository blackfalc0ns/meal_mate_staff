import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

import 'driver_start_work_metric_card.dart';

class DriverStartWorkMetricsRow extends StatelessWidget {
  const DriverStartWorkMetricsRow({
    super.key,
    this.profits = '0.0',
    this.distance = '0',
    this.completedOrders = '0',
  });

  final String profits;
  final String distance;
  final String completedOrders;

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return Row(
      children: [
        Expanded(
          child: DriverStartWorkMetricCard(
            value: '$profits ${locale.driverCurrencyKd}',
            label: locale.driverProfits,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: DriverStartWorkMetricCard(
            value: distance,
            label: locale.driverDistanceApprox,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: DriverStartWorkMetricCard(
            value: completedOrders,
            label: locale.driverCompletedOrders,
          ),
        ),
      ],
    );
  }
}
