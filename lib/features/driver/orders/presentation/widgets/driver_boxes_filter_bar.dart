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

  AlignmentGeometry _getIndicatorAlignment(DriverBoxesFilterType filter) {
    switch (filter) {
      case DriverBoxesFilterType.all:
        return AlignmentDirectional.centerStart;
      case DriverBoxesFilterType.readyForDelivery:
        return AlignmentDirectional.center;
      case DriverBoxesFilterType.delivered:
        return AlignmentDirectional.centerEnd;
    }
  }

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
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOutCubic,
                  alignment: _getIndicatorAlignment(selectedFilter),
                  child: FractionallySizedBox(
                    widthFactor: 1 / 3,
                    heightFactor: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.primary,
                        borderRadius: BorderRadius.circular(
                          Spacing.buttonSmallRadius,
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
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
