import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DispatcherSupportFilterChips extends StatelessWidget {
  const DispatcherSupportFilterChips({
    super.key,
    required this.areas,
    required this.selectedArea,
    required this.onAreaSelected,
    this.isDateFilterActive = false,
    this.onDateFilterTap,
  });

  final List<String> areas;
  final String selectedArea;
  final ValueChanged<String> onAreaSelected;
  final bool isDateFilterActive;
  final VoidCallback? onDateFilterTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return SizedBox(
      height: Spacing.dispatcherSupportFilterChipHeight,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
        children: [
          ...areas.map((area) {
            final isSelected = area == selectedArea;
            final label = area == areas.first ? locale.supportFilterAll : area;
            return Padding(
              padding: const EdgeInsetsDirectional.only(end: Spacing.xs),
              child: InkWell(
                onTap: () => onAreaSelected(area),
                borderRadius: BorderRadius.circular(Spacing.buttonSmallRadius),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.surface,
                    borderRadius: BorderRadius.circular(Spacing.buttonSmallRadius),
                    border: Border.all(
                      color: isSelected
                          ? color.primary
                          : color.outlineVariant.withValues(alpha: 0.6),
                      width: isSelected ? Spacing.border * 1.5 : Spacing.border,
                    ),
                  ),
                  child: Text(
                    label,
                    style: isSelected
                        ? getBoldStyle(
                            fontSize: FontSize.size10,
                            color: color.primary,
                          )
                        : getRegularStyle(
                            fontSize: FontSize.size10,
                            color: color.onSurfaceVariant,
                          ),
                  ),
                ),
              ),
            );
          }),
          InkWell(
            onTap: onDateFilterTap,
            borderRadius: BorderRadius.circular(Spacing.buttonSmallRadius),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(Spacing.buttonSmallRadius),
                border: Border.all(
                  color: isDateFilterActive
                      ? color.primary
                      : color.outlineVariant.withValues(alpha: 0.6),
                  width: isDateFilterActive
                      ? Spacing.border * 1.5
                      : Spacing.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    size: Spacing.iconXs,
                    color: isDateFilterActive
                        ? color.primary
                        : color.onSurfaceVariant,
                  ),
                  const SizedBox(width: Spacing.border * 2),
                  Text(
                    locale.supportFilterLast7Days,
                    style: isDateFilterActive
                        ? getBoldStyle(
                            fontSize: FontSize.size10,
                            color: color.primary,
                          )
                        : getRegularStyle(
                            fontSize: FontSize.size10,
                            color: color.onSurfaceVariant,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
