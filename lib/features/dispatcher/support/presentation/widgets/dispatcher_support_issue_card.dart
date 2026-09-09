import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_support_issue_entity.dart';
import '../../domain/entities/dispatcher_support_issue_type.dart';

class DispatcherSupportIssueCard extends StatelessWidget {
  const DispatcherSupportIssueCard({
    super.key,
    required this.issue,
    this.onTap,
    this.onViewDetails,
    this.onAssignAlternativeDriver,
    this.onCallDriver,
  });

  final DispatcherSupportIssueEntity issue;
  final VoidCallback? onTap;
  final VoidCallback? onViewDetails;
  final VoidCallback? onAssignAlternativeDriver;
  final VoidCallback? onCallDriver;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final indicatorColor = _getIndicatorColor(color);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.dispatcherCardRadius),
        border: Border.all(color: color.outlineVariant.withValues(alpha: 0.6)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Left-side colored indicator bar
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: Spacing.dispatcherSupportCardIndicatorWidth,
              decoration: BoxDecoration(
                color: indicatorColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(Spacing.dispatcherCardRadius),
                  bottomLeft: Radius.circular(Spacing.dispatcherCardRadius),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              left: Spacing.md,
              right: Spacing.sm,
              top: Spacing.sm,
              bottom: Spacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Right-side in RTL: Driver details + Avatar + Divider + Chevron
                    Expanded(
                      flex: 12,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chevron_left_rounded,
                            size: Spacing.iconSm,
                            color: color.onSurface,
                          ),
                          const SizedBox(width: Spacing.border),
                          Container(
                            width: Spacing.border,
                            height: 38,
                            color: color.outlineVariant.withValues(alpha: 0.5),
                          ),
                          const SizedBox(width: Spacing.xs),
                          Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: color.primary.withValues(alpha: 0.2),
                                    width: Spacing.border,
                                  ),
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    issue.driverAvatar,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 11,
                                  height: 11,
                                  decoration: BoxDecoration(
                                    color: color.error,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: color.surface,
                                      width: Spacing.border * 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: Spacing.xs),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    InkWell(
                                      onTap: onCallDriver,
                                      child: Icon(
                                        Icons.phone_rounded,
                                        size: Spacing.iconXs - Spacing.border,
                                        color: color.primary,
                                      ),
                                    ),
                                    const SizedBox(width: Spacing.border * 2),
                                    Flexible(
                                      child: Text(
                                        issue.driverName,
                                        style: getBoldStyle(
                                          fontSize: FontSize.size10,
                                          color: color.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Spacing.sm),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: Spacing.iconSm,
                                      color: color.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: Spacing.sm),
                                    Flexible(
                                      child: Text(
                                        issue.area,
                                        style: getRegularStyle(
                                          fontSize: FontSize.size10,
                                          color: color.onSurfaceVariant,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: Spacing.sm),
                                Text(
                                  '${issue.vehicleModel} • ${issue.vehicleColor}',
                                  style: getRegularStyle(
                                    fontSize: FontSize.size9,
                                    color: color.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Left-side in RTL: Issue badges & time & box code pill
                    Expanded(
                      flex: 10,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildIssueBadge(context),
                          const SizedBox(height: Spacing.border),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: Spacing.iconSm,
                                  color: color.onSurfaceVariant,
                                ),
                                const SizedBox(width: Spacing.xs),
                                Text(
                                  locale.supportTimeMinutesAgo(
                                    issue.minutesAgo,
                                  ),
                                  style: getRegularStyle(
                                    fontSize: FontSize.size9,
                                    color: color.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: Spacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.xs,
                              vertical: Spacing.border,
                            ),
                            decoration: BoxDecoration(
                              color: color.surface,
                              borderRadius: BorderRadius.circular(
                                Spacing.buttonSmallRadius,
                              ),
                              border: Border.all(
                                color: color.primary,
                                width: Spacing.border,
                              ),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.inventory_2_rounded,
                                    size: Spacing.iconXs - Spacing.border,
                                    color: color.primary,
                                  ),
                                  const SizedBox(width: Spacing.border),
                                  Text(
                                    '#${issue.boxCode}',
                                    style: getBoldStyle(
                                      fontSize: FontSize.size10,
                                      color: color.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.sm),
                // Action Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: onViewDetails,
                        borderRadius: BorderRadius.circular(
                          Spacing.buttonSmallRadius,
                        ),
                        child: Container(
                          height: Spacing.dispatcherSupportCardActionBtnHeight,
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: color.primary,
                            borderRadius: BorderRadius.circular(
                              Spacing.buttonSmallRadius,
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.visibility_outlined,
                                  size: Spacing.iconXs,
                                  color: color.onPrimary,
                                ),
                                const SizedBox(width: Spacing.xs),
                                Text(
                                  locale.supportViewDetails,
                                  style: getBoldStyle(
                                    fontSize: FontSize.size11,
                                    color: color.onPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    Expanded(
                      child: InkWell(
                        onTap: onAssignAlternativeDriver,
                        borderRadius: BorderRadius.circular(
                          Spacing.buttonSmallRadius,
                        ),
                        child: Container(
                          height: Spacing.dispatcherSupportCardActionBtnHeight,
                          padding: const EdgeInsets.symmetric(
                            horizontal: Spacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: color.surface,
                            borderRadius: BorderRadius.circular(
                              Spacing.buttonSmallRadius,
                            ),
                            border: Border.all(
                              color: color.outlineVariant.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person_add_alt_1_rounded,
                                  size: Spacing.iconXs,
                                  color: color.primary,
                                ),
                                const SizedBox(width: Spacing.xs),
                                Text(
                                  locale.supportAssignAlternativeDriver,
                                  style: getBoldStyle(
                                    fontSize: FontSize.size11,
                                    color: color.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getIndicatorColor(ColorScheme color) {
    switch (issue.issueType) {
      case DispatcherSupportIssueType.severeDelay:
      case DispatcherSupportIssueType.addressProblem:
        return color.error;
      case DispatcherSupportIssueType.damagedBox:
      case DispatcherSupportIssueType.customerUnavailable:
        return color.secondary;
    }
  }

  Widget _buildIssueBadge(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final String label;
    final IconData icon;
    final Color badgeColor;
    final Color badgeBgColor;

    switch (issue.issueType) {
      case DispatcherSupportIssueType.severeDelay:
        label = locale.supportIssueLate;
        icon = Icons.info_rounded;
        badgeColor = color.error;
        badgeBgColor = color.errorContainer;
      case DispatcherSupportIssueType.damagedBox:
        label = locale.supportIssueDamagedBox;
        icon = Icons.inventory_2_rounded;
        badgeColor = color.secondary;
        badgeBgColor = color.secondaryContainer;
      case DispatcherSupportIssueType.customerUnavailable:
        label = locale.supportIssueCustomerUnavailable;
        icon = Icons.phone_disabled_rounded;
        badgeColor = color.secondary;
        badgeBgColor = color.secondaryContainer;
      case DispatcherSupportIssueType.addressProblem:
        label = locale.supportIssueAddressProblem;
        icon = Icons.location_on_rounded;
        badgeColor = color.error;
        badgeBgColor = color.errorContainer;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        // horizontal: Spacing.xs,
        vertical: Spacing.border,
      ),
      decoration: BoxDecoration(
        color: badgeBgColor,
        borderRadius: BorderRadius.circular(Spacing.buttonSmallRadius),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: Spacing.iconSm, color: badgeColor),
          const SizedBox(width: Spacing.border),
          Flexible(
            child: Text(
              label,
              style: getRegularStyle(
                fontSize: FontSize.size9,
                color: badgeColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
