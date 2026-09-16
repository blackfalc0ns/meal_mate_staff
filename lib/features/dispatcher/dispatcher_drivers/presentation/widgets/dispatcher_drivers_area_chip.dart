import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherDriversAreaChip extends StatelessWidget {
  const DispatcherDriversAreaChip({
    super.key,
    required this.area,
    required this.isSelected,
    required this.onTap,
  });

  final String area;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.radiusPill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color.primary : color.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusPill),
          border: isSelected
              ? null
              : Border.all(
                  color: color.outlineVariant.withValues(alpha: Spacing.hairline + Spacing.border / 10),
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on_rounded,
              size: Spacing.iconXs,
              color: isSelected ? color.onPrimary : color.onSurfaceVariant,
            ),
            const SizedBox(width: Spacing.xs),
            Text(
              area,
              style: isSelected
                  ? getSemiBoldStyle(
                      fontSize: FontSize.size12,
                      color: color.onPrimary,
                    )
                  : getRegularStyle(
                      fontSize: FontSize.size12,
                      color: color.onSurface,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
