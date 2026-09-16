import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_issue_detail_entity.dart';

class DispatcherIssueDetailsTripCard extends StatelessWidget {
  const DispatcherIssueDetailsTripCard({
    super.key,
    required this.issue,
  });

  final DispatcherIssueDetailEntity issue;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.6),
          width: Spacing.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            locale.issueDetailsTripInfoTitle,
            style: getBoldStyle(
              fontSize: FontSize.size12,
              color: color.onSurface,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.person_rounded,
                      size: Spacing.iconSm,
                      color: color.primary,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale.issueDetailsClient,
                            style: getRegularStyle(
                              fontSize: FontSize.size10,
                              color: color.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: Spacing.xs / 2),
                          Text(
                            issue.clientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: getBoldStyle(
                              fontSize: FontSize.size11,
                              color: color.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: Spacing.border,
                height: Spacing.dispatcherDriverBadgeHeight * 1.5,
                color: color.outlineVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.shopping_bag_rounded,
                      size: Spacing.iconSm,
                      color: color.primary,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale.issueDetailsMealsCount,
                            style: getRegularStyle(
                              fontSize: FontSize.size10,
                              color: color.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: Spacing.xs / 2),
                          Text(
                            locale.issueDetailsMealsCountValue(issue.mealsCount),
                            style: getBoldStyle(
                              fontSize: FontSize.size11,
                              color: color.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: Spacing.border,
                height: Spacing.dispatcherDriverBadgeHeight * 1.5,
                color: color.outlineVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_filled_rounded,
                      size: Spacing.iconSm,
                      color: color.primary,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale.issueDetailsExpectedDeliveryTime,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: getRegularStyle(
                              fontSize: FontSize.size10,
                              color: color.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: Spacing.xs / 2),
                          Text(
                            issue.expectedDeliveryTime,
                            style: getBoldStyle(
                              fontSize: FontSize.size11,
                              color: color.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Divider(
            height: Spacing.border,
            thickness: Spacing.border,
            color: color.outlineVariant.withValues(alpha: 0.4),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      size: Spacing.iconSm,
                      color: color.primary,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale.issueDetailsPickupLocation,
                            style: getRegularStyle(
                              fontSize: FontSize.size10,
                              color: color.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: Spacing.xs / 2),
                          Text(
                            issue.pickupLocation,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: getBoldStyle(
                              fontSize: FontSize.size11,
                              color: color.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: Spacing.border,
                height: Spacing.dispatcherDriverBadgeHeight * 1.8,
                color: color.outlineVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: Spacing.iconSm,
                      color: color.primary,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale.issueDetailsDropoffLocation,
                            style: getRegularStyle(
                              fontSize: FontSize.size10,
                              color: color.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: Spacing.xs / 2),
                          Text(
                            issue.dropoffLocation,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: getBoldStyle(
                              fontSize: FontSize.size11,
                              color: color.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
