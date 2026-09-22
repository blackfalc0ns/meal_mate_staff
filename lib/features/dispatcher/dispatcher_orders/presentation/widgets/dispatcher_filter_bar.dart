import 'package:flutter/material.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_filter_type.dart';
import '../../domain/entities/dispatcher_order_queue_entity.dart';
import 'dispatcher_filter_chip.dart';

class DispatcherFilterBar extends StatelessWidget {
  const DispatcherFilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterSelected,
    this.counts,
  });

  final DispatcherFilterType selectedFilter;
  final ValueChanged<DispatcherFilterType> onFilterSelected;
  final DispatcherOrderQueueCountsEntity? counts;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final allCount = counts?.totalCount ?? 0;
    final pendingCount = counts?.pendingCount ?? 0;
    final assignedCount = counts?.assignedCount ?? 0;
    final inDeliveryCount = counts?.inDeliveryCount ?? 0;
    final issuesCount = counts?.issuesCount ?? 0;

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
            count: allCount,
            isSelected: selectedFilter == DispatcherFilterType.all,
            onTap: () => onFilterSelected(DispatcherFilterType.all),
          ),
          const SizedBox(width: Spacing.sm),
          DispatcherFilterChip(
            label: locale.dispatcherStatusPendingAssignment,
            count: pendingCount,
            dotColor: color.secondary,
            isSelected:
                selectedFilter == DispatcherFilterType.pendingAssignment,
            onTap: () =>
                onFilterSelected(DispatcherFilterType.pendingAssignment),
          ),
          const SizedBox(width: Spacing.sm),
          DispatcherFilterChip(
            label: locale.dispatcherStatusAssigned,
            count: assignedCount,
            dotColor: color.tertiary,
            isSelected: selectedFilter == DispatcherFilterType.assigned,
            onTap: () => onFilterSelected(DispatcherFilterType.assigned),
          ),
          const SizedBox(width: Spacing.sm),
          DispatcherFilterChip(
            label: locale.dispatcherStatusInDelivery,
            count: inDeliveryCount,
            dotColor: color.info,
            isSelected: selectedFilter == DispatcherFilterType.inDelivery,
            onTap: () => onFilterSelected(DispatcherFilterType.inDelivery),
          ),
          const SizedBox(width: Spacing.sm),
          DispatcherFilterChip(
            label: locale.dispatcherStatusProblems,
            count: issuesCount,
            dotColor: color.error,
            isSelected: selectedFilter == DispatcherFilterType.problems,
            onTap: () => onFilterSelected(DispatcherFilterType.problems),
          ),
        ],
      ),
    );
  }
}
