import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_performance_tab_type.dart';
import '../../domain/fake_data/driver_performance_fake_data.dart';
import '../widgets/driver_performance_distribution_card.dart';
import '../widgets/driver_performance_header.dart';
import '../widgets/driver_performance_kpi_list.dart';
import '../widgets/driver_performance_segmented_tabs.dart';
import '../widgets/driver_performance_table_card.dart';
import '../widgets/driver_performance_top_rated_card.dart';

class DispatcherDriverPerformanceScreen extends StatefulWidget {
  const DispatcherDriverPerformanceScreen({super.key});

  @override
  State<DispatcherDriverPerformanceScreen> createState() =>
      _DispatcherDriverPerformanceScreenState();
}

class _DispatcherDriverPerformanceScreenState
    extends State<DispatcherDriverPerformanceScreen> {
  DriverPerformanceTabType _selectedTab = DriverPerformanceTabType.overview;

  void _onTabChanged(DriverPerformanceTabType tab) {
    if (_selectedTab == tab) return;
    setState(() {
      _selectedTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surfaceContainerLowest,
      appBar: const DriverPerformanceHeader(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.base,
            vertical: Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DriverPerformanceSegmentedTabs(
                selectedTab: _selectedTab,
                onTabChanged: _onTabChanged,
              ),
              const SizedBox(height: Spacing.md),
              const DriverPerformanceKpiList(
                items: DriverPerformanceFakeData.kpiItems,
              ),
              const SizedBox(height: Spacing.md),
              const DriverPerformanceTableCard(
                drivers: DriverPerformanceFakeData.drivers,
              ),
              const SizedBox(height: Spacing.md),
              const DriverPerformanceDistributionCard(
                items: DriverPerformanceFakeData.distribution,
                totalBoxes: DriverPerformanceFakeData.totalBoxesCount,
              ),
              const SizedBox(height: Spacing.md),
              const DriverPerformanceTopRatedCard(
                entries: DriverPerformanceFakeData.topRatedDrivers,
              ),
              const SizedBox(height: Spacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
