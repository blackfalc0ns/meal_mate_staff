import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

import '../../domain/entities/driver_map_stop_entity.dart';

class DriverMapBackground extends StatelessWidget {
  const DriverMapBackground({
    super.key,
    required this.driverLocation,
    required this.stops,
    required this.routePoints,
    required this.selectedStopIndex,
    this.onMapCreated,
    this.onMarkerTapped,
  });

  final LatLng driverLocation;
  final List<DriverMapStopEntity> stops;
  final List<LatLng> routePoints;
  final int selectedStopIndex;
  final ValueChanged<GoogleMapController>? onMapCreated;
  final ValueChanged<int>? onMarkerTapped;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('driver_current_location'),
        position: driverLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),
      for (int i = 0; i < stops.length; i++)
        Marker(
          markerId: MarkerId(stops[i].id),
          position: LatLng(stops[i].latitude, stops[i].longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == selectedStopIndex
                ? BitmapDescriptor.hueViolet
                : BitmapDescriptor.hueMagenta,
          ),
          onTap: () => onMarkerTapped?.call(i),
        ),
    };

    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('delivery_route'),
        points: routePoints,
        color: color.primary,
        width: 4,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: driverLocation,
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
