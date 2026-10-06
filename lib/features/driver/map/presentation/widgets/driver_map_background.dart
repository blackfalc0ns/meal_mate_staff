import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

import '../../domain/entities/driver_map_stop_entity.dart';
import 'driver_map_camera_controller.dart';
import 'driver_map_marker_bitmap_factory.dart';

class DriverMapBackground extends StatefulWidget {
  const DriverMapBackground({
    super.key,
    this.driverLocation,
    this.driverHeading,
    this.routeOrigin,
    this.routeOriginLabel,
    required this.stops,
    required this.routePoints,
    required this.selectedStopIndex,
    this.onMapCreated,
    this.onMarkerTapped,
  });

  final LatLng? driverLocation;
  final double? driverHeading;
  final LatLng? routeOrigin;
  final String? routeOriginLabel;
  final List<DriverMapStopEntity> stops;
  final List<LatLng> routePoints;
  final int selectedStopIndex;
  final ValueChanged<GoogleMapController>? onMapCreated;
  final ValueChanged<int>? onMarkerTapped;

  @override
  State<DriverMapBackground> createState() => _DriverMapBackgroundState();
}

class _DriverMapBackgroundState extends State<DriverMapBackground> {
  BitmapDescriptor? _driverDescriptor;
  final Map<String, BitmapDescriptor> _stopDescriptors = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_resolveMarkers());
      }
    });
  }

  @override
  void didUpdateWidget(covariant DriverMapBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.stops != widget.stops ||
        oldWidget.selectedStopIndex != widget.selectedStopIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(_resolveMarkers());
        }
      });
    }
  }

  Future<void> _resolveMarkers() async {
    final driverDescriptor =
        await DriverMapMarkerBitmapFactory.createDriverMarker(context);

    if (!mounted) return;

    if (_driverDescriptor != driverDescriptor) {
      setState(() {
        _driverDescriptor = driverDescriptor;
      });
    }

    for (int i = 0; i < widget.stops.length; i++) {
      if (!mounted) return;
      final stop = widget.stops[i];
      final isSelected = i == widget.selectedStopIndex;
      final descriptor = await DriverMapMarkerBitmapFactory.createStopMarker(
        context,
        stopId: stop.id,
        boxCode: stop.boxCode,
        isSelected: isSelected,
      );

      if (!mounted) return;

      final key = DriverMapMarkerBitmapFactory.stopCacheKey(
        stop.id,
        stop.boxCode,
        isSelected: isSelected,
      );
      if (_stopDescriptors[key] != descriptor) {
        setState(() {
          _stopDescriptors[key] = descriptor;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final markers = <Marker>{};

    // Live driver moving marker
    if (widget.driverLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver_current_location'),
          position: widget.driverLocation!,
          anchor: const Offset(0.5, 0.95),
          icon: _driverDescriptor ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: InfoWindow(
            title: locale.driverMapYourLocation,
          ),
        ),
      );
    }

    // Static route origin snapshot marker (if distinct from live location)
    if (widget.routeOrigin != null &&
        (widget.driverLocation == null ||
            (widget.routeOrigin!.latitude - widget.driverLocation!.latitude).abs() > 1e-4 ||
            (widget.routeOrigin!.longitude - widget.driverLocation!.longitude).abs() > 1e-4)) {
      markers.add(
        Marker(
          markerId: const MarkerId('route_origin_location'),
          position: widget.routeOrigin!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          infoWindow: InfoWindow(
            title: widget.routeOriginLabel ?? locale.driverMapYourLocation,
          ),
        ),
      );
    }

    // Customer stops markers
    for (int i = 0; i < widget.stops.length; i++) {
      final stop = widget.stops[i];
      if (stop.latitude != null && stop.longitude != null) {
        final isSelected = i == widget.selectedStopIndex;
        final stopKey = DriverMapMarkerBitmapFactory.stopCacheKey(
          stop.id,
          stop.boxCode,
          isSelected: isSelected,
        );
        final descriptor = _stopDescriptors[stopKey];

        markers.add(
          Marker(
            markerId: MarkerId(stop.id),
            position: LatLng(stop.latitude!, stop.longitude!),
            anchor: const Offset(0.5, 1.0),
            zIndexInt: isSelected ? 2 : 1,
            icon: descriptor ??
                BitmapDescriptor.defaultMarkerWithHue(
                  isSelected ? BitmapDescriptor.hueViolet : BitmapDescriptor.hueMagenta,
                ),
            infoWindow: InfoWindow(
              title: stop.customerName.isNotEmpty
                  ? stop.customerName
                  : locale.driverMapDeliveryDestination,
              snippet: stop.formattedAddress,
            ),
            onTap: () => widget.onMarkerTapped?.call(i),
          ),
        );
      }
    }

    final polylines = <Polyline>{};
    if (widget.routePoints.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('delivery_route'),
          points: widget.routePoints,
          color: color.primary,
          width: 5,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    }

    final initialTarget = widget.driverLocation ??
        widget.routeOrigin ??
        (widget.stops.isNotEmpty &&
                widget.stops.first.latitude != null &&
                widget.stops.first.longitude != null
            ? LatLng(widget.stops.first.latitude!, widget.stops.first.longitude!)
            : DriverMapCameraController.defaultKuwaitCenter);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialTarget,
        zoom: 14.5,
      ),
      onMapCreated: widget.onMapCreated,
      markers: markers,
      polylines: polylines,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      compassEnabled: false,
      mapToolbarEnabled: false,
      padding: const EdgeInsets.only(
        top: 220,
        bottom: Spacing.bottomNavHeight + 180,
      ),
    );
  }
}
