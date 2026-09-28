import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
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
                icon: Icons.cancel_rounded,
                accentColor: const Color(0xFFEF4444),
                borderColor: const Color(0xFFFFD4D4),
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Expanded(
              child: DriverDailySummaryCard(
                count: summary.inDeliveryCount,
                label: locale.driverSummaryInDelivery,
                icon: Icons.access_time_filled_rounded,
                accentColor: const Color(0xFFF97316),
                borderColor: const Color(0xFFFFE0CC),
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Expanded(
              child: DriverDailySummaryCard(
                count: summary.deliveredCount,
                label: locale.driverSummaryDelivered,
                icon: Icons.check_circle_rounded,
                accentColor: const Color(0xFF22C55E),
                borderColor: const Color(0xFFCCF4DD),
              ),
            ),
            const SizedBox(width: Spacing.xs),
            Expanded(
              child: DriverDailySummaryCard(
                count: summary.totalOrdersCount,
                label: locale.driverSummaryTotalOrders,
                icon: Icons.shopping_bag_rounded,
                accentColor: color.primary,
                borderColor: const Color(0xFFE0D4FC),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
