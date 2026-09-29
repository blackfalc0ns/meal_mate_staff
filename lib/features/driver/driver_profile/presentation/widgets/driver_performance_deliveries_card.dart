import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_performance_metric_card_entity.dart';
import 'driver_performance_bar_chart.dart';

class DriverPerformanceDeliveriesCard extends StatelessWidget {
  const DriverPerformanceDeliveriesCard({
    super.key,
    required this.cardData,
  });

  final DriverPerformanceMetricCardEntity cardData;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outline.withValues(alpha: 0.5),
          width: Spacing.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.driverPerformanceDeliveries,
                      style: getRegularStyle(
                        fontSize: FontSize.size11,
                        color: color.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      locale.driverPerformanceHandover,
                      style: getRegularStyle(
                        fontSize: FontSize.size9,
                        color: color.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Icon(
                Icons.handshake_outlined,
                size: 16,
                color: color.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            cardData.value,
            style: getBoldStyle(
              fontSize: FontSize.size18,
              color: color.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            locale.driverPerformanceTrendUpFromYesterday(cardData.trendText),
            style: getMediumStyle(
              fontSize: FontSize.size10,
              color: color.tertiary,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          DriverPerformanceBarChart(
            points: cardData.points,
            barColor: color.primary,
            yLabels: const ['0', '5', '10'],
          ),
        ],
      ),
    );
  }
}
