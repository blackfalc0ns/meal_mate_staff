import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/operation_status.dart';
import '../../domain/entities/operations_counters_entity.dart';
import 'operations_status_tab_item.dart';

class OperationsStatusTabs extends StatelessWidget {
  const OperationsStatusTabs({
    super.key,
    required this.counters,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  final OperationsCountersEntity counters;
  final OperationStatus selectedStatus;
  final ValueChanged<OperationStatus> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: const EdgeInsets.only(
          top: 6,
          bottom: Spacing.xs,
          right: Spacing.base,
          left: Spacing.base,
        ),
        child: Row(
          children: [
            OperationsStatusTabItem(
              label: locale.operationsTabAll,
              count: counters.allCount,
              isSelected: selectedStatus == OperationStatus.all,
              badgeColor: color.outlineVariant.withValues(alpha: 0.85),
              badgeTextColor: color.onPrimary,
              onTap: () => onStatusSelected(OperationStatus.all),
            ),
            const SizedBox(width: Spacing.xs),
            OperationsStatusTabItem(
              label: locale.operationsTabCompleted,
              count: counters.completedCount,
              isSelected: selectedStatus == OperationStatus.completed,
              badgeColor: color.tertiary,
              badgeTextColor: color.onTertiary,
              onTap: () => onStatusSelected(OperationStatus.completed),
            ),
            const SizedBox(width: Spacing.xs),
            OperationsStatusTabItem(
              label: locale.operationsTabCancelled,
              count: counters.cancelledCount,
              isSelected: selectedStatus == OperationStatus.cancelled,
              badgeColor: color.error,
              badgeTextColor: color.onError,
              onTap: () => onStatusSelected(OperationStatus.cancelled),
            ),
            const SizedBox(width: Spacing.xs),
            OperationsStatusTabItem(
              label: locale.operationsTabFailed,
              count: counters.failedCount,
              isSelected: selectedStatus == OperationStatus.failed,
              badgeColor: color.error,
              badgeTextColor: color.onError,
              onTap: () => onStatusSelected(OperationStatus.failed),
            ),
            const SizedBox(width: Spacing.xs),
            OperationsStatusTabItem(
              label: locale.operationsTabReassigned,
              count: counters.reassignedCount,
              isSelected: selectedStatus == OperationStatus.reassigned,
              badgeColor: color.secondaryContainer,
              badgeTextColor: color.onSecondaryContainer,
              onTap: () => onStatusSelected(OperationStatus.reassigned),
            ),
          ],
        ),
      ),
    );
  }
}
