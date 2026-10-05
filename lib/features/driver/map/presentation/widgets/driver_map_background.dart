import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

import '../../domain/entities/driver_map_stop_entity.dart';
import 'driver_map_camera_controller.dart';

class DriverMapBackground extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    final markers = <Marker>{};

    // Live driver moving marker
    if (driverLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('driver_current_location'),
          position: driverLocation!,
          rotation: (driverHeading != null && driverHeading! >= 0 && driverHeading! <= 360)
              ? driverHeading!
              : 0.0,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          infoWindow: const InfoWindow(title: 'موقعك الحالي'),
        ),
      );
    }

    // Static route origin snapshot marker (if distinct from live location)
    if (routeOrigin != null &&
        (driverLocation == null ||
            (routeOrigin!.latitude - driverLocation!.latitude).abs() > 1e-4 ||
            (routeOrigin!.longitude - driverLocation!.longitude).abs() > 1e-4)) {
      markers.add(
        Marker(
          markerId: const MarkerId('route_origin_location'),
          position: routeOrigin!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          infoWindow: InfoWindow(title: routeOriginLabel ?? 'بداية المسار'),
        ),
      );
    }

    // Customer stops markers
    for (int i = 0; i < stops.length; i++) {
      final stop = stops[i];
      if (stop.latitude != null && stop.longitude != null) {
        final isSelected = i == selectedStopIndex;
        markers.add(
          Marker(
            markerId: MarkerId(stop.id),
            position: LatLng(stop.latitude!, stop.longitude!),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isSelected ? BitmapDescriptor.hueViolet : BitmapDescriptor.hueMagenta,
            ),
            infoWindow: InfoWindow(
              title: stop.customerName.isNotEmpty ? stop.customerName : 'وجهة التوصيل',
              snippet: stop.formattedAddress,
            ),
            onTap: () => onMarkerTapped?.call(i),
          ),
        );
      }
    }

    final polylines = <Polyline>{};
    if (routePoints.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('delivery_route'),
          points: routePoints,
          color: color.primary,
          width: 5,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    }

    final initialTarget = driverLocation ??
        routeOrigin ??
        (stops.isNotEmpty && stops.first.latitude != null && stops.first.longitude != null
            ? LatLng(stops.first.latitude!, stops.first.longitude!)
            : DriverMapCameraController.defaultKuwaitCenter);

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialTarget,
        zoom: 14.5,
      ),
      onMapCreated: onMapCreated,
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
