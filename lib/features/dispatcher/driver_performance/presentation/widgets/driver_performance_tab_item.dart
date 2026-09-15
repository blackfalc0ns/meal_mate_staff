import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverPerformanceTabItem extends StatelessWidget {
  const DriverPerformanceTabItem({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(Spacing.radiusSm),
          border: isSelected
              ? Border.all(
                  color: color.primary,
                  width: Spacing.border,
                )
              : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.shadow.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: isSelected
              ? getBoldStyle(
                  fontFamily: FontConstant.alexandria,
                  fontSize: FontSize.size12,
                  color: color.primary,
                )
              : getMediumStyle(
                  fontFamily: FontConstant.alexandria,
                  fontSize: FontSize.size12,
                  color: color.onSurfaceVariant,
                ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
