import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_box_received_success_entity.dart';
import 'driver_box_received_detail_row.dart';

class DriverBoxReceivedDetailsCard extends StatelessWidget {
  const DriverBoxReceivedDetailsCard({
    super.key,
    required this.box,
  });

  final DriverBoxReceivedSuccessEntity box;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.cardPadding),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant,
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
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: color.tertiaryContainer,
                  borderRadius: BorderRadius.circular(Spacing.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: Spacing.iconXs,
                      color: color.tertiary,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      locale.driverBoxStatusReceivedSuccess,
                      style: getMediumStyle(
                        color: color.tertiary,
                        fontSize: FontSize.size11,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    box.boxCode,
                    style: getBoldStyle(
                      color: color.primary,
                      fontSize: FontSize.size16,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    locale.driverBoxNumberLabel,
                    style: getRegularStyle(
                      color: color.onSurfaceVariant,
                      fontSize: FontSize.size11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.md),
            child: Divider(
              height: Spacing.border,
              thickness: Spacing.border,
              color: color.outlineVariant,
            ),
          ),
          DriverBoxReceivedDetailRow(
            icon: Icons.storefront_rounded,
            label: locale.driverRestaurantLabel,
            value: box.restaurantName,
          ),
          const SizedBox(height: Spacing.md),
          DriverBoxReceivedDetailRow(
            icon: Icons.inventory_2_rounded,
            label: locale.driverItemCountLabel,
            value: locale.driverBoxMealsCount(box.itemsCount),
          ),
          const SizedBox(height: Spacing.md),
          DriverBoxReceivedDetailRow(
            icon: Icons.schedule_rounded,
            label: locale.driverExpectedReceiptTime,
            value: box.expectedReceiptTime,
          ),
        ],
      ),
    );
  }
}
