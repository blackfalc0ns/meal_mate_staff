import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../domain/entities/dispatcher_metric_entity.dart';
import 'dispatcher_metric_card.dart';

class DispatcherMetricsGrid extends StatelessWidget {
  const DispatcherMetricsGrid({super.key, required this.metrics});

  final List<DispatcherMetricEntity> metrics;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.screenH,
        vertical: Spacing.sm,
      ),
      child: Row(
        children: [
          for (int i = 0; i < metrics.length; i++) ...[
            if (i > 0) const SizedBox(width: Spacing.xs),
            Expanded(child: DispatcherMetricCard(metric: metrics[i])),
          ],
        ],
      ),
    );
  }
}
