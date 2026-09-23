import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_performance_comparison_entity.dart';
import '../../domain/entities/driver_performance_delay_level.dart';
import 'driver_comparison_driver_header.dart';
import 'driver_comparison_metric_row.dart';

class DriverPerformanceComparisonContent extends StatelessWidget {
  const DriverPerformanceComparisonContent({
    super.key,
    required this.comparison,
  });

  final DriverPerformanceComparisonEntity comparison;

  static const double _colWidth = 135.0;
  static const double _labelColWidth = 125.0;
  static const double _headerHeight = 96.0;
  static const double _rowHeight = 48.0;

  Color _getDelayColor(
    DriverPerformanceDelayLevel level,
    int minutes,
    ColorScheme color,
  ) {
    switch (level) {
      case DriverPerformanceDelayLevel.good:
        return color.success;
      case DriverPerformanceDelayLevel.warning:
        return color.warning;
      case DriverPerformanceDelayLevel.critical:
        return color.error;
      case DriverPerformanceDelayLevel.unknown:
        if (minutes <= 10) return color.success;
        if (minutes <= 15) return color.warning;
        return color.error;
    }
  }

  Color _getFailColor(int count, ColorScheme color) {
    if (count == 0) return color.success;
    if (count == 1) return color.warning;
    return color.error;
  }

  Color? _getRowBg(int index, ColorScheme color) {
    return index.isEven
        ? color.surfaceContainerHighest.withValues(alpha: 0.25)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final labels = [
      (locale.driverPerformanceComparisonTotalAssigned, Icons.inventory_2_outlined),
      (locale.driverPerformanceComparisonDelivered, Icons.check_circle_outline_rounded),
      (locale.driverPerformanceComparisonOnTime, Icons.timer_outlined),
      (locale.driverPerformanceComparisonAvgDelay, Icons.access_time_rounded),
      (locale.driverPerformanceComparisonRating, Icons.star_outline_rounded),
      (locale.driverPerformanceComparisonFailed, Icons.block_rounded),
      (locale.driverPerformanceComparisonDistance, Icons.route_outlined),
    ];

    return Container(
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.6),
          width: Spacing.border,
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: Text(
              locale.driverPerformanceTabCompare,
              style: getBoldStyle(
                fontFamily: FontConstant.alexandria,
                fontSize: FontSize.size14,
                color: color.onSurface,
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fixed Metric Labels Column
              SizedBox(
                width: _labelColWidth,
                child: Column(
                  children: [
                    SizedBox(
                      height: _headerHeight,
                      child: Center(
                        child: Text(
                          locale.driverPerformanceColDriver,
                          style: getBoldStyle(
                            fontFamily: FontConstant.alexandria,
                            fontSize: FontSize.size12,
                            color: color.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: color.outlineVariant.withValues(alpha: 0.4),
                    ),
                    ...List.generate(labels.length, (i) {
                      final item = labels[i];
                      return DriverComparisonMetricCell.label(
                        context: context,
                        label: item.$1,
                        icon: item.$2,
                        width: _labelColWidth,
                        height: _rowHeight,
                        backgroundColor: _getRowBg(i, color),
                      );
                    }),
                  ],
                ),
              ),

              // Vertical Divider separating label column from driver columns
              Container(
                width: 1,
                height: _headerHeight + 1 + (labels.length * _rowHeight),
                color: color.outlineVariant.withValues(alpha: 0.4),
              ),

              // Horizontally Scrollable Driver Columns
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: comparison.drivers.map((driver) {
                      final delayColor = _getDelayColor(
                        driver.delayLevel,
                        driver.avgDelayMinutes,
                        color,
                      );
                      final failColor = _getFailColor(driver.failedCount, color);

                      return SizedBox(
                        width: _colWidth,
                        child: Column(
                          children: [
                            DriverComparisonDriverHeader(
                              driver: driver,
                              width: _colWidth,
                            ),
                            Divider(
                              height: 1,
                              color: color.outlineVariant.withValues(alpha: 0.4),
                            ),

                            // 1. Total Assigned
                            DriverComparisonMetricCell(
                              width: _colWidth,
                              height: _rowHeight,
                              backgroundColor: _getRowBg(0, color),
                              child: Text(
                                driver.totalAssignedText ?? '${driver.totalAssigned}',
                                style: getBoldStyle(
                                  fontFamily: FontConstant.alexandria,
                                  fontSize: FontSize.size12,
                                  color: color.onSurface,
                                ),
                              ),
                            ),

                            // 2. Delivered count + %
                            DriverComparisonMetricCell(
                              width: _colWidth,
                              height: _rowHeight,
                              backgroundColor: _getRowBg(1, color),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    driver.deliveredCountText ?? '${driver.deliveredCount}',
                                    style: getBoldStyle(
                                      fontFamily: FontConstant.alexandria,
                                      fontSize: FontSize.size12,
                                      color: color.onSurface,
                                    ),
                                  ),
                                  Text(
                                    driver.deliveredPercentageText ?? '(${driver.deliveredPercentage.toInt()}%)',
                                    style: getMediumStyle(
                                      fontFamily: FontConstant.alexandria,
                                      fontSize: FontSize.size9,
                                      color: color.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 3. On-time %
                            DriverComparisonMetricCell(
                              width: _colWidth,
                              height: _rowHeight,
                              backgroundColor: _getRowBg(2, color),
                              child: Text(
                                driver.onTimePercentageText ?? '${driver.onTimePercentage.toInt()}%',
                                style: getBoldStyle(
                                  fontFamily: FontConstant.alexandria,
                                  fontSize: FontSize.size12,
                                  color: color.primary,
                                ),
                              ),
                            ),

                            // 4. Avg delay
                            DriverComparisonMetricCell(
                              width: _colWidth,
                              height: _rowHeight,
                              backgroundColor: _getRowBg(3, color),
                              child: Text(
                                driver.avgDelayText ?? locale.driverPerformanceMinutesShort(driver.avgDelayMinutes),
                                style: getBoldStyle(
                                  fontFamily: FontConstant.alexandria,
                                  fontSize: FontSize.size11,
                                  color: delayColor,
                                ),
                              ),
                            ),

                            // 5. Rating
                            DriverComparisonMetricCell(
                              width: _colWidth,
                              height: _rowHeight,
                              backgroundColor: _getRowBg(4, color),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (driver.rating != null) ...[
                                    Icon(Icons.star_rounded, size: 14, color: color.primary),
                                    const SizedBox(width: 2),
                                    Text(
                                      driver.ratingText ?? driver.rating!.toStringAsFixed(1),
                                      style: getBoldStyle(
                                        fontFamily: FontConstant.alexandria,
                                        fontSize: FontSize.size11,
                                        color: color.onSurface,
                                      ),
                                    ),
                                  ] else
                                    Text(
                                      '—',
                                      style: getMediumStyle(
                                        fontFamily: FontConstant.alexandria,
                                        fontSize: FontSize.size11,
                                        color: color.onSurfaceVariant,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // 6. Failed count + %
                            DriverComparisonMetricCell(
                              width: _colWidth,
                              height: _rowHeight,
                              backgroundColor: _getRowBg(5, color),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    driver.failedCountText ?? '${driver.failedCount}',
                                    style: getBoldStyle(
                                      fontFamily: FontConstant.alexandria,
                                      fontSize: FontSize.size12,
                                      color: color.onSurface,
                                    ),
                                  ),
                                  Text(
                                    driver.failedPercentageText ?? '(${driver.failedPercentage.toInt()}%)',
                                    style: getMediumStyle(
                                      fontFamily: FontConstant.alexandria,
                                      fontSize: FontSize.size9,
                                      color: failColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 7. Total distance
                            DriverComparisonMetricCell(
                              width: _colWidth,
                              height: _rowHeight,
                              backgroundColor: _getRowBg(6, color),
                              child: Text(
                                driver.totalDistanceKm != null
                                    ? (driver.totalDistanceKmText ?? '${driver.totalDistanceKm!.toStringAsFixed(1)} km')
                                    : '—',
                                style: getMediumStyle(
                                  fontFamily: FontConstant.alexandria,
                                  fontSize: FontSize.size11,
                                  color: color.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
