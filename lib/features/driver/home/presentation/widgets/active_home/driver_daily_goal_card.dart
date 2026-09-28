import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/colors.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_daily_goal_entity.dart';

class DriverDailyGoalCard extends StatelessWidget {
  const DriverDailyGoalCard({
    super.key,
    required this.goal,
  });

  final DriverDailyGoalEntity goal;

  static const double _targetSize = 44;
  static const double _starSize = 12;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.cardPadding),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.driverCardBorder,
          width: Spacing.hairline,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: _targetSize,
            height: _targetSize,
            decoration: BoxDecoration(
              color: color.driverGoalBadgeBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.track_changes_rounded,
              color: color.primary,
              size: Spacing.iconMd,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        locale.driverDailyGoalTitle,
                        style: getBoldStyle(
                          fontSize: FontSize.size13,
                          color: color.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      '${goal.completedOrders}/${goal.totalOrdersTarget} ${locale.driverMealsUnit}',
                      style: getBoldStyle(
                        fontSize: FontSize.size14,
                        color: color.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  locale.driverDailyGoalCompleted(goal.completedOrders),
                  style: getRegularStyle(
                    fontSize: FontSize.size11,
                    color: color.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(Spacing.radiusPill),
                  child: LinearProgressIndicator(
                    value: goal.progress,
                    minHeight: 6,
                    backgroundColor: color.driverGoalTrack,
                    valueColor: AlwaysStoppedAnimation<Color>(color.primary),
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        locale.driverDailyGoalRemaining(goal.remainingOrders),
                        style: getRegularStyle(
                          fontSize: FontSize.size10,
                          color: color.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.xs,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.homeStar.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(Spacing.radiusPill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: color.homeStar,
                            size: _starSize,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            locale.driverPerformanceGood,
                            style: getBoldStyle(
                              fontSize: FontSize.size9,
                              color: color.homeStar,
                            ),
                          ),
                        ],
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
}
