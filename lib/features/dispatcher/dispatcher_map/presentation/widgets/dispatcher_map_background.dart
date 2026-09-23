import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../config/theme/spacing.dart';
import '../../domain/entities/dispatcher_map_driver_entity.dart';
import 'dispatcher_map_camera_controller.dart';
import 'dispatcher_map_driver_marker_factory.dart';

class DispatcherMapBackground extends StatefulWidget {
  const DispatcherMapBackground({
    super.key,
    required this.drivers,
    this.selectedDriverId,
    this.onSelectDriver,
    this.cameraController,
    this.onMapCreated,
  });

  final List<DispatcherMapDriverEntity> drivers;
  final String? selectedDriverId;
  final ValueChanged<DispatcherMapDriverEntity>? onSelectDriver;
  final DispatcherMapCameraController? cameraController;
  final ValueChanged<GoogleMapController>? onMapCreated;

  @override
  State<DispatcherMapBackground> createState() =>
      _DispatcherMapBackgroundState();
}

class _DispatcherMapBackgroundState extends State<DispatcherMapBackground>
    with TickerProviderStateMixin {
  final Map<String, _DriverMarkerAnimator> _animators = {};
  final Map<String, BitmapDescriptor> _descriptors = {};
  Set<Marker> _markers = {};
  GoogleMapController? _rawController;
  bool _hasInitialFit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncDrivers(isInitial: true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant DispatcherMapBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncDrivers(isInitial: false);
  }

  void _syncDrivers({required bool isInitial}) {
    final validDriverIds = <String>{};

    for (final driver in widget.drivers) {
      if (!_isValidCoordinate(driver.latitude, driver.longitude)) continue;
      validDriverIds.add(driver.id);

      final target = LatLng(driver.latitude!, driver.longitude!);
      var animator = _animators[driver.id];

      if (animator == null) {
        animator = _DriverMarkerAnimator(
          driverId: driver.id,
          vsync: this,
          initialPosition: target,
          onPositionUpdate: () {
            if (mounted) _rebuildMarkers();
          },
        );
        _animators[driver.id] = animator;
      } else {
        animator.animateTo(target);
      }

      _resolveBitmap(driver);
    }

    // Clean up removed drivers
    final toRemove = _animators.keys
        .where((id) => !validDriverIds.contains(id))
        .toList();
    for (final id in toRemove) {
      _animators[id]?.dispose();
      _animators.remove(id);
      _descriptors.remove(id);
    }

    _rebuildMarkers();
  }

  bool _isValidCoordinate(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (!lat.isFinite || !lng.isFinite) return false;
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  Future<void> _resolveBitmap(DispatcherMapDriverEntity driver) async {
    final isSelected = driver.id == widget.selectedDriverId;
    final descriptor = await DispatcherMapMarkerBitmapFactory.create(
      context,
      driver,
      isSelected: isSelected,
    );

    if (mounted) {
      final old = _descriptors[driver.id];
      if (old != descriptor) {
        _descriptors[driver.id] = descriptor;
        _rebuildMarkers();
      }
    }
  }

  void _rebuildMarkers() {
    final newMarkers = <Marker>{};

    for (final driver in widget.drivers) {
      final animator = _animators[driver.id];
      if (animator == null) continue;

      final isSelected = driver.id == widget.selectedDriverId;
      final descriptor =
          _descriptors[driver.id] ?? BitmapDescriptor.defaultMarker;

      newMarkers.add(
        Marker(
          markerId: MarkerId(driver.id),
          position: animator.currentPosition,
          icon: descriptor,
          zIndexInt: isSelected ? 2 : 1,
          onTap: () => widget.onSelectDriver?.call(driver),
        ),
      );
    }

    setState(() {
      _markers = newMarkers;
    });
  }

  CameraPosition _initialCameraPosition() {
    for (final driver in widget.drivers) {
      if (_isValidCoordinate(driver.latitude, driver.longitude)) {
        return CameraPosition(
          target: LatLng(driver.latitude!, driver.longitude!),
          zoom: 14.0,
        );
      }
    }
    // Default fallback (e.g. Riyadh center)
    return const CameraPosition(target: LatLng(24.7136, 46.6753), zoom: 12.0);
  }

  void _handleMapCreated(GoogleMapController controller) {
    _rawController = controller;
    if (widget.cameraController is GoogleMapCameraControllerImpl) {
      (widget.cameraController! as GoogleMapCameraControllerImpl).attach(
        controller,
      );
    }
    widget.onMapCreated?.call(controller);

    if (!_hasInitialFit && widget.drivers.isNotEmpty) {
      _hasInitialFit = true;
      widget.cameraController?.fitDrivers(widget.drivers);
    }
  }

  @override
  void dispose() {
    for (final animator in _animators.values) {
      animator.dispose();
    }
    _animators.clear();
    if (widget.cameraController is GoogleMapCameraControllerImpl) {
      (widget.cameraController! as GoogleMapCameraControllerImpl).detach();
    }
    _rawController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: _initialCameraPosition(),
      markers: _markers,
      onMapCreated: _handleMapCreated,
      zoomControlsEnabled: false,
      myLocationEnabled: false,
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      padding: const EdgeInsets.only(
        top: 200,
        bottom: Spacing.dispatcherMapBottomCarouselHeight + Spacing.lg,
      ),
    );
  }
}

class _DriverMarkerAnimator {
  _DriverMarkerAnimator({
    required this.driverId,
    required TickerProvider vsync,
    required LatLng initialPosition,
    required this.onPositionUpdate,
  }) : _start = initialPosition,
       _target = initialPosition,
       _current = initialPosition {
    _controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 250),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
      ..addListener(_handleTick);
  }

  final String driverId;
  final VoidCallback onPositionUpdate;

  late final AnimationController _controller;
  late final Animation<double> _animation;

  LatLng _start;
  LatLng _target;
  LatLng _current;

  LatLng get currentPosition => _current;

  void animateTo(LatLng newTarget) {
    if ((newTarget.latitude - _target.latitude).abs() < 0.000001 &&
        (newTarget.longitude - _target.longitude).abs() < 0.000001) {
      return;
    }

    _start = _current;
    _target = newTarget;
    _controller.forward(from: 0.0);
  }

  void _handleTick() {
    final t = _animation.value;
    final lat =
        ui.lerpDouble(_start.latitude, _target.latitude, t) ?? _target.latitude;
    final lng =
        ui.lerpDouble(_start.longitude, _target.longitude, t) ??
        _target.longitude;
    _current = LatLng(lat, lng);
    onPositionUpdate();
  }

  void dispose() {
    _controller.dispose();
  }
}
