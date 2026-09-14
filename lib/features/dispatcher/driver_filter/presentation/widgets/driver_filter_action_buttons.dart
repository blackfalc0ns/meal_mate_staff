import 'package:flutter/material.dart';

import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'package:meal_mate_delivery/core/widget/app_button.dart';

class DriverFilterActionButtons extends StatelessWidget {
  const DriverFilterActionButtons({
    super.key,
    required this.onReset,
    required this.onApply,
  });

  final VoidCallback onReset;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Row(
      children: [
        // Reset Filters Button (Outlined via AppButton)

        // Apply Results Button (Filled Primary via AppButton)
        Expanded(
          child: AppButton(
            text: locale.driverFilterShowResults,
            onPressed: onApply,
            variant: AppButtonVariant.filled,
            color: color.primary,
            textColor: color.onPrimary,
            height: Spacing.buttonHeight,
            borderRadius: Spacing.buttonRadius,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        locale.driverFilterShowResults,
                        style: getBoldStyle(
                          color: color.onPrimary,
                          fontSize: FontSize.size13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        locale.driverFilterShowAllDrivers,
                        style: getRegularStyle(
                          color: color.onPrimary.withValues(alpha: 0.8),
                          fontSize: FontSize.size10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: Spacing.xs),

                Icon(
                  Icons.arrow_forward_rounded,
                  size: Spacing.iconSm,
                  color: color.onPrimary,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: Spacing.sm),

        Expanded(
          child: AppButton(
            text: locale.driverFilterResetAll,
            onPressed: onReset,
            variant: AppButtonVariant.outlined,
            color: color.primary,
            textColor: color.primary,
            height: Spacing.buttonHeight,
            borderRadius: Spacing.buttonRadius,
            textStyle: getBoldStyle(
              color: color.primary,
              fontSize: FontSize.size11,
            ),
          ),
        ),
      ],
    );
  }
}
