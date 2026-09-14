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
    required this.badgeColor,
    required this.badgeTextColor,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool isSelected;
  final Color badgeColor;
  final Color badgeTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Spacing.radiusSm),
          child: Container(
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm + 2),
            decoration: BoxDecoration(
              color: isSelected ? color.primary : color.surface,
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              border: Border.all(
                color: isSelected
                    ? color.primary
                    : color.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: isSelected
                  ? getBoldStyle(
                      fontFamily: FontConstant.alexandria,
                      fontSize: FontSize.size11,
                      color: color.onPrimary,
                    )
                  : getBoldStyle(
                      fontFamily: FontConstant.alexandria,
                      fontSize: FontSize.size11,
                      color: color.onSurface,
                    ),
            ),
          ),
        ),
        Positioned(
          top: -5,
          right: 3,
          child: IgnorePointer(
            child: Container(
              height: 16,
              constraints: const BoxConstraints(minWidth: 16),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: badgeColor,
                borderRadius: BorderRadius.circular(Spacing.radiusPill),
              ),
              alignment: Alignment.center,
              child: Text(
                count.toString(),
                style: getBoldStyle(
                  fontFamily: FontConstant.alexandria,
                  fontSize: FontSize.size8,
                  color: badgeTextColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
