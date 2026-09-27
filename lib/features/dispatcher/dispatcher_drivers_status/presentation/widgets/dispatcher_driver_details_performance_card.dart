import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_performance_entity.dart';
import 'dispatcher_driver_details_metric_card.dart';

class DispatcherDriverDetailsPerformanceCard extends StatelessWidget {
  const DispatcherDriverDetailsPerformanceCard({
    super.key,
    required this.performance,
  });

  final DispatcherDriverPerformanceEntity performance;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.base),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
          width: Spacing.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.star_outline_rounded,
                size: Spacing.iconSm,
                color: color.primary,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                locale.driverDetailsPerformanceAndEvaluationTitle,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size13,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Expanded(
                child: DispatcherDriverDetailsMetricCard(
                  icon: Icons.bar_chart_rounded,
                  value: performance.totalOrders.toString(),
                  label: locale.driverDetailsTotalOrders,
                  iconColor: color.primary,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: DispatcherDriverDetailsMetricCard(
                  icon: Icons.thumb_up_alt_outlined,
                  value: performance.averageRating.toStringAsFixed(1),
                  label: locale.driverDetailsAverageRating,
                  iconColor: color.tertiary,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: DispatcherDriverDetailsMetricCard(
                  icon: Icons.speed_rounded,
                  value: '${performance.commitmentRatePercent}%',
                  label: locale.driverDetailsCommitmentRate,
                  iconColor: color.secondary,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: DispatcherDriverDetailsMetricCard(
                  icon: Icons.warning_amber_rounded,
                  value: performance.violationsCount.toString(),
                  label: locale.driverDetailsViolations,
                  iconColor: color.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
