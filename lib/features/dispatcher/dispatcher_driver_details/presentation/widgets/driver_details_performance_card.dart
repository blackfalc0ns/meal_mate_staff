import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_details_entity.dart';
import 'driver_details_performance_column.dart';

class DriverDetailsPerformanceCard extends StatelessWidget {
  const DriverDetailsPerformanceCard({
    super.key,
    required this.driver,
  });

  final DriverDetailsEntity driver;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: Container(
        padding: const EdgeInsets.all(Spacing.md),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          border: Border.all(
            color: color.outlineVariant,
            width: Spacing.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              locale.driverDetailsDailyPerformanceTitle,
              style: getBoldStyle(
                color: color.onSurface,
                fontSize: FontSize.size14,
              ),
            ),
            const SizedBox(height: Spacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: DriverDetailsPerformanceColumn(
                    svgAsset: AppAssets.driverPerfPins,
                    value: driver.approxKm.toString(),
                    label: locale.driverDetailsApproxKm,
                    iconColor: color.primary,
                  ),
                ),
                Container(
                  width: Spacing.border,
                  height: Spacing.xxxl,
                  color: color.outlineVariant,
                ),
                Expanded(
                  child: DriverDetailsPerformanceColumn(
                    svgAsset: AppAssets.driverPerfClock,
                    value: '${driver.avgDelayMinutes} د',
                    label: locale.driverDetailsAvgDelayMin,
                    iconColor: color.error,
                  ),
                ),
                Container(
                  width: Spacing.border,
                  height: Spacing.xxxl,
                  color: color.outlineVariant,
                ),
                Expanded(
                  child: DriverDetailsPerformanceColumn(
                    svgAsset: AppAssets.driverPerfNo,
                    value: driver.failedDeliveryCount.toString(),
                    label: locale.driverDetailsDeliveryFailed,
                    iconColor: color.error,
                  ),
                ),
                Container(
                  width: Spacing.border,
                  height: Spacing.xxxl,
                  color: color.outlineVariant,
                ),
                Expanded(
                  child: DriverDetailsPerformanceColumn(
                    svgAsset: AppAssets.driverPerfCheck,
                    value: driver.deliveredTodayCount.toString(),
                    label: locale.driverDetailsDelivered,
                    iconColor: color.tertiary, // Green
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
