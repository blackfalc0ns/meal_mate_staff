import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_filter_type.dart';
import 'dispatcher_filter_chip.dart';

class DispatcherFilterBar extends StatelessWidget {
  const DispatcherFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final DispatcherFilterType selectedFilter;
  final ValueChanged<DispatcherFilterType> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.screenH,
        vertical: Spacing.sm,
      ),
      child: Row(
        children: [
          DispatcherFilterChip(
            label: locale.dispatcherFilterAll,
            count: 23,
            isSelected: selectedFilter == DispatcherFilterType.all,
            onTap: () => onFilterSelected(DispatcherFilterType.all),
          ),
          const SizedBox(width: Spacing.sm),
          DispatcherFilterChip(
            label: locale.dispatcherStatusPendingAssignment,
            count: 23,
            dotColor: color.secondary,
            isSelected:
                selectedFilter == DispatcherFilterType.pendingAssignment,
            onTap: () =>
                onFilterSelected(DispatcherFilterType.pendingAssignment),
          ),
          const SizedBox(width: Spacing.sm),
          DispatcherFilterChip(
            label: locale.dispatcherStatusAssigned,
            count: 37,
            dotColor: color.tertiary,
            isSelected: selectedFilter == DispatcherFilterType.assigned,
            onTap: () => onFilterSelected(DispatcherFilterType.assigned),
          ),
          const SizedBox(width: Spacing.sm),
          DispatcherFilterChip(
            label: locale.dispatcherStatusInDelivery,
            count: 58,
            dotColor: color.info,
            isSelected: selectedFilter == DispatcherFilterType.inDelivery,
            onTap: () => onFilterSelected(DispatcherFilterType.inDelivery),
          ),
          const SizedBox(width: Spacing.sm),
          DispatcherFilterChip(
            label: locale.dispatcherStatusProblems,
            count: 2,
            dotColor: color.error,
            isSelected: selectedFilter == DispatcherFilterType.problems,
            onTap: () => onFilterSelected(DispatcherFilterType.problems),
          ),
        ],
      ),
    );
  }
}
