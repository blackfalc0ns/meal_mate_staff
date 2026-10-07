import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/delivery_issue_entity.dart';

class DeliveryIssueBoxSummaryCard extends StatelessWidget {
  const DeliveryIssueBoxSummaryCard({
    super.key,
    required this.issue,
  });

  final DeliveryIssueEntity issue;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusLg),
        border: Border.all(
          color: color.primary.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Right Section (in RTL): Current Box pill, Restaurant, Customer, Meals
            Expanded(
              flex: 11,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: color.primary,
                        borderRadius: BorderRadius.circular(Spacing.radiusSm),
                      ),
                      child: Text(
                        locale.reportIssueCurrentBox,
                        style: getBoldStyle(
                          fontSize: FontSize.size11,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: Spacing.xs),
                  Text(
                    issue.restaurantName,
                    style: getBoldStyle(
                      fontSize: FontSize.size13,
                      color: color.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    issue.customerName,
                    style: getMediumStyle(
                      fontSize: FontSize.size12,
                      color: color.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    issue.mealsCountText,
                    style: getRegularStyle(
                      fontSize: FontSize.size11,
                      color: color.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            // Middle Vertical Divider
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: Spacing.md),
              color: color.outlineVariant.withValues(alpha: 0.45),
            ),
            // Left Section (in RTL): Box code, Area, Status
            Expanded(
              flex: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inventory_2_rounded,
                        size: Spacing.iconSm,
                        color: color.primary,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(
                        issue.boxCode,
                        style: getBoldStyle(
                          fontSize: FontSize.size14,
                          color: color.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: Spacing.iconSm,
                        color: color.primary,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Flexible(
                        child: Text(
                          issue.area,
                          style: getMediumStyle(
                            fontSize: FontSize.size12,
                            color: color.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xs),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'الحالي: ',
                        style: getRegularStyle(
                          fontSize: FontSize.size12,
                          color: color.onSurfaceVariant,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          issue.status,
                          style: getBoldStyle(
                            fontSize: FontSize.size12,
                            color: const Color(0xFF00B074),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
