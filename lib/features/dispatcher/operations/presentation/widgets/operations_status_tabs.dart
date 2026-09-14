import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/operation_status.dart';
import '../../domain/entities/operations_filter_entity.dart';
import 'operations_status_tab_item.dart';

class OperationsStatusTabs extends StatelessWidget {
  const OperationsStatusTabs({
    super.key,
    required this.filter,
    required this.onStatusSelected,
  });

  final OperationsFilterEntity filter;
  final ValueChanged<OperationStatus?> onStatusSelected;

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Row(
        children: [
          OperationsStatusTabItem(
            label: locale.operationsTabAll,
            count: filter.totalCount,
            isSelected: filter.selectedStatus == null,
            onTap: () => onStatusSelected(null),
          ),
          const SizedBox(width: Spacing.xs),
          OperationsStatusTabItem(
            label: locale.operationsTabCompleted,
            count: filter.completedCount,
            isSelected: filter.selectedStatus == OperationStatus.completed,
            onTap: () => onStatusSelected(OperationStatus.completed),
          ),
          const SizedBox(width: Spacing.xs),
          OperationsStatusTabItem(
            label: locale.operationsTabCancelled,
            count: filter.cancelledCount,
            isSelected: filter.selectedStatus == OperationStatus.cancelled,
            onTap: () => onStatusSelected(OperationStatus.cancelled),
          ),
          const SizedBox(width: Spacing.xs),
          OperationsStatusTabItem(
            label: locale.operationsTabFailed,
            count: filter.failedCount,
            isSelected: filter.selectedStatus == OperationStatus.failed,
            onTap: () => onStatusSelected(OperationStatus.failed),
          ),
          const SizedBox(width: Spacing.xs),
          OperationsStatusTabItem(
            label: locale.operationsTabReassigned,
            count: filter.reassignedCount,
            isSelected: filter.selectedStatus == OperationStatus.reassigned,
            onTap: () => onStatusSelected(OperationStatus.reassigned),
          ),
        ],
      ),
    );
  }
}
