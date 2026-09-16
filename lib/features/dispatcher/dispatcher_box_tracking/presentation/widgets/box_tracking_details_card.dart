import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/box_tracking_entity.dart';
import 'box_tracking_details_row.dart';

class BoxTrackingDetailsCard extends StatelessWidget {
  const BoxTrackingDetailsCard({super.key, required this.box});

  final BoxTrackingEntity box;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.sm),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.outlineVariant, width: Spacing.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            locale.boxTrackingDetailsTitle,
            style: getBoldStyle(
              color: color.onSurface,
              fontSize: FontSize.size16,
            ),
          ),
          const SizedBox(height: Spacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BoxTrackingDetailsRow(
                  label: locale.boxTrackingPlanType,
                  value: box.planType,
                  icon: Icons.restaurant_rounded,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: BoxTrackingDetailsRow(
                  label: locale.boxTrackingOrderDate,
                  value: box.orderDate,
                  icon: Icons.calendar_today_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BoxTrackingDetailsRow(
                  label: locale.boxTrackingCustomerNotes,
                  value: box.customerNotes,
                  icon: Icons.description_outlined,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: BoxTrackingDetailsRow(
                  label: locale.boxTrackingMealCount,
                  value: box.mealCount,
                  icon: Icons.shopping_bag_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
