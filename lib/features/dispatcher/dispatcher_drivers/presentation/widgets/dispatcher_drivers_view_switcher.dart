import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_view_mode.dart';
import 'dispatcher_drivers_segment_item.dart';

class DispatcherDriversViewSwitcher extends StatelessWidget {
  const DispatcherDriversViewSwitcher({
    super.key,
    required this.selectedViewMode,
    required this.onViewModeChanged,
  });

  final DispatcherDriverViewMode selectedViewMode;
  final ValueChanged<DispatcherDriverViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.xs,
      ),
      child: Container(
        height:
            Spacing.registrationSmallButtonHeight +
            Spacing.border +
            Spacing.border,
        decoration: BoxDecoration(
          color: color.primaryContainer,
          borderRadius: BorderRadius.circular(Spacing.radiusPill),
        ),
        padding: const EdgeInsets.all(Spacing.xs - Spacing.border),
        child: Row(
          children: [
            Expanded(
              child: DispatcherDriversSegmentItem(
                title: locale.driversAll,
                icon: Icons.people_alt_rounded,
                isSelected:
                    selectedViewMode == DispatcherDriverViewMode.allDrivers,
                onTap: () =>
                    onViewModeChanged(DispatcherDriverViewMode.allDrivers),
              ),
            ),

            Expanded(
              child: DispatcherDriversSegmentItem(
                title: locale.driversByArea,
                icon: Icons.apartment_rounded,
                isSelected: selectedViewMode == DispatcherDriverViewMode.byArea,
                onTap: () => onViewModeChanged(DispatcherDriverViewMode.byArea),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
