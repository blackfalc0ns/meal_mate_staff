import '../../../../../config/theme/colors.dart';
import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_performance_distribution_category.dart';
import '../../domain/entities/driver_performance_distribution_item_entity.dart';

class DriverPerformanceLegendRow extends StatelessWidget {
  const DriverPerformanceLegendRow({super.key, required this.item});

  final DriverPerformanceDistributionItemEntity item;

  Color _getCategoryColor(
    DriverPerformanceDistributionCategory cat,
    ColorScheme color,
  ) {
    switch (cat) {
      case DriverPerformanceDistributionCategory.onTime:
        return color.success;
      case DriverPerformanceDistributionCategory.late:
        return color.warning;
      case DriverPerformanceDistributionCategory.failed:
        return color.error;
      case DriverPerformanceDistributionCategory.cancelled:
        return color.outline;
    }
  }

  String _getCategoryLabel(
    DriverPerformanceDistributionCategory cat,
    dynamic locale,
  ) {
    switch (cat) {
      case DriverPerformanceDistributionCategory.onTime:
        return locale.driverPerformanceDistOnTime;
      case DriverPerformanceDistributionCategory.late:
        return locale.driverPerformanceDistLate;
      case DriverPerformanceDistributionCategory.failed:
        return locale.driverPerformanceDistFailed;
      case DriverPerformanceDistributionCategory.cancelled:
        return locale.driverPerformanceDistCancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final dotColor = _getCategoryColor(item.category, color);
    final label = _getCategoryLabel(item.category, locale);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs / 2),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: Text(
              label,
              style: getRegularStyle(
                fontFamily: FontConstant.alexandria,
                fontSize: FontSize.size10,
                color: color.onSurface,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '(${item.count})',
            style: getBoldStyle(
              fontFamily: FontConstant.alexandria,
              fontSize: FontSize.size10,
              color: color.onSurface,
            ),
          ),
          const SizedBox(width: Spacing.md),
          SizedBox(
            width: 32,
            child: Text(
              '${item.percentage.toInt()}%',
              textAlign: TextAlign.end,
              style: getBoldStyle(
                fontFamily: FontConstant.alexandria,
                fontSize: FontSize.size10,
                color: color.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
