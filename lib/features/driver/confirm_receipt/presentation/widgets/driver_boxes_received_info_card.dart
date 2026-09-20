import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import 'driver_boxes_received_summary_item.dart';

class DriverBoxesReceivedInfoCard extends StatelessWidget {
  const DriverBoxesReceivedInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.outline, width: Spacing.border),
      ),
      child: Row(
        children: [
          DriverBoxesReceivedSummaryItem(
            icon: Icons.storefront_outlined,
            label: locale.driverAssemblyPoint,
            value: locale.driverAssemblyPointValue,
          ),
          Container(
            width: Spacing.border,
            height: Spacing.xl,
            color: color.outline,
          ),
          DriverBoxesReceivedSummaryItem(
            icon: Icons.access_time_rounded,
            label: locale.driverReceiptTime,
            value: locale.driverReceiptTimeValue,
          ),
          Container(
            width: Spacing.border,
            height: Spacing.xl,
            color: color.outline,
          ),
          DriverBoxesReceivedSummaryItem(
            icon: Icons.alt_route_rounded,
            label: locale.driverReadyForDeliveryRoute,
            value: locale.driverReadyForDeliveryRouteValue,
          ),
        ],
      ),
    );
  }
}
