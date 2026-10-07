import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/active_delivery_location_entity.dart';

class StartRouteMapPreview extends StatelessWidget {
  const StartRouteMapPreview({
    super.key,
    this.driverLocation,
    this.customerLocation,
    this.routePoints = const [],
    this.originLatLng,
    this.destinationLatLng,
    this.polylinePoints = const [],
    this.height,
  });

  final ActiveDeliveryLocationEntity? driverLocation;
  final ActiveDeliveryLocationEntity? customerLocation;
  final List<ActiveDeliveryLocationEntity> routePoints;
  final LatLng? originLatLng;
  final LatLng? destinationLatLng;
  final List<LatLng> polylinePoints;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final origin = originLatLng ?? driverLocation?.toLatLng;
    final destination = destinationLatLng ?? customerLocation?.toLatLng;
    final points = polylinePoints.isNotEmpty
        ? polylinePoints
        : routePoints.map((p) => p.toLatLng).toList();

    final markers = <Marker>{
      if (origin != null)
        Marker(
          markerId: const MarkerId('driver'),
          position: origin,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ),
      if (destination != null)
        Marker(
          markerId: const MarkerId('customer'),
          position: destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        ),
    };

    final polylines = <Polyline>{
      if (points.isNotEmpty)
        Polyline(
          polylineId: const PolylineId('route_preview'),
          points: points,
          color: color.primary,
          width: 4,
          patterns: [PatternItem.dash(16), PatternItem.gap(8)],
        )
      else if (origin != null && destination != null)
        Polyline(
          polylineId: const PolylineId('route_preview'),
          points: [origin, destination],
          color: color.primary,
          width: 4,
          patterns: [PatternItem.dash(16), PatternItem.gap(8)],
        ),
    };

    final double centerLat;
    final double centerLng;
    if (origin != null && destination != null) {
      centerLat = (origin.latitude + destination.latitude) / 2;
      centerLng = (origin.longitude + destination.longitude) / 2;
    } else if (origin != null) {
      centerLat = origin.latitude;
      centerLng = origin.longitude;
    } else if (destination != null) {
      centerLat = destination.latitude;
      centerLng = destination.longitude;
    } else {
      centerLat = 24.7136;
      centerLng = 46.6753;
    }

    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
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
          ),
          PositionedDirectional(
            top: Spacing.md,
            start: Spacing.md,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm + 2,
                vertical: Spacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(Spacing.radiusPill),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    locale.driverStartRouteCurrentLocation,
                    style: getMediumStyle(
                      fontSize: FontSize.size10,
                      color: color.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            top: Spacing.md,
            end: Spacing.md,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm + 2,
                vertical: Spacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(Spacing.radiusPill),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.home_rounded,
                    size: Spacing.iconXs,
                    color: color.primary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    locale.driverStartRouteCustomerLocation,
                    style: getMediumStyle(
                      fontSize: FontSize.size10,
                      color: color.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
