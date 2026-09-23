import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/active_delivery_location_entity.dart';

class ReturnBoxMapView extends StatelessWidget {
  const ReturnBoxMapView({
    super.key,
    required this.driverLocation,
    required this.restaurantLocation,
    required this.returnRoutePoints,
  });

  final ActiveDeliveryLocationEntity driverLocation;
  final ActiveDeliveryLocationEntity restaurantLocation;
  final List<ActiveDeliveryLocationEntity> returnRoutePoints;

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
        markerId: const MarkerId('restaurant'),
        position: restaurantLocation.toLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    };

    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('return_route'),
        points: returnRoutePoints.map((p) => p.toLatLng).toList(),
        color: color.secondary,
        width: 4,
      ),
    };

    final centerLat =
        (driverLocation.latitude + restaurantLocation.latitude) / 2;
    final centerLng =
        (driverLocation.longitude + restaurantLocation.longitude) / 2;

    return Container(
      height: 200,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.outline),
      ),
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(centerLat, centerLng),
          zoom: 12.5,
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
