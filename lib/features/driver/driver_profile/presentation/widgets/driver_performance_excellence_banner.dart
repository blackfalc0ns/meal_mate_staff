import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverPerformanceExcellenceBanner extends StatelessWidget {
  const DriverPerformanceExcellenceBanner({
    super.key,
    this.onViewDetailsTap,
  });

  final VoidCallback? onViewDetailsTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        gradient: LinearGradient(
          colors: [
            color.primary,
            color.inverseSurface,
          ],
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.workspace_premium_rounded,
            size: 48,
            color: color.secondary,
          ),
          const SizedBox(width: Spacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.driverPerformanceExcellenceTitle,
                  style: getBoldStyle(
                    fontSize: FontSize.size12,
                    color: color.onInverseSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  locale.driverPerformanceExcellenceSubtitle,
                  style: getRegularStyle(
                    fontSize: FontSize.size11,
                    color: color.onInverseSurface.withValues(alpha: 0.8),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.sm),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: InkWell(
                    onTap: onViewDetailsTap,
                    borderRadius: BorderRadius.circular(Spacing.radiusXl),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: color.surface,
                        borderRadius: BorderRadius.circular(Spacing.radiusXl),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.insights_rounded,
                            size: 15,
                            color: color.primary,
                          ),
                          const SizedBox(width: Spacing.xs),
                          Text(
                            locale.driverPerformanceViewDetails,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
