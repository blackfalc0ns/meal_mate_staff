import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_entity.dart';
import '../../domain/entities/dispatcher_driver_view_mode.dart';
import '../../domain/fake_data/dispatcher_drivers_fake_data.dart';
import '../widgets/dispatcher_drivers_area_chips.dart';
import '../widgets/dispatcher_drivers_card.dart';
import '../widgets/dispatcher_drivers_header.dart';
import '../widgets/dispatcher_drivers_kpi_card.dart';
import '../widgets/dispatcher_drivers_map_button.dart';
import '../widgets/dispatcher_drivers_section_header.dart';
import '../widgets/dispatcher_drivers_view_switcher.dart';

class DispatcherDriversScreen extends StatefulWidget {
  const DispatcherDriversScreen({
    super.key,
    this.onSelectDriver,
    this.onBack,
    this.onViewOnMap,
    this.showBottomNavBar = false,
  });

  final ValueChanged<DispatcherDriverEntity>? onSelectDriver;
  final VoidCallback? onBack;
  final VoidCallback? onViewOnMap;
  final bool showBottomNavBar;

  @override
  State<DispatcherDriversScreen> createState() =>
      _DispatcherDriversScreenState();
}

class _DispatcherDriversScreenState extends State<DispatcherDriversScreen> {
  DispatcherDriverViewMode _viewMode = DispatcherDriverViewMode.byArea;
  String _selectedArea = DispatcherDriversFakeData.areas.first;
  bool _sortByDistance = false;

  List<DispatcherDriverEntity> get _filteredDrivers {
    List<DispatcherDriverEntity> list;
    if (_viewMode == DispatcherDriverViewMode.byArea) {
      list = DispatcherDriversFakeData.drivers
          .where((d) => d.area == _selectedArea)
          .toList();
    } else {
      list = List.of(DispatcherDriversFakeData.drivers);
    }

    if (_sortByDistance) {
      list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    }
    return list;
  }

  void _toggleSort() {
    setState(() {
      _sortByDistance = !_sortByDistance;
    });
  }

  void _handleDriverSelected(DispatcherDriverEntity driver) {
    if (widget.onSelectDriver != null) {
      widget.onSelectDriver!(driver);
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(driver);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final drivers = _filteredDrivers;
    final sectionTitle = _viewMode == DispatcherDriverViewMode.byArea
        ? locale.driversSectionTitle(_selectedArea, drivers.length)
        : locale.driversAllSectionTitle(drivers.length);

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DispatcherDriversHeader(onBack: widget.onBack),
              const SizedBox(height: Spacing.xs),
              DispatcherDriversViewSwitcher(
                selectedViewMode: _viewMode,
                onViewModeChanged: (mode) {
                  setState(() {
                    _viewMode = mode;
                  });
                },
              ),
              if (_viewMode == DispatcherDriverViewMode.byArea) ...[
                const SizedBox(height: Spacing.xs),
                DispatcherDriversAreaChips(
                  areas: DispatcherDriversFakeData.areas,
                  selectedArea: _selectedArea,
                  onAreaSelected: (area) {
                    setState(() {
                      _selectedArea = area;
                    });
                  },
                ),
              ],
              const SizedBox(height: Spacing.xs),
              const DispatcherDriversKpiCard(
                kpi: DispatcherDriversFakeData.kpi,
              ),
              const SizedBox(height: Spacing.sm),
              DispatcherDriversSectionHeader(
                title: sectionTitle,
                onSort: _toggleSort,
              ),
              const SizedBox(height: Spacing.xs),
              ...drivers.map(
                (driver) => DispatcherDriversCard(
                  key: ValueKey(driver.id),
                  driver: driver,
                  onSelect: _handleDriverSelected,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              DispatcherDriversMapButton(onTap: widget.onViewOnMap),
              const SizedBox(height: Spacing.base),
            ],
          ),
        ),
      ),
    );
  }
}
