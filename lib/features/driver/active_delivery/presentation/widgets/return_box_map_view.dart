import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/map_markers/map_markers.dart';
import '../../domain/entities/active_delivery_location_entity.dart';

class ReturnBoxMapView extends StatefulWidget {
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
  State<ReturnBoxMapView> createState() => _ReturnBoxMapViewState();
}

class _ReturnBoxMapViewState extends State<ReturnBoxMapView> {
  BitmapDescriptor? _driverDescriptor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_resolveMarkers());
      }
    });
  }

  Future<void> _resolveMarkers() async {
    final driverDescriptor =
        await AppMapMarkerBitmapFactory.createDriverMarker(context);
    if (!mounted) return;
    if (_driverDescriptor != driverDescriptor) {
      setState(() {
        _driverDescriptor = driverDescriptor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('driver'),
        position: widget.driverLocation.toLatLng,
        anchor: const Offset(0.5, 0.95),
        icon: _driverDescriptor ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),
      Marker(
        markerId: const MarkerId('restaurant'),
        position: widget.restaurantLocation.toLatLng,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    };

    final polylines = <Polyline>{
      Polyline(
        polylineId: const PolylineId('return_route'),
        points: widget.returnRoutePoints.map((p) => p.toLatLng).toList(),
        color: color.secondary,
        width: 4,
      ),
    };

    final centerLat =
        (widget.driverLocation.latitude + widget.restaurantLocation.latitude) / 2;
    final centerLng =
        (widget.driverLocation.longitude + widget.restaurantLocation.longitude) / 2;

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
