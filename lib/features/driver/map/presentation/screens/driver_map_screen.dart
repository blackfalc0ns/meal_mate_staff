import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/app_shell/widgets/app_bottom_nav_bar.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

import '../../data/datasources/driver_map_fake_datasource.dart';
import '../../domain/entities/driver_map_stop_entity.dart';
import '../widgets/driver_map_active_order_card.dart';
import '../widgets/driver_map_background.dart';
import '../widgets/driver_map_recenter_button.dart';
import '../widgets/driver_map_stops_carousel.dart';

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({
    super.key,
    this.initialStops,
    this.initialDriverLocation,
    this.initialRoutePoints,
    this.showBottomNavBar = false,
    this.onCallCustomer,
    this.onAddressTap,
  });

  final List<DriverMapStopEntity>? initialStops;
  final LatLng? initialDriverLocation;
  final List<LatLng>? initialRoutePoints;
  final bool showBottomNavBar;
  final VoidCallback? onCallCustomer;
  final VoidCallback? onAddressTap;

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  late final List<DriverMapStopEntity> _stops;
  late final LatLng _driverLocation;
  late final List<LatLng> _routePoints;
  late final PageController _pageController;

  GoogleMapController? _mapController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _stops = widget.initialStops ?? DriverMapFakeDataSource.sampleStops;
    _driverLocation =
        widget.initialDriverLocation ??
        DriverMapFakeDataSource.driverInitialLocation;
    _routePoints =
        widget.initialRoutePoints ?? DriverMapFakeDataSource.sampleRoutePoints;
    _pageController = PageController(
      viewportFraction: 0.62,
      initialPage: _currentIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _mapController = null;
    super.dispose();
  }

  void _handleMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _handleRecenter() {
    final controller = _mapController;
    if (controller != null) {
      unawaited(
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(_driverLocation, 14.5),
        ),
      );
    }
  }

  void _handleStopSelected(int index) {
    if (index < 0 || index >= _stops.length) return;
    setState(() {
      _currentIndex = index;
    });
    if (_pageController.hasClients &&
        _pageController.page?.round() != index) {
      unawaited(
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
      );
    }
    final stop = _stops[index];
    final controller = _mapController;
    if (controller != null) {
      unawaited(
        controller.animateCamera(
          CameraUpdate.newLatLng(LatLng(stop.latitude, stop.longitude)),
        ),
      );
    }
  }

  void _handlePrevious() {
    if (_currentIndex > 0) {
      _handleStopSelected(_currentIndex - 1);
    }
  }

  void _handleNext() {
    if (_currentIndex < _stops.length - 1) {
      _handleStopSelected(_currentIndex + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    final activeStop = _stops.isNotEmpty ? _stops[_currentIndex] : null;

    final bottomPadding = widget.showBottomNavBar
        ? Spacing.bottomNavHeight + Spacing.sm
        : Spacing.bottomNavHeight + Spacing.sm;

    return Scaffold(
      backgroundColor: color.surface,
      extendBody: true,
      bottomNavigationBar: widget.showBottomNavBar
          ? AppBottomNavBar(
              selectedIndex: 2,
              onItemSelected: (index) {
                if (index != 2 && Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              },
            )
          : null,
      body: Stack(
        children: [
          Positioned.fill(
            child: DriverMapBackground(
              driverLocation: _driverLocation,
              stops: _stops,
              routePoints: _routePoints,
              selectedStopIndex: _currentIndex,
              onMapCreated: _handleMapCreated,
              onMarkerTapped: _handleStopSelected,
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                if (activeStop != null)
                  PositionedDirectional(
                    top: Spacing.xs,
                    start: Spacing.zero,
                    end: Spacing.zero,
                    child: DriverMapActiveOrderCard(
                      stop: activeStop,
                      onCallPressed: widget.onCallCustomer,
                      onAddressPressed: widget.onAddressTap,
                    ),
                  ),
                PositionedDirectional(
                  end: Spacing.screenH,
                  bottom: bottomPadding + 240,
                  child: DriverMapRecenterButton(
                    onPressed: _handleRecenter,
                  ),
                ),
                PositionedDirectional(
                  start: Spacing.zero,
                  end: Spacing.zero,
                  bottom: bottomPadding,
                  child: DriverMapStopsCarousel(
                    stops: _stops,
                    currentIndex: _currentIndex,
                    pageController: _pageController,
                    onPageChanged: _handleStopSelected,
                    onPrevious: _handlePrevious,
                    onNext: _handleNext,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
