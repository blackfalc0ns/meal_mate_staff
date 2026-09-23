import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_current_location_entity.dart';
import '../../domain/entities/driver_location_point_entity.dart';

class DriverDetailsMapPresentationHelper {
  const DriverDetailsMapPresentationHelper._();

  static Set<Marker> buildMarkers({
    required double driverLat,
    required double driverLng,
    double? destLat,
    double? destLng,
    double? heading,
  }) {
    final markers = <Marker>{
      Marker(
        markerId: const MarkerId('driver'),
        position: LatLng(driverLat, driverLng),
        rotation: heading ?? 0.0,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
      ),
    };

    if (destLat != null && destLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position: LatLng(destLat, destLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    return markers;
  }

  static Set<Polyline> buildPolylines(
    List<DriverLocationPointEntity> routePoints, {
    required Color polylineColor,
  }) {
    if (routePoints.length < 2) {
      return const <Polyline>{};
    }

    return {
      Polyline(
        polylineId: const PolylineId('driver_route'),
        points: routePoints
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList(growable: false),
        color: polylineColor,
        width: 4,
      ),
    };
  }

  static LatLngBounds? calculateBounds({
    required double driverLat,
    required double driverLng,
    double? destLat,
    double? destLng,
    List<DriverLocationPointEntity> routePoints = const [],
  }) {
    final points = <LatLng>[LatLng(driverLat, driverLng)];

    if (destLat != null && destLng != null) {
      points.add(LatLng(destLat, destLng));
    }

    for (final rp in routePoints) {
      points.add(LatLng(rp.latitude, rp.longitude));
    }

    if (points.length < 2) {
      return null;
    }

    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    // In case all points are identical
    if (minLat == maxLat && minLng == maxLng) {
      return null;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
}

class DriverDetailsMiniMap extends StatefulWidget {
  const DriverDetailsMiniMap({
    super.key,
    required this.location,
    this.height = 130.0,
  });

  final DriverCurrentLocationEntity location;
  final double height;

  @override
  State<DriverDetailsMiniMap> createState() => _DriverDetailsMiniMapState();
}

class _DriverDetailsMiniMapState extends State<DriverDetailsMiniMap> {
  GoogleMapController? _mapController;

  @override
  void didUpdateWidget(covariant DriverDetailsMiniMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_mapController != null && !widget.location.isOffline) {
      _updateCamera();
    }
  }

  void _updateCamera() {
    final lat = widget.location.latitude;
    final lng = widget.location.longitude;
    if (lat == null || lng == null) return;

    final bounds = DriverDetailsMapPresentationHelper.calculateBounds(
      driverLat: lat,
      driverLng: lng,
      destLat: widget.location.destinationLatitude,
      destLng: widget.location.destinationLongitude,
      routePoints: widget.location.routePoints,
    );

    if (bounds != null) {
      _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 24.0));
    } else {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(lat, lng), 14.5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.location.isOffline) {
      return const SizedBox.shrink();
    }

    final color = context.colorScheme;
    final driverLat = widget.location.latitude!;
    final driverLng = widget.location.longitude!;

    final markers = DriverDetailsMapPresentationHelper.buildMarkers(
      driverLat: driverLat,
      driverLng: driverLng,
      destLat: widget.location.destinationLatitude,
      destLng: widget.location.destinationLongitude,
      heading: widget.location.heading,
    );

    final polylines = DriverDetailsMapPresentationHelper.buildPolylines(
      widget.location.routePoints,
      polylineColor: color.primary,
    );

    return SizedBox(
      height: widget.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(driverLat, driverLng),
            zoom: 14.5,
          ),
          markers: markers,
          polylines: polylines,
          onMapCreated: (controller) {
            _mapController = controller;
            _updateCamera();
          },
          zoomControlsEnabled: false,
          zoomGesturesEnabled: false,
          scrollGesturesEnabled: false,
          rotateGesturesEnabled: false,
          tiltGesturesEnabled: false,
          myLocationButtonEnabled: false,
          compassEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }
}
