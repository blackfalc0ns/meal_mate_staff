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
        Expanded(
          child: Container(
            height: Spacing.dispatcherMapButtonHeight,
            padding: const EdgeInsets.all(Spacing.xs),
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
                  title: locale.driverBoxesFilterAll,
                  isSelected: selectedFilter == DriverBoxesFilterType.all,
                  onTap: () => onFilterChanged(DriverBoxesFilterType.all),
                ),
                DriverBoxesFilterTabItem(
                  title: locale.driverBoxesFilterReadyForDelivery,
                  isSelected:
                      selectedFilter == DriverBoxesFilterType.readyForDelivery,
                  onTap: () =>
                      onFilterChanged(DriverBoxesFilterType.readyForDelivery),
                ),
                DriverBoxesFilterTabItem(
                  title: locale.driverBoxesFilterDelivered,
                  isSelected: selectedFilter == DriverBoxesFilterType.delivered,
                  onTap: () => onFilterChanged(DriverBoxesFilterType.delivered),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        DriverBoxesFilterActionButton(onTap: onFilterActionTap),
      ],
    );
  }
}
