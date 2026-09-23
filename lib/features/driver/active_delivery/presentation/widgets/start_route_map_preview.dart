import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/active_delivery_location_entity.dart';

class StartRouteMapPreview extends StatelessWidget {
  const StartRouteMapPreview({
    super.key,
    required this.driverLocation,
    required this.customerLocation,
    required this.routePoints,
  });

  final ActiveDeliveryLocationEntity driverLocation;
  final ActiveDeliveryLocationEntity customerLocation;
  final List<ActiveDeliveryLocationEntity> routePoints;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('driver'),
        position: driverLocation.toLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),
      Marker(
        markerId: const MarkerId('customer'),
        position: customerLocation.toLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    };

    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('route_preview'),
        points: routePoints.map((p) => p.toLatLng).toList(),
        color: color.primary,
        width: 4,
      ),
    };

    final centerLat = (driverLocation.latitude + customerLocation.latitude) / 2;
    final centerLng =
        (driverLocation.longitude + customerLocation.longitude) / 2;

    return Container(
      height: 220,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.outline),
      ),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(centerLat, centerLng),
          zoom: 13.5,
        ),
        markers: markers,
        polylines: polylines,
        zoomControlsEnabled: false,
        myLocationButtonEnabled: false,
        compassEnabled: false,
        mapToolbarEnabled: false,
      ),
    );
  }
}
