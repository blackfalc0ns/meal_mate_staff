import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherFilterChip extends StatelessWidget {
  const DispatcherFilterChip({
    super.key,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    this.dotColor,
  });

  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Material(
      color: color.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
        child: Ink(
          height: Spacing.dispatcherFilterChipHeight,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected ? color.primary : color.surface,
            borderRadius: BorderRadius.circular(Spacing.radiusPill),
            border: Border.all(
              color: isSelected ? color.primary : color.outline,
              width: Spacing.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColor != null && !isSelected) ...[
                Container(
                  width: Spacing.sm - Spacing.border,
                  height: Spacing.sm - Spacing.border,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: Spacing.xs),
              ],
              Text(
                label,
                style: getMediumStyle(
                  color: isSelected ? color.onPrimary : color.onSurface,
                  fontSize: FontSize.size11,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                '$count',
                style: getBoldStyle(
                  color: isSelected ? color.onPrimary : color.onSurfaceVariant,
                  fontSize: FontSize.size11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
