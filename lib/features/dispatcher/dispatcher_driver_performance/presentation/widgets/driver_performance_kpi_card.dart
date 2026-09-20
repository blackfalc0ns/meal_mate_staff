import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_performance_kpi_entity.dart';
import '../../domain/entities/driver_performance_kpi_type.dart';

class DriverPerformanceKpiCard extends StatelessWidget {
  const DriverPerformanceKpiCard({super.key, required this.item});

  final DriverPerformanceKpiEntity item;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final isHighlighted = item.isHighlighted;

    final (label, subText, iconData, iconColor) = switch (item.type) {
      DriverPerformanceKpiType.totalBoxes => (
        locale.driverPerformanceTotalBoxes,
        locale.driverPerformanceBoxesUnit,
        Icons.inventory_2_outlined,
        color.onPrimary,
      ),
      DriverPerformanceKpiType.delivered => (
        locale.driverPerformanceDelivered,
        item.subValue,
        Icons.check_circle_outline_rounded,
        color.primary,
      ),
      DriverPerformanceKpiType.avgDelay => (
        locale.driverPerformanceAvgDelay,
        locale.driverPerformanceMinutesUnit,
        Icons.access_time_rounded,
        color.tertiary,
      ),
      DriverPerformanceKpiType.overallRating => (
        locale.driverPerformanceOverallRating,
        locale.driverPerformanceOutOfFive,
        Icons.star_outline_rounded,
        color.primary,
      ),
      DriverPerformanceKpiType.deliveryFailed => (
        locale.driverPerformanceDeliveryFailed,
        item.subValue,
        Icons.block_rounded,
        color.error,
      ),
    };

    return Container(
      width: 66,
      height: 93,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: isHighlighted ? color.primary : color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusSm + 1),
        border: isHighlighted
            ? null
            : Border.all(
                color: color.outlineVariant.withValues(alpha: 0.6),
                width: Spacing.border,
              ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Icon(
            iconData,
            size: Spacing.iconSm,
            color: isHighlighted ? color.onPrimary : iconColor,
          ),
          Text(
            label,
            style: getRegularStyle(
              fontFamily: FontConstant.alexandria,
              fontSize: FontSize.size9,
              color: isHighlighted
                  ? color.onPrimary.withValues(alpha: 0.9)
                  : color.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            item.value,
            style: getBoldStyle(
              fontFamily: FontConstant.alexandria,
              fontSize: FontSize.size16,
              color: isHighlighted ? color.onPrimary : color.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            subText,
            style: getRegularStyle(
              fontFamily: FontConstant.alexandria,
              fontSize: FontSize.size9,
              color: isHighlighted
                  ? color.onPrimary.withValues(alpha: 0.85)
                  : color.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
