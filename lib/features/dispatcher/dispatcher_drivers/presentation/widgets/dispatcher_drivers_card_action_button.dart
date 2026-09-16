import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherDriversCardActionButton extends StatelessWidget {
  const DispatcherDriversCardActionButton({
    super.key,
    required this.isAvailable,
    this.onTap,
  });

  final bool isAvailable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    if (isAvailable) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.buttonSmallRadius),
        child: Container(
          height: Spacing.dispatcherDriverActionBtnHeight,
          padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
          decoration: BoxDecoration(
            color: color.primary,
            borderRadius: BorderRadius.circular(Spacing.buttonSmallRadius),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.add_rounded,
                  size: Spacing.iconXs - Spacing.border - Spacing.border,
                  color: color.onPrimary,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  locale.driversSelect,
                  style: getBoldStyle(
                    fontSize: FontSize.size11,
                    color: color.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: Spacing.dispatcherDriverActionBtnHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.dispatcherBadgeHorizontal,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.buttonSmallRadius),
        border: Border.all(color: color.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.block_rounded,
              size: Spacing.iconXs - Spacing.border - Spacing.border,
              color: color.onSurfaceVariant,
            ),
            const SizedBox(width: Spacing.xs),
            Text(
              locale.driversUnavailable,
              style: getRegularStyle(
                fontSize: FontSize.size10,
                color: color.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
