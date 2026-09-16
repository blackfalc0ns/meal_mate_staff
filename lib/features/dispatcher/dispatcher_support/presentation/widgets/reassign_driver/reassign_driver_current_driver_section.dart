import 'package:flutter/material.dart';

import '../../../../../../config/theme/font_manager.dart';
import '../../../../../../config/theme/spacing.dart';
import '../../../../../../config/theme/styles_manager.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../domain/entities/dispatcher_issue_detail_entity.dart';

class ReassignDriverCurrentDriverSection extends StatelessWidget {
  const ReassignDriverCurrentDriverSection({super.key, required this.issue});

  final DispatcherIssueDetailEntity issue;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Driver Identification (Start side - Right in RTL)
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  locale.reassignDriverCurrentDriver,
                  style: getBoldStyle(
                    color: color.primary,
                    fontSize: FontSize.size10,
                  ),
                ),
                const SizedBox(height: Spacing.xs / 2),
                Text(
                  issue.driverName,
                  style: getBoldStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.xs / 2),
                Text(
                  issue.driverCode,
                  style: getBoldStyle(
                    color: color.primary,
                    fontSize: FontSize.size10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          VerticalDivider(
            color: color.outlineVariant,
            width: Spacing.md,
            thickness: Spacing.border,
          ),

          // Status & Breakdown Note (Center/middle)
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xs,
                    vertical: Spacing.xs / 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.errorContainer,
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: Spacing.xs,
                        height: Spacing.xs,
                        decoration: BoxDecoration(
                          color: color.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: Spacing.xs / 2),
                      Flexible(
                        child: Text(
                          locale.reassignDriverUnavailable,
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
                const SizedBox(height: Spacing.xs / 2),
                Text(
                  issue.description.isNotEmpty
                      ? issue.description
                      : locale.reassignDriverVehicleFailureReason,
                  style: getRegularStyle(
                    color: color.onSurfaceVariant,
                    fontSize: FontSize.size10,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: Spacing.xs),

          // Avatar with red unavailable status dot (End side - Left in RTL)
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: Spacing.buttonSmallHeight + Spacing.xs,
                height: Spacing.buttonSmallHeight + Spacing.xs,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.outlineVariant,
                    width: Spacing.border,
                  ),
                ),
                padding: const EdgeInsets.all(Spacing.xs / 2),
                child: Container(
                  decoration: BoxDecoration(
                    color: color.surfaceContainerHighest,
                    shape: BoxShape.circle,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: issue.driverAvatar.isNotEmpty
                      ? Image.asset(
                          issue.driverAvatar,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Icon(
                            Icons.person_rounded,
                            size: Spacing.iconMd,
                            color: color.onSurfaceVariant.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.person_rounded,
                          size: Spacing.iconMd,
                          color: color.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                ),
              ),
              PositionedDirectional(
                bottom: Spacing.border,
                start: Spacing.border,
                child: Container(
                  width: Spacing.md,
                  height: Spacing.md,
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
        ],
      ),
    );
  }
}
