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
    final locale = context.localization;

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('driver'),
        position: driverLocation.toLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),
      Marker(
        markerId: const MarkerId('customer'),
        position: customerLocation.toLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),
    };

    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('route_preview'),
        points: routePoints.map((p) => p.toLatLng).toList(),
        color: color.primary,
        width: 4,
        patterns: [PatternItem.dash(16), PatternItem.gap(8)],
      ),
    };

    final centerLat = (driverLocation.latitude + customerLocation.latitude) / 2;
    final centerLng =
        (driverLocation.longitude + customerLocation.longitude) / 2;

    return Container(
      height: 248,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(color: color.outlineVariant),
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
                horizontal: Spacing.sm,
                vertical: Spacing.xs,
              ),
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
                boxShadow: [
                  BoxShadow(
                    color: color.shadow.withValues(alpha: 0.08),
                    blurRadius: 4,
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
                horizontal: Spacing.sm,
                vertical: Spacing.xs,
              ),
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
                boxShadow: [
                  BoxShadow(
                    color: color.shadow.withValues(alpha: 0.08),
                    blurRadius: 4,
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
