import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../../config/theme/font_manager.dart';
import '../../../../../../config/theme/spacing.dart';
import '../../../../../../config/theme/styles_manager.dart';
import '../../../../../../core/constants/assets.dart';
import '../../../../../../core/extensions/extensions.dart';
import '../../../domain/entities/dispatcher_issue_detail_entity.dart';

class ReassignDriverIssueHeader extends StatelessWidget {
  const ReassignDriverIssueHeader({super.key, required this.issue});

  final DispatcherIssueDetailEntity issue;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text Column (Start side - Right in RTL)
        Expanded(
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
                    Icon(
                      Icons.info_rounded,
                      size: Spacing.iconXs - Spacing.border * 2,
                      color: color.error,
                    ),
                    const SizedBox(width: Spacing.xs / 2),
                    Flexible(
                      child: Text(
                        issue.priority.isNotEmpty
                            ? issue.priority
                            : locale.reassignDriverProblemSummary,
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
              const SizedBox(height: Spacing.xs),
              Text(
                issue.title,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size13,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: Spacing.xs / 2),
              Text(
                locale.driverDetailsTimeAgo(issue.minutesAgo),
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

        const SizedBox(width: Spacing.sm),

        // Circle with Delivery Truck Speed SVG (End side - Left in RTL)
        Container(
          width: Spacing.buttonSmallHeight + Spacing.xs,
          height: Spacing.buttonSmallHeight + Spacing.xs,
          decoration: BoxDecoration(
            color: color.errorContainer,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              AppAssets.deliveryTruckSpeed,
              width: Spacing.iconMd,
              height: Spacing.iconMd,
              colorFilter: ColorFilter.mode(color.error, BlendMode.srcIn),
            ),
          ),
        ),
      ],
    );
  }
}
