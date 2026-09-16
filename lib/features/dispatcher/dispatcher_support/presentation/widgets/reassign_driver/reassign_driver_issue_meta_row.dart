import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../config/theme/font_manager.dart';
import '../../../../../../config/theme/spacing.dart';
import '../../../../../../config/theme/styles_manager.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../domain/entities/dispatcher_issue_detail_entity.dart';

class ReassignDriverIssueMetaRow extends StatelessWidget {
  const ReassignDriverIssueMetaRow({super.key, required this.issue});

  final DispatcherIssueDetailEntity issue;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return IntrinsicHeight(
      child: Row(
        children: [
          // 1) Task Number
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  locale.reassignDriverTaskNumber,
                  style: getRegularStyle(
                    color: color.onSurfaceVariant,
                    fontSize: FontSize.size10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.xs / 2),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: issue.taskNumber));
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.copy_rounded,
                        size: Spacing.iconXs - Spacing.border * 2,
                        color: color.primary,
                      ),
                      const SizedBox(width: Spacing.xs / 2),
                      Flexible(
                        child: Text(
                          issue.taskNumber,
                          style: getBoldStyle(
                            color: color.onSurface,
                            fontSize: FontSize.size11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          VerticalDivider(
            color: color.outlineVariant,
            width: Spacing.sm,
            thickness: Spacing.border,
          ),

          // 2) Area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: Spacing.iconXs - Spacing.border * 2,
                      color: color.primary,
                    ),
                    const SizedBox(width: Spacing.xs / 2),
                    Flexible(
                      child: Text(
                        locale.reassignDriverArea,
                        style: getRegularStyle(
                          color: color.onSurfaceVariant,
                          fontSize: FontSize.size10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xs / 2),
                Text(
                  issue.area,
                  style: getBoldStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          VerticalDivider(
            color: color.outlineVariant,
            width: Spacing.sm,
            thickness: Spacing.border,
          ),

          // 3) Affected Boxes
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_rounded,
                      size: Spacing.iconXs - Spacing.border * 2,
                      color: color.primary,
                    ),
                    const SizedBox(width: Spacing.xs / 2),
                    Flexible(
                      child: Text(
                        locale.reassignDriverAffectedBoxes,
                        style: getRegularStyle(
                          color: color.onSurfaceVariant,
                          fontSize: FontSize.size9,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xs / 2),
                Text(
                  '${issue.affectedBoxesCount}',
                  style: getBoldStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          VerticalDivider(
            color: color.outlineVariant,
            width: Spacing.sm,
            thickness: Spacing.border,
          ),

          // 4) Priority
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.flag_rounded,
                      size: Spacing.iconXs - Spacing.border * 2,
                      color: color.primary,
                    ),
                    const SizedBox(width: Spacing.xs / 2),
                    Flexible(
                      child: Text(
                        locale.reassignDriverPriority,
                        style: getRegularStyle(
                          color: color.onSurfaceVariant,
                          fontSize: FontSize.size10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xs / 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xs,
                    vertical: Spacing.xs / 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.errorContainer,
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  ),
                  child: Text(
                    issue.priority,
                    style: getBoldStyle(
                      color: color.error,
                      fontSize: FontSize.size10,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
