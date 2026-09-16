import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_performance_tab_type.dart';
import 'driver_performance_tab_item.dart';

class DriverPerformanceSegmentedTabs extends StatelessWidget {
  const DriverPerformanceSegmentedTabs({
    super.key,
    required this.selectedTab,
    required this.onTabChanged,
  });

  final DriverPerformanceTabType selectedTab;
  final ValueChanged<DriverPerformanceTabType> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      height: 38,
      padding: const EdgeInsets.all(Spacing.xs / 2),
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(Spacing.radiusSm + 2),
      ),
      child: Row(
        children: [
          Expanded(
            child: DriverPerformanceTabItem(
              title: locale.driverPerformanceTabOverview,
              isSelected: selectedTab == DriverPerformanceTabType.overview,
              onTap: () => onTabChanged(DriverPerformanceTabType.overview),
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: DriverPerformanceTabItem(
              title: locale.driverPerformanceTabCompare,
              isSelected: selectedTab == DriverPerformanceTabType.compareDrivers,
              onTap: () =>
                  onTabChanged(DriverPerformanceTabType.compareDrivers),
            ),
          ),
        ],
      ),
    );
  }
}
