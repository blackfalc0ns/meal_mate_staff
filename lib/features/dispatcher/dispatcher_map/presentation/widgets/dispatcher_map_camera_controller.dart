import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/dispatcher_map_driver_entity.dart';

abstract class DispatcherMapCameraController {
  Future<void> animateCamera(CameraUpdate cameraUpdate);
  Future<void> zoomIn();
  Future<void> zoomOut();
  Future<void> centerOn(LatLng coordinate, {double zoom = 15.0});
  Future<void> fitDrivers(
    List<DispatcherMapDriverEntity> drivers, {
    double padding = 60,
  });
}

class GoogleMapCameraControllerImpl implements DispatcherMapCameraController {
  GoogleMapController? _controller;

  void attach(GoogleMapController controller) {
    _controller = controller;
  }

  void detach() {
    _controller = null;
  }

  bool get isAttached => _controller != null;

  @override
  Future<void> animateCamera(CameraUpdate cameraUpdate) async {
    final c = _controller;
    if (c != null) {
      await c.animateCamera(cameraUpdate);
    }
  }

  @override
  Future<void> zoomIn() async {
    final c = _controller;
    if (c != null) {
      await c.animateCamera(CameraUpdate.zoomIn());
    }
  }

  @override
  Future<void> zoomOut() async {
    final c = _controller;
    if (c != null) {
      await c.animateCamera(CameraUpdate.zoomOut());
    }
  }

  @override
  Future<void> centerOn(LatLng coordinate, {double zoom = 15.0}) async {
    final c = _controller;
    if (c != null) {
      await c.animateCamera(CameraUpdate.newLatLngZoom(coordinate, zoom));
    }
  }

  @override
  Future<void> fitDrivers(
    List<DispatcherMapDriverEntity> drivers, {
    double padding = 60,
  }) async {
    final c = _controller;
    if (c == null) return;

    final validDrivers = drivers
        .where(
          (d) =>
              d.latitude != null &&
              d.longitude != null &&
              d.latitude!.isFinite &&
              d.longitude!.isFinite &&
              d.latitude! >= -90 &&
              d.latitude! <= 90 &&
              d.longitude! >= -180 &&
              d.longitude! <= 180,
        )
        .toList();

    if (validDrivers.isEmpty) {
      return;
    }

    if (validDrivers.length == 1) {
      final first = validDrivers.first;
      await c.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(first.latitude!, first.longitude!),
          15.0,
        ),
      );
      return;
    }

    double minLat = validDrivers.first.latitude!;
    double maxLat = validDrivers.first.latitude!;
    double minLng = validDrivers.first.longitude!;
    double maxLng = validDrivers.first.longitude!;

    for (final d in validDrivers) {
      minLat = math.min(minLat, d.latitude!);
      maxLat = math.max(maxLat, d.latitude!);
      minLng = math.min(minLng, d.longitude!);
      maxLng = math.max(maxLng, d.longitude!);
    }

    if ((minLat - maxLat).abs() < 0.0001 && (minLng - maxLng).abs() < 0.0001) {
      await c.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(minLat, minLng), 15.0),
      );
      return;
    }

    final bounds = LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );

    await c.animateCamera(CameraUpdate.newLatLngBounds(bounds, padding));
  }
}
