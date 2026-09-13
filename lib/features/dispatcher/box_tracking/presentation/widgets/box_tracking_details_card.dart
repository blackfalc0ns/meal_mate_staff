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
          BoxTrackingDetailsRow(
            label: locale.boxTrackingPlanType,
            value: box.planType,
            icon: Icons.restaurant_menu_rounded,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: Spacing.sm),
            child: Divider(height: Spacing.border),
          ),
          BoxTrackingDetailsRow(
            label: locale.boxTrackingOrderDate,
            value: box.orderDate,
            icon: Icons.calendar_today_outlined,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: Spacing.sm),
            child: Divider(height: Spacing.border),
          ),
          BoxTrackingDetailsRow(
            label: locale.boxTrackingMealCount,
            value: box.mealCount,
            icon: Icons.lunch_dining_outlined,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: Spacing.sm),
            child: Divider(height: Spacing.border),
          ),
          BoxTrackingDetailsRow(
            label: locale.boxTrackingCustomerNotes,
            value: box.customerNotes,
            icon: Icons.chat_outlined,
          ),
        ],
      ),
    );
  }
}
