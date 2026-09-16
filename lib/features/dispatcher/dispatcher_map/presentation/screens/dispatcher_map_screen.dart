import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_map_driver_marker_entity.dart';
import '../../domain/fake_data/dispatcher_map_fake_data.dart';
import '../widgets/dispatcher_map_background.dart';
import '../widgets/dispatcher_map_controls.dart';
import '../widgets/dispatcher_map_drivers_carousel.dart';
import '../widgets/dispatcher_map_header.dart';
import '../widgets/dispatcher_map_kpi_bar.dart';

class DispatcherMapScreen extends StatefulWidget {
  const DispatcherMapScreen({
    super.key,
    this.onBack,
    this.showBottomNavBar = false,
  });

  final VoidCallback? onBack;
  final bool showBottomNavBar;

  @override
  State<DispatcherMapScreen> createState() => _DispatcherMapScreenState();
}

class _DispatcherMapScreenState extends State<DispatcherMapScreen> {
  String? _selectedDriverId;

  @override
  void initState() {
    super.initState();
    if (DispatcherMapFakeData.drivers.isNotEmpty) {
      _selectedDriverId = DispatcherMapFakeData.drivers.first.id;
    }
  }

  void _handleDriverSelected(DispatcherMapDriverMarkerEntity driver) {
    setState(() {
      _selectedDriverId = driver.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      body: Stack(
        children: [
          Positioned.fill(
            child: DispatcherMapBackground(
              drivers: DispatcherMapFakeData.drivers,
              selectedDriverId: _selectedDriverId,
              onSelectDriver: _handleDriverSelected,
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    color.surface,
                    color.surface.withValues(alpha: 0.9),
                    color.surface.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.75, 1.0],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DispatcherMapHeader(
                      onMenuTap: widget.onBack,
                    ),
                    const SizedBox(height: Spacing.xs),
                    const DispatcherMapKpiBar(
                      kpi: DispatcherMapFakeData.kpi,
                    ),
                    const SizedBox(height: Spacing.base),
                  ],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            end: Spacing.base,
            bottom: Spacing.dispatcherMapBottomCarouselHeight + Spacing.lg,
            child: const DispatcherMapControls(),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: DispatcherMapDriversCarousel(
                drivers: DispatcherMapFakeData.drivers,
                selectedDriverId: _selectedDriverId,
                onSelectDriver: _handleDriverSelected,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
