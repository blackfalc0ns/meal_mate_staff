import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/map_markers/map_markers.dart';
import '../../domain/entities/active_delivery_location_entity.dart';

class StartRouteMapPreview extends StatefulWidget {
  const StartRouteMapPreview({
    super.key,
    this.driverLocation,
    this.customerLocation,
    this.routePoints = const [],
    this.originLatLng,
    this.destinationLatLng,
    this.polylinePoints = const [],
    this.height,
    this.boxCode,
  });

  final ActiveDeliveryLocationEntity? driverLocation;
  final ActiveDeliveryLocationEntity? customerLocation;
  final List<ActiveDeliveryLocationEntity> routePoints;
  final LatLng? originLatLng;
  final LatLng? destinationLatLng;
  final List<LatLng> polylinePoints;
  final double? height;
  final String? boxCode;

  @override
  State<StartRouteMapPreview> createState() => _StartRouteMapPreviewState();
}

class _StartRouteMapPreviewState extends State<StartRouteMapPreview> {
  GoogleMapController? _mapController;
  BitmapDescriptor? _driverDescriptor;
  BitmapDescriptor? _customerDescriptor;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_resolveMarkers());
      }
    });
  }

  @override
  void didUpdateWidget(covariant StartRouteMapPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.boxCode != widget.boxCode ||
        _driverDescriptor == null ||
        _customerDescriptor == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          unawaited(_resolveMarkers());
        }
      });
    }

    final newOrigin = widget.originLatLng ?? widget.driverLocation?.toLatLng;
    final oldOrigin =
        oldWidget.originLatLng ?? oldWidget.driverLocation?.toLatLng;
    if (newOrigin != null && (newOrigin != oldOrigin || oldOrigin == null)) {
      final controller = _mapController;
      if (controller != null) {
        unawaited(
          controller.animateCamera(
            CameraUpdate.newLatLngZoom(newOrigin, 15.0),
          ),
        );
      }
    }
  }

  Future<void> _resolveMarkers() async {
    final driverDescriptor =
        await AppMapMarkerBitmapFactory.createDriverMarker(context);
    if (!mounted) return;
    final customerDescriptor =
        await AppMapMarkerBitmapFactory.createStopMarker(
      context,
      boxCode: widget.boxCode ?? '',
      isSelected: true,
    );

    if (!mounted) return;

    if (_driverDescriptor != driverDescriptor ||
        _customerDescriptor != customerDescriptor) {
      setState(() {
        _driverDescriptor = driverDescriptor;
        _customerDescriptor = customerDescriptor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final origin = widget.originLatLng ?? widget.driverLocation?.toLatLng;
    final destination =
        widget.destinationLatLng ?? widget.customerLocation?.toLatLng;
    final points = widget.polylinePoints.isNotEmpty
        ? widget.polylinePoints
        : widget.routePoints.map((p) => p.toLatLng).toList();

    final markers = <Marker>{
      if (origin != null)
        Marker(
          markerId: const MarkerId('driver'),
          position: origin,
          anchor: const Offset(0.5, 0.95),
          icon: _driverDescriptor ??
              BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet,
              ),
        ),
      if (destination != null)
        Marker(
          markerId: const MarkerId('customer'),
          position: destination,
          anchor: const Offset(0.5, 1.0),
          icon: _customerDescriptor ??
              BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet,
              ),
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

    // Center camera on driver's current location when available
    final LatLng initialTarget = origin ??
        destination ??
        const LatLng(29.3759, 47.9774); // Default Kuwait City center

    return Container(
      height: widget.height,
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
                target: initialTarget,
                zoom: origin != null ? 15.0 : 13.5,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                if (origin != null) {
                  unawaited(
                    controller.animateCamera(
                      CameraUpdate.newLatLngZoom(origin, 15.0),
                    ),
                  );
                }
              },
              myLocationEnabled: true,
              markers: markers,
              polylines: polylines,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
            ),
          ),

        ],
      ),
    );
  }
}
