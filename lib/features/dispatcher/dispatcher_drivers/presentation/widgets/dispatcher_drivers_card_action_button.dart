import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherDriversCardActionButton extends StatelessWidget {
  const DispatcherDriversCardActionButton({
    super.key,
    required this.isAvailable,
    this.isLoading = false,
    this.isDisabled = false,
    this.label,
    this.onTap,
  });

  final bool isAvailable;
  final bool isLoading;
  final bool isDisabled;
  final String? label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final isInteractive = isAvailable && !isDisabled && !isLoading;

    if (isAvailable) {
      return InkWell(
        onTap: isInteractive ? onTap : null,
        borderRadius: BorderRadius.circular(Spacing.buttonSmallRadius),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: isDisabled ? 0.5 : 1.0,
          child: Container(
            height: Spacing.dispatcherDriverActionBtnHeight,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
            decoration: BoxDecoration(
              color: color.primary,
              borderRadius: BorderRadius.circular(Spacing.buttonSmallRadius),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: isLoading
                  ? SizedBox.square(
                      dimension: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: color.onPrimary,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.add_rounded,
                          size:
                              Spacing.iconXs - Spacing.border - Spacing.border,
                          color: color.onPrimary,
                        ),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          label ?? locale.driversSelect,
                          style: getBoldStyle(
                            fontSize: FontSize.size11,
                            color: color.onPrimary,
                          ),
                        ),
                      ],
                    ),
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
