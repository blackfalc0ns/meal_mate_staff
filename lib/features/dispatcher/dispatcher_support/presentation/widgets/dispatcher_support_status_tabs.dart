import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_support_status.dart';

class DispatcherSupportStatusTabs extends StatelessWidget {
  const DispatcherSupportStatusTabs({
    super.key,
    required this.selectedStatus,
    required this.openCount,
    required this.inProgressCount,
    required this.resolvedCount,
    required this.onChanged,
  });

  final DispatcherSupportStatus selectedStatus;
  final int openCount;
  final int inProgressCount;
  final int resolvedCount;
  final ValueChanged<DispatcherSupportStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
      child: Container(
        height: Spacing.dispatcherSupportTabHeight,
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.buttonSmallRadius),
          border: Border.all(
            color: color.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTabItem(
                context: context,
                status: DispatcherSupportStatus.open,
                label: locale.supportTabOpen(openCount),
                icon: Icons.info_outline_rounded,
                isSelected: selectedStatus == DispatcherSupportStatus.open,
              ),
            ),
            Expanded(
              child: _buildTabItem(
                context: context,
                status: DispatcherSupportStatus.resolved,
                label: locale.supportTabResolved(resolvedCount),
                icon: Icons.check_circle_outline_rounded,
                isSelected: selectedStatus == DispatcherSupportStatus.resolved,
              ),
            ),
            Expanded(
              child: _buildTabItem(
                context: context,
                status: DispatcherSupportStatus.inProgress,
                label: locale.supportTabResolving(inProgressCount),
                icon: Icons.access_time_rounded,
                isSelected: selectedStatus == DispatcherSupportStatus.inProgress,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required BuildContext context,
    required DispatcherSupportStatus status,
    required String label,
    required IconData icon,
    required bool isSelected,
  }) {
    final color = context.colorScheme;

    return InkWell(
      onTap: () => onChanged(status),
      borderRadius: BorderRadius.circular(Spacing.buttonSmallRadius),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? color.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(Spacing.buttonSmallRadius - 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: Spacing.iconXs - Spacing.border,
              color: isSelected ? color.onPrimary : color.onSurfaceVariant,
            ),
            const SizedBox(width: Spacing.border * 2),
            Flexible(
              child: Text(
                label,
                style: isSelected
                    ? getBoldStyle(
                        fontSize: FontSize.size10,
                        color: color.onPrimary,
                      )
                    : getRegularStyle(
                        fontSize: FontSize.size10,
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
