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
      height: 82,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(
          color: color.outlineVariant,
          width: Spacing.border,
        ),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DriverBoxActionSection(
            isLoaded: box.isLoaded,
            onCompleteAction: onCompleteAction,
          ),
          const SizedBox(width: Spacing.xs),
          _buildVerticalDivider(color.outlineVariant),
          const SizedBox(width: Spacing.xs),
          Expanded(
            flex: 3,
            child: DriverBoxMealsAndAreaSection(
              mealCount: box.mealCount,
              area: box.area,
            ),
          ),
          _buildVerticalDivider(color.outlineVariant),
          const SizedBox(width: Spacing.xs),
          Expanded(
            flex: 3,
            child: DriverBoxIdsSection(
              boxId: box.boxId,
              orderCode: box.orderCode,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          DriverBoxIconBadge(isLoaded: box.isLoaded),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider(Color dividerColor) {
    return Container(
      width: Spacing.border,
      height: 50,
      color: dividerColor.withValues(alpha: 0.6),
    );
  }
}
