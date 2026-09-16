import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/assign_box_order_entity.dart';
import 'assign_box_summary_item.dart';

class AssignBoxSummaryCard extends StatelessWidget {
  const AssignBoxSummaryCard({super.key, required this.order});

  final AssignBoxOrderEntity order;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.outlineVariant),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Side 1 (Right in RTL): Box Code, Distance, Priority
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Box Code + New Badge
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.inventory_2_rounded,
                        size: Spacing.iconMd,
                        color: color.primary,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              order.boxCode,
                              style: getBoldStyle(
                                color: color.primary,
                                fontSize: FontSize.size18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: Spacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Spacing.md,
                                vertical: Spacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: color.dispatcherBadgeNewSurface,
                                borderRadius: BorderRadius.circular(
                                  Spacing.radiusPill,
                                ),
                              ),
                              child: Text(
                                order.statusText,
                                style: getSemiBoldStyle(
                                  color: color.dispatcherBadgeNew,
                                  fontSize: FontSize.size11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.md),
                  // Distance from restaurant
                  AssignBoxSummaryItem(
                    icon: Icons.storefront_rounded,
                    label: locale.assignBoxDistanceRestaurant,
                    value: order.distanceText,
                  ),
                  const SizedBox(height: Spacing.md),
                  // Priority
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        locale.assignBoxPriority,
                        style: getRegularStyle(
                          color: color.onSurfaceVariant,
                          fontSize: FontSize.size11,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.md,
                          vertical: Spacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: color.dispatcherBadgeHighSurface,
                          borderRadius: BorderRadius.circular(
                            Spacing.radiusPill,
                          ),
                        ),
                        child: Text(
                          order.priorityText,
                          style: getSemiBoldStyle(
                            color: color.dispatcherBadgeHigh,
                            fontSize: FontSize.size11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Vertical Divider
            VerticalDivider(
              color: color.outlineVariant,
              thickness: Spacing.border,
              width: Spacing.xl,
            ),
            // Side 2 (Left in RTL): Customer Area, Time, Meals Count
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AssignBoxSummaryItem(
                    icon: Icons.location_on_rounded,
                    label: locale.assignBoxWorkArea,
                    value: order.areaText,
                  ),
                  const SizedBox(height: Spacing.md),
                  AssignBoxSummaryItem(
                    icon: Icons.access_time_filled_rounded,
                    label: locale.assignBoxRequiredTime,
                    value: order.deliveryTimeWindow,
                  ),
                  const SizedBox(height: Spacing.md),
                  AssignBoxSummaryItem(
                    icon: Icons.restaurant_rounded,
                    label: locale.assignBoxMealsCount,
                    value: order.mealsCountText,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
