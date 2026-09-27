import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherDriversStatusFilterButton extends StatelessWidget {
  const DispatcherDriversStatusFilterButton({
    super.key,
    this.onTap,
    this.isActive = false,
  });

  final VoidCallback? onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Material(
      color: isActive ? color.primary.withValues(alpha: 0.1) : color.surface,
      borderRadius: BorderRadius.circular(Spacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Spacing.radiusMd),
            border: Border.all(
              color: isActive ? color.primary : color.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: Spacing.iconSm,
                color: isActive ? color.primary : color.onSurfaceVariant,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                locale.driversStatusFilter,
                style: getMediumStyle(
                  fontFamily: FontConstant.alexandria,
                  fontSize: FontSize.size12,
                  color: isActive ? color.primary : color.onSurface,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Icon(
                Icons.filter_list_rounded,
                size: Spacing.iconSm,
                color: isActive ? color.primary : color.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
