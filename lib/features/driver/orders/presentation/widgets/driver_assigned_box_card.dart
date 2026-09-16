import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_assigned_box_entity.dart';
import 'driver_box_action_section.dart';
import 'driver_box_icon_badge.dart';
import 'driver_box_ids_section.dart';
import 'driver_box_meals_and_area_section.dart';

class DriverAssignedBoxCard extends StatelessWidget {
  const DriverAssignedBoxCard({
    super.key,
    required this.box,
    this.onCompleteAction,
  });

  final DriverAssignedBoxEntity box;
  final VoidCallback? onCompleteAction;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 90),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm + 2,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusLg),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.6),
          width: Spacing.border,
        ),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DriverBoxActionSection(
            status: box.status,
            onCompleteAction: onCompleteAction,
          ),
          const SizedBox(width: Spacing.xs),
          Container(
            width: Spacing.border,
            height: 50,
            color: color.outlineVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            flex: 3,
            child: DriverBoxMealsAndAreaSection(
              mealCount: box.mealCount,
              area: box.area,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Container(
            width: Spacing.border,
            height: 50,
            color: color.outlineVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            flex: 3,
            child: DriverBoxIdsSection(
              boxId: box.boxId,
              orderCode: box.orderCode,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          DriverBoxIconBadge(status: box.status),
        ],
      ),
    );
  }
}
