import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_entity.dart';
import '../../domain/entities/dispatcher_driver_view_mode.dart';
import '../../domain/fake_data/dispatcher_drivers_fake_data.dart';
import '../widgets/dispatcher_drivers_area_chips.dart';
import '../widgets/dispatcher_drivers_content_list.dart';
import '../widgets/dispatcher_drivers_header.dart';
import '../widgets/dispatcher_drivers_kpi_card.dart';
import '../widgets/dispatcher_drivers_map_button.dart';
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
  bool _isTransitionReversed = false;

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

  void _handleAreaSelected(String area) {
    if (area == _selectedArea) return;
    final oldIndex = DispatcherDriversFakeData.areas.indexOf(_selectedArea);
    final newIndex = DispatcherDriversFakeData.areas.indexOf(area);
    setState(() {
      _isTransitionReversed = newIndex < oldIndex;
      _selectedArea = area;
    });
  }

  void _handleViewModeChanged(DispatcherDriverViewMode mode) {
    if (mode == _viewMode) return;
    setState(() {
      _isTransitionReversed = mode == DispatcherDriverViewMode.byArea;
      _viewMode = mode;
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
                onViewModeChanged: _handleViewModeChanged,
              ),
              if (_viewMode == DispatcherDriverViewMode.byArea) ...[
                const SizedBox(height: Spacing.xs),
                DispatcherDriversAreaChips(
                  areas: DispatcherDriversFakeData.areas,
                  selectedArea: _selectedArea,
                  onAreaSelected: _handleAreaSelected,
                ),
              ],
              const SizedBox(height: Spacing.xs),
              const DispatcherDriversKpiCard(
                kpi: DispatcherDriversFakeData.kpi,
              ),
              const SizedBox(height: Spacing.sm),
              DispatcherDriversContentList(
                transitionKey: '$_viewMode-$_selectedArea',
                isTransitionReversed: _isTransitionReversed,
                sectionTitle: sectionTitle,
                drivers: drivers,
                onSort: _toggleSort,
                onSelectDriver: _handleDriverSelected,
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
