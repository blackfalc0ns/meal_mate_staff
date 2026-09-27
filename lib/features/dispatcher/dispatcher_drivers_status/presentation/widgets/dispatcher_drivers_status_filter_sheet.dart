import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_status_type.dart';

class DispatcherDriversStatusFilterSheet extends StatelessWidget {
  const DispatcherDriversStatusFilterSheet({
    super.key,
    required this.selectedFilter,
    required this.onSelectFilter,
  });

  final DispatcherDriverStatusType? selectedFilter;
  final ValueChanged<DispatcherDriverStatusType?> onSelectFilter;

  static Future<DispatcherDriverStatusType?> show({
    required BuildContext context,
    required DispatcherDriverStatusType? currentFilter,
  }) {
    return showModalBottomSheet<DispatcherDriverStatusType?>(
      context: context,
      backgroundColor: context.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Spacing.radiusLg)),
      ),
      builder: (ctx) => DispatcherDriversStatusFilterSheet(
        selectedFilter: currentFilter,
        onSelectFilter: (filter) => Navigator.of(ctx).pop(filter),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.base,
          vertical: Spacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: color.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(Spacing.radiusPill),
                ),
              ),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              locale.driversStatusFilter,
              style: getBoldStyle(
                fontFamily: FontConstant.alexandria,
                fontSize: FontSize.size16,
                color: color.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            _filterTile(
              context: context,
              label: locale.driversAll,
              isSelected: selectedFilter == null,
              onTap: () => onSelectFilter(null),
            ),
            _filterTile(
              context: context,
              label: locale.driversStatusBadgeAvailable,
              isSelected: selectedFilter == DispatcherDriverStatusType.available,
              onTap: () => onSelectFilter(DispatcherDriverStatusType.available),
            ),
            _filterTile(
              context: context,
              label: locale.driversStatusBadgeOnline,
              isSelected: selectedFilter == DispatcherDriverStatusType.connected,
              onTap: () => onSelectFilter(DispatcherDriverStatusType.connected),
            ),
            _filterTile(
              context: context,
              label: locale.driversStatusBadgeOffline,
              isSelected: selectedFilter == DispatcherDriverStatusType.offline,
              onTap: () => onSelectFilter(DispatcherDriverStatusType.offline),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterTile({
    required BuildContext context,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = context.colorScheme;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        label,
        style: getMediumStyle(
          fontFamily: FontConstant.alexandria,
          fontSize: FontSize.size14,
          color: isSelected ? color.primary : color.onSurface,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: color.primary)
          : null,
      onTap: onTap,
    );
  }
}
