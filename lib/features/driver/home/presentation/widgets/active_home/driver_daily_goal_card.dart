import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_daily_goal_entity.dart';

class DriverDailyGoalCard extends StatelessWidget {
  const DriverDailyGoalCard({
    super.key,
    required this.goal,
  });

  final DriverDailyGoalEntity goal;

  static const double _starSize = 12;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final totalTarget = goal.totalOrdersTarget > 0 ? goal.totalOrdersTarget : 8;
    final completed = goal.completedOrders.clamp(0, totalTarget);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.cardPadding),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
          width: Spacing.hairline,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Right side: Goal information & segmented bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  locale.driverDailyGoalTitle,
                  style: getRegularStyle(
                    fontSize: FontSize.size11,
                    color: color.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 3),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text:
                            '${goal.totalOrdersTarget}/${goal.completedOrders} ',
                        style: getBoldStyle(
                          fontSize: FontSize.size22,
                          color: color.primary,
                        ),
                      ),
                      TextSpan(
                        text: locale.driverMealsUnit,
                        style: getBoldStyle(
                          fontSize: FontSize.size13,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  locale.driverDailyGoalCompleted(goal.completedOrders),
                  style: getRegularStyle(
                    fontSize: FontSize.size10,
                    color: color.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                // Segmented progress capsules (in RTL: right to left)
                Row(
                  children: List.generate(totalTarget, (index) {
                    final isFilled = index < completed;
                    return Expanded(
                      child: Container(
                        height: 8,
                        margin: EdgeInsetsDirectional.only(
                          end: index < totalTarget - 1 ? 4 : 0,
                        ),
                        decoration: BoxDecoration(
                          color: isFilled
                              ? color.primary
                              : const Color(0xFFEDE9FE),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  locale.driverDailyGoalRemaining(goal.remainingOrders),
                  style: getRegularStyle(
                    fontSize: FontSize.size10,
                    color: color.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.md),
          // Left side: 3D Target illustration + performance chip
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AppAssets.driverTarget3d,
                width: 84,
                height: 76,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(Spacing.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: color.primary,
                      size: _starSize,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      locale.driverPerformanceGood,
                      style: getBoldStyle(
                        fontSize: FontSize.size9,
                        color: color.primary,
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
