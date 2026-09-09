import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_issue_detail_entity.dart';

class DispatcherIssueDetailsHeaderCard extends StatelessWidget {
  const DispatcherIssueDetailsHeaderCard({
    super.key,
    required this.issue,
  });

  final DispatcherIssueDetailEntity issue;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
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
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: Spacing.dispatcherDriverAvatarSize,
                  height: Spacing.dispatcherDriverAvatarSize,
                  decoration: BoxDecoration(
                    color: color.errorContainer.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.directions_bike_rounded,
                    color: color.error,
                    size: Spacing.iconMd,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        issue.title,
                        style: getBoldStyle(
                          fontSize: FontSize.size14,
                          color: color.onSurface,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        locale.issueDetailsReportedMinutesAgo(issue.minutesAgo),
                        style: getRegularStyle(
                          fontSize: FontSize.size11,
                          color: color.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (issue.isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: Spacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: color.errorContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(Spacing.radiusXs),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_rounded,
                          color: color.error,
                          size: Spacing.iconXs,
                        ),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          locale.issueDetailsUrgent,
                          style: getMediumStyle(
                            fontSize: FontSize.size10,
                            color: color.error,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Divider(
            height: Spacing.border,
            thickness: Spacing.border,
            color: color.outlineVariant.withValues(alpha: 0.4),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.md,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.flag_rounded,
                              size: Spacing.iconXs,
                              color: color.primary,
                            ),
                            const SizedBox(width: Spacing.xs),
                            Text(
                              locale.issueDetailsPriority,
                              style: getRegularStyle(
                                fontSize: FontSize.size10,
                                color: color.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.sm,
                          vertical: Spacing.xs / 2,
                        ),
                        decoration: BoxDecoration(
                          color: color.errorContainer.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(Spacing.radiusXs),
                        ),
                        child: Text(
                          issue.priority,
                          style: getBoldStyle(
                            fontSize: FontSize.size10,
                            color: color.error,
                          ),
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
                Expanded(
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_rounded,
                              size: Spacing.iconXs,
                              color: color.primary,
                            ),
                            const SizedBox(width: Spacing.xs),
                            Text(
                              locale.issueDetailsAffectedBoxes,
                              style: getRegularStyle(
                                fontSize: FontSize.size10,
                                color: color.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          locale.issueDetailsBoxesCount(issue.affectedBoxesCount),
                          style: getBoldStyle(
                            fontSize: FontSize.size11,
                            color: color.onSurface,
                          ),
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
                Expanded(
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: Spacing.iconXs,
                              color: color.primary,
                            ),
                            const SizedBox(width: Spacing.xs),
                            Text(
                              locale.issueDetailsArea,
                              style: getRegularStyle(
                                fontSize: FontSize.size10,
                                color: color.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          issue.area,
                          style: getBoldStyle(
                            fontSize: FontSize.size11,
                            color: color.onSurface,
                          ),
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
                Expanded(
                  child: Column(
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                Clipboard.setData(
                                  ClipboardData(text: issue.taskNumber),
                                );
                              },
                              child: Icon(
                                Icons.copy_rounded,
                                size: Spacing.iconXs,
                                color: color.primary,
                              ),
                            ),
                            const SizedBox(width: Spacing.xs),
                            Text(
                              locale.issueDetailsTaskNumber,
                              style: getRegularStyle(
                                fontSize: FontSize.size10,
                                color: color.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          issue.taskNumber,
                          style: getBoldStyle(
                            fontSize: FontSize.size11,
                            color: color.onSurface,
                          ),
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
    );
  }
}
