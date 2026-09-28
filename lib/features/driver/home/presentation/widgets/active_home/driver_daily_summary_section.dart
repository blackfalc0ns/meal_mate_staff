import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/colors.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_daily_summary_entity.dart';

import 'driver_daily_summary_card.dart';

class DriverDailySummarySection extends StatelessWidget {
  const DriverDailySummarySection({
    super.key,
    required this.summary,
  });

  final DriverDailySummaryEntity summary;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          locale.driverDailySummaryTitle,
          style: getBoldStyle(
            fontSize: FontSize.size14,
            color: color.onSurface,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            Expanded(
              child: DriverDailySummaryCard(
                count: summary.incompleteCount,
                label: locale.driverSummaryIncomplete,
                iconAsset: AppAssets.driverPerfNo,
                backgroundColor: color.driverSummaryIncompleteBg,
                textColor: color.driverSummaryIncompleteText,
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Expanded(
              child: DriverDailySummaryCard(
                count: summary.inDeliveryCount,
                label: locale.driverSummaryInDelivery,
                iconAsset: AppAssets.driverKpiClock,
                backgroundColor: color.driverSummaryInDeliveryBg,
                textColor: color.driverSummaryInDeliveryText,
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Expanded(
              child: DriverDailySummaryCard(
                count: summary.deliveredCount,
                label: locale.driverSummaryDelivered,
                iconAsset: AppAssets.driverKpiCheck,
                backgroundColor: color.driverSummaryDeliveredBg,
                textColor: color.driverSummaryDeliveredText,
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Expanded(
              child: DriverDailySummaryCard(
                count: summary.totalOrdersCount,
                label: locale.driverSummaryTotalOrders,
                iconAsset: AppAssets.driverKpiBox,
                backgroundColor: color.driverSummaryTotalBg,
                textColor: color.driverSummaryTotalText,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
