import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_performance_distribution_item_entity.dart';
import 'driver_performance_donut_chart.dart';
import 'driver_performance_legend_row.dart';

class DriverPerformanceDistributionCard extends StatelessWidget {
  const DriverPerformanceDistributionCard({
    super.key,
    required this.items,
    required this.totalBoxes,
  });

  final List<DriverPerformanceDistributionItemEntity> items;
  final int totalBoxes;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.6),
          width: Spacing.border,
        ),
      ),
      padding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  locale.driverPerformanceDistributionTitle,
                  style: getBoldStyle(
                    fontFamily: FontConstant.alexandria,
                    fontSize: FontSize.size13,
                    color: color.onSurface,
                  ),
                ),
              ),
              Text(
                locale.driverPerformanceDistributionOrderCol,
                style: getMediumStyle(
                  fontFamily: FontConstant.alexandria,
                  fontSize: FontSize.size10,
                  color: color.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Text(
                locale.driverPerformanceDistributionPctCol,
                style: getMediumStyle(
                  fontFamily: FontConstant.alexandria,
                  fontSize: FontSize.size10,
                  color: color.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DriverPerformanceDonutChart(
                items: items,
                centerValue: totalBoxes.toString(),
                centerLabel: locale.driverPerformanceDistributionCenterSub,
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: items
                      .map((item) => DriverPerformanceLegendRow(item: item))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
