import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/app_shell/widgets/app_bottom_nav_bar.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

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
    @Deprecated('Customer calling is disabled by operations decision')
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
    final initialPage = _stops.length > 1
        ? (300 ~/ _stops.length) * _stops.length + _currentIndex
        : _currentIndex;
    _pageController = PageController(
      viewportFraction: 0.52,
      initialPage: initialPage,
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

  int _closestPageForIndex(int targetIndex) {
    if (!_pageController.hasClients) {
      return _pageController.initialPage;
    }
    final currentPage =
        _pageController.page?.round() ?? _pageController.initialPage;
    final currentModulo =
        _stops.isEmpty ? 0 : currentPage % _stops.length;
    var diff = targetIndex - currentModulo;
    if (_stops.isNotEmpty) {
      if (diff > _stops.length / 2) diff -= _stops.length;
      if (diff < -_stops.length / 2) diff += _stops.length;
    }
    return currentPage + diff;
  }

  void _handleStopSelected(int index) {
    if (index < 0 || index >= _stops.length) return;
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
    if (_pageController.hasClients) {
      final targetPage = _closestPageForIndex(index);
      if (_pageController.page?.round() != targetPage) {
        unawaited(
          _pageController.animateToPage(
            targetPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
        );
      }
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

  void _handleCarouselPageChanged(int index) {
    if (index < 0 || index >= _stops.length) return;
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
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
    if (_stops.length > 1 && _pageController.hasClients) {
      unawaited(
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  void _handleNext() {
    if (_stops.length > 1 && _pageController.hasClients) {
      unawaited(
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  Future<void> _handleAddressPressed(DriverMapStopEntity stop) async {
    if (widget.onAddressTap != null) {
      widget.onAddressTap!();
      return;
    }
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${stop.latitude},${stop.longitude}',
    );
    if (await canLaunchUrl(googleMapsUrl)) {
      await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    final activeStop = _stops.isNotEmpty ? _stops[_currentIndex] : null;

    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final bottomPadding =
        (bottomInset > Spacing.md ? bottomInset : Spacing.md) +
        Spacing.bottomNavHeight +
        Spacing.sm;

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
            bottom: false,
            child: Stack(
              children: [
                if (activeStop != null)
                  PositionedDirectional(
                    top: Spacing.xs,
                    start: Spacing.zero,
                    end: Spacing.zero,
                    child: DriverMapActiveOrderCard(
                      stop: activeStop,
                      onAddressPressed: () => _handleAddressPressed(activeStop),
                    ),
                  ),
                PositionedDirectional(
                  end: Spacing.screenH,
                  top: 168,
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
                    onPageChanged: _handleCarouselPageChanged,
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
