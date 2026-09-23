import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../config/theme/spacing.dart';
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

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('driver'),
        position: _driverLocation.toLatLng,
        rotation: _driverLocation.heading,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: const InfoWindow(title: 'السائق'),
      ),
      Marker(
        markerId: const MarkerId('customer'),
        position: widget.customerLocation.toLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        infoWindow: const InfoWindow(title: 'العميل'),
      ),
    };

    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('tracking_route'),
        points: widget.routePoints.map((p) => p.toLatLng).toList(),
        color: color.primary,
        width: 5,
      ),
    };

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _driverLocation.toLatLng,
            zoom: 15.0,
          ),
          onMapCreated: (controller) => _mapController = controller,
          markers: markers,
          polylines: polylines,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
        ),
        PositionedDirectional(
          top: Spacing.base,
          end: Spacing.base,
          child: Column(
            children: [
              MapFloatingActionButton(
                icon: Icons.my_location,
                onPressed: _centerOnDriver,
                backgroundColor: color.surface,
                iconColor: color.primary,
              ),
              if (widget.onCallCustomer != null) ...[
                const SizedBox(height: Spacing.sm),
                MapFloatingActionButton(
                  icon: Icons.phone,
                  onPressed: widget.onCallCustomer!,
                  backgroundColor: color.surface,
                  iconColor: color.tertiary,
                ),
              ],
              if (widget.onMessageCustomer != null) ...[
                const SizedBox(height: Spacing.sm),
                MapFloatingActionButton(
                  icon: Icons.chat_bubble_outline,
                  onPressed: widget.onMessageCustomer!,
                  backgroundColor: color.surface,
                  iconColor: color.primary,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
