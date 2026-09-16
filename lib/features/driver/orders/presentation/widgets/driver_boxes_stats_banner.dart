import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverBoxesStatsBanner extends StatelessWidget {
  const DriverBoxesStatsBanner({
    super.key,
    this.totalMeals = 32,
    this.totalBoxes = 8,
  });

  final int totalMeals;
  final int totalBoxes;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      height: 101,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.inverseSurface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                // Total Meals Column
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        locale.driverTotalMeals,
                        style: getRegularStyle(
                          color: color.onPrimary.withValues(alpha: 0.8),
                          fontSize: FontSize.size9,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        '$totalMeals',
                        style: getBoldStyle(
                          color: color.onPrimary,
                          fontSize: FontSize.size22,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        locale.driverMealsUnit,
                        style: getRegularStyle(
                          color: color.onPrimary.withValues(alpha: 0.8),
                          fontSize: FontSize.size9,
                        ),
                      ),
                    ],
                  ),
                ),
                // Subtle Divider
                Container(
                  width: Spacing.border,
                  height: Spacing.buttonHeight,
                  color: color.onPrimary.withValues(alpha: 0.2),
                ),
                // Total Boxes Column
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        locale.driverTotalBoxesToday,
                        style: getRegularStyle(
                          color: color.onPrimary.withValues(alpha: 0.8),
                          fontSize: FontSize.size9,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        '$totalBoxes',
                        style: getBoldStyle(
                          color: color.onPrimary,
                          fontSize: FontSize.size22,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs),
                      Text(
                        locale.driverBoxesUnit,
                        style: getRegularStyle(
                          color: color.onPrimary.withValues(alpha: 0.8),
                          fontSize: FontSize.size9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          // Illustration on logical end (left in RTL)
          Image.asset(
            AppAssets.driverAssignedBoxesBanner,
            width: 80,
            height: 76,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}
