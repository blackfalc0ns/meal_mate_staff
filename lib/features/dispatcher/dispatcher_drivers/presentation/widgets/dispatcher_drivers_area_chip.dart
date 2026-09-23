import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_area_entity.dart';

class DispatcherDriversAreaChip extends StatelessWidget {
  const DispatcherDriversAreaChip({
    super.key,
    required this.area,
    required this.isSelected,
    required this.onTap,
  });

  final DispatcherDriverAreaEntity area;
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
                  color: color.outlineVariant.withValues(
                    alpha: Spacing.hairline + Spacing.border / 10,
                  ),
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
              area.name,
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
            const SizedBox(width: Spacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.xs,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.onPrimary.withValues(alpha: 0.25)
                    : color.primaryContainer,
                borderRadius: BorderRadius.circular(Spacing.radiusPill),
              ),
              child: Text(
                '${area.driverCount}',
                style: getSemiBoldStyle(
                  fontSize: FontSize.size10,
                  color: isSelected ? color.onPrimary : color.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
