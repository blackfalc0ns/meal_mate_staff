import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/active_delivery_location_entity.dart';
import 'map_floating_action_button.dart';

class DriverTrackingMapView extends StatefulWidget {
  const DriverTrackingMapView({
    super.key,
    required this.initialDriverLocation,
    required this.customerLocation,
    required this.routePoints,
    required this.locationStream,
    this.onCallCustomer,
    this.onMessageCustomer,
  });

  final ActiveDeliveryLocationEntity initialDriverLocation;
  final ActiveDeliveryLocationEntity customerLocation;
  final List<ActiveDeliveryLocationEntity> routePoints;
  final Stream<ActiveDeliveryLocationEntity> locationStream;
  final VoidCallback? onCallCustomer;
  final VoidCallback? onMessageCustomer;

  @override
  State<DriverTrackingMapView> createState() => _DriverTrackingMapViewState();
}

class _DriverTrackingMapViewState extends State<DriverTrackingMapView> {
  GoogleMapController? _mapController;
  StreamSubscription<ActiveDeliveryLocationEntity>? _subscription;
  late ActiveDeliveryLocationEntity _driverLocation;

  @override
  void initState() {
    super.initState();
    _driverLocation = widget.initialDriverLocation;
    _subscription = widget.locationStream.listen(_onLocationUpdate);
  }

  void _onLocationUpdate(ActiveDeliveryLocationEntity newLocation) {
    if (!mounted) return;
    setState(() {
      _driverLocation = newLocation;
    });
    final controller = _mapController;
    if (controller != null) {
      unawaited(
        controller.animateCamera(CameraUpdate.newLatLng(newLocation.toLatLng)),
      );
    }
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    _mapController = null;
    super.dispose();
  }

  void _centerOnDriver() {
    final controller = _mapController;
    if (controller != null) {
      unawaited(
        controller.animateCamera(
          CameraUpdate.newLatLngZoom(_driverLocation.toLatLng, 15.5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('driver'),
        position: _driverLocation.toLatLng,
        rotation: _driverLocation.heading,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),
      Marker(
        markerId: const MarkerId('customer'),
        position: widget.customerLocation.toLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),
    };

    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('tracking_route'),
        points: widget.routePoints.map((p) => p.toLatLng).toList(),
        color: color.primary,
        width: 4,
        patterns: [PatternItem.dash(16), PatternItem.gap(8)],
      ),
    };

    return Container(
      height: 260,
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
                target: _driverLocation.toLatLng,
                zoom: 14.5,
              ),
              onMapCreated: (controller) => _mapController = controller,
              markers: markers,
              polylines: polylines,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),
          PositionedDirectional(
            top: Spacing.sm,
            start: Spacing.sm,
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
            top: Spacing.sm,
            end: Spacing.sm,
            child: MapFloatingActionButton(
              icon: Icons.my_location,
              onPressed: _centerOnDriver,
              backgroundColor: color.surface,
              iconColor: color.primary,
            ),
          ),
          PositionedDirectional(
            bottom: Spacing.sm,
            end: Spacing.sm,
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
