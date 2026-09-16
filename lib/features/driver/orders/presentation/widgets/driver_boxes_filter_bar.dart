import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_boxes_filter_type.dart';
import 'driver_boxes_filter_action_button.dart';
import 'driver_boxes_filter_tab_item.dart';

class DriverBoxesFilterBar extends StatelessWidget {
  const DriverBoxesFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    this.onFilterActionTap,
  });

  final DriverBoxesFilterType selectedFilter;
  final ValueChanged<DriverBoxesFilterType> onFilterChanged;
  final VoidCallback? onFilterActionTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Row(
      children: [
        DriverBoxesFilterActionButton(onTap: onFilterActionTap),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Container(
            height: 38,
            padding: const EdgeInsets.all(Spacing.hairline * 6),
            decoration: BoxDecoration(
              color: color.surface,
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              border: Border.all(
                color: color.outlineVariant,
                width: Spacing.border,
              ),
            ),
            child: Row(
              children: [
                DriverBoxesFilterTabItem(
                  title: locale.driverBoxesFilterLoaded,
                  isSelected: selectedFilter == DriverBoxesFilterType.loaded,
                  onTap: () => onFilterChanged(DriverBoxesFilterType.loaded),
                ),
                DriverBoxesFilterTabItem(
                  title: locale.driverBoxesFilterNotLoaded,
                  isSelected: selectedFilter == DriverBoxesFilterType.notLoaded,
                  onTap: () => onFilterChanged(DriverBoxesFilterType.notLoaded),
                ),
                DriverBoxesFilterTabItem(
                  title: locale.driverBoxesFilterAll,
                  isSelected: selectedFilter == DriverBoxesFilterType.all,
                  onTap: () => onFilterChanged(DriverBoxesFilterType.all),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
