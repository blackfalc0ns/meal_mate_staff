import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_issue_detail_entity.dart';

class DispatcherIssueDetailsDriverCard extends StatelessWidget {
  const DispatcherIssueDetailsDriverCard({
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
            locale.issueDetailsDriverData,
            style: getBoldStyle(
              fontSize: FontSize.size12,
              color: color.onSurface,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipOval(
                    child: Image.asset(
                      issue.driverAvatar,
                      width: Spacing.buttonSmallHeight * 1.15,
                      height: Spacing.buttonSmallHeight * 1.15,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (issue.isDriverOnline)
                    PositionedDirectional(
                      end: 0,
                      bottom: 0,
                      child: Container(
                        width: Spacing.md,
                        height: Spacing.md,
                        decoration: BoxDecoration(
                          color: color.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: color.surface,
                            width: Spacing.border * 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.driverName,
                      style: getBoldStyle(
                        fontSize: FontSize.size13,
                        color: color.onSurface,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs / 2),
                    Text(
                      issue.driverCode,
                      style: getSemiBoldStyle(
                        fontSize: FontSize.size12,
                        color: color.primary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: Spacing.border,
                height: Spacing.buttonSmallHeight,
                color: color.outlineVariant.withValues(alpha: 0.4),
              ),
              const SizedBox(width: Spacing.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    locale.issueDetailsStatusNow,
                    style: getRegularStyle(
                      fontSize: FontSize.size10,
                      color: color.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: Spacing.xs / 2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: Spacing.xs / 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.secondaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(Spacing.radiusSm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: Spacing.xs * 1.5,
                          height: Spacing.xs * 1.5,
                          decoration: BoxDecoration(
                            color: color.secondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          locale.issueDetailsStatusOnline,
                          style: getMediumStyle(
                            fontSize: FontSize.size10,
                            color: color.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Spacing.xs / 2),
                  Text(
                    issue.driverSubStatus,
                    style: getRegularStyle(
                      fontSize: FontSize.size10,
                      color: color.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
