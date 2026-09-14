import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class OperationsStatusTabItem extends StatelessWidget {
  const OperationsStatusTabItem({
    super.key,
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final int count;
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
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.sm),
        decoration: BoxDecoration(
          color: isSelected ? color.primary : color.surface,
          borderRadius: BorderRadius.circular(Spacing.radiusPill),
          border: Border.all(
            color: isSelected
                ? color.primary
                : color.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: isSelected
                  ? getBoldStyle(
                      fontFamily: FontConstant.alexandria,
                      fontSize: FontSize.size11,
                      color: color.onPrimary,
                    )
                  : getRegularStyle(
                      fontFamily: FontConstant.alexandria,
                      fontSize: FontSize.size11,
                      color: color.onSurface,
                    ),
            ),
            const SizedBox(width: Spacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.onPrimary
                    : color.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(Spacing.radiusPill),
              ),
              child: Text(
                count.toString(),
                style: getBoldStyle(
                  fontFamily: FontConstant.alexandria,
                  fontSize: FontSize.size9,
                  color: isSelected ? color.primary : color.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
