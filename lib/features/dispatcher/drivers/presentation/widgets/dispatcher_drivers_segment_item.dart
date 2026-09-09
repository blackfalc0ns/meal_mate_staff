import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherDriversSegmentItem extends StatelessWidget {
  const DispatcherDriversSegmentItem({
    super.key,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
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
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected ? color.primary : color.surface.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(Spacing.radiusPill),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.primary.withValues(alpha: Spacing.hairline / 2),
                    blurRadius: Spacing.xs,
                    offset: const Offset(Spacing.zero, Spacing.border),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: Spacing.iconSm,
              color: isSelected ? color.onPrimary : color.onSurfaceVariant,
            ),
            const SizedBox(width: Spacing.xs),
            Flexible(
              child: Text(
                title,
                style: isSelected
                    ? getSemiBoldStyle(
                        fontSize: FontSize.size12,
                        color: color.onPrimary,
                      )
                    : getRegularStyle(
                        fontSize: FontSize.size12,
                        color: color.onSurfaceVariant,
                      ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
