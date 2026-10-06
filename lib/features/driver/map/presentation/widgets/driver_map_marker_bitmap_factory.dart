import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meal_mate_delivery/config/theme/colors.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

import 'driver_map_driver_marker_item.dart';
import 'driver_map_stop_marker_item.dart';

class DriverMapMarkerBitmapFactory {
  DriverMapMarkerBitmapFactory._();

  static final Map<String, BitmapDescriptor> _cache = {};

  static const String driverCacheKey = 'driver_marker';

  static String stopCacheKey(
    String stopId,
    String boxCode, {
    required bool isSelected,
  }) {
    return 'stop|$stopId|$boxCode|$isSelected';
  }

  static void clearCache() {
    _cache.clear();
  }

  static Future<BitmapDescriptor> createDriverMarker(
    BuildContext context,
  ) {
    return _createFromWidget(
      context,
      key: driverCacheKey,
      widget: const DriverMapDriverMarkerItem(),
    );
  }

  static Future<BitmapDescriptor> createStopMarker(
    BuildContext context, {
    required String stopId,
    required String boxCode,
    required bool isSelected,
  }) {
    final key = stopCacheKey(stopId, boxCode, isSelected: isSelected);
    return _createFromWidget(
      context,
      key: key,
      widget: DriverMapStopMarkerItem(
        boxCode: boxCode,
        isSelected: isSelected,
      ),
    );
  }

  static Future<BitmapDescriptor> _createFromWidget(
    BuildContext context, {
    required String key,
    required Widget widget,
  }) async {
    final cached = _cache[key];
    if (cached != null) {
      return cached;
    }

    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');
    if (isTest) {
      return BitmapDescriptor.defaultMarker;
    }

    final pixelRatio =
        MediaQuery.maybeDevicePixelRatioOf(context)?.clamp(1.5, 3.0) ?? 2.0;
    final boundaryKey = GlobalKey();
    final overlay = Overlay.maybeOf(context);

    if (overlay == null) {
      return BitmapDescriptor.defaultMarker;
    }

    final color = context.colorScheme;

    final entry = OverlayEntry(
      builder: (_) => Positioned(
        left: -2000,
        top: -2000,
        child: RepaintBoundary(
          key: boundaryKey,
          child: Material(
            color: color.transparent,
            child: Directionality(
              textDirection:
                  Directionality.maybeOf(context) ?? TextDirection.rtl,
              child: Theme(
                data: Theme.of(context),
                child: widget,
              ),
            ),
          ),
        ),
      ),
    );

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      await Future<void>.delayed(Duration.zero);
    }

    if (!overlay.mounted) {
      return BitmapDescriptor.defaultMarker;
    }

    overlay.insert(entry);

    try {
      await Future.any([
        WidgetsBinding.instance.endOfFrame,
        Future<void>.delayed(const Duration(milliseconds: 50)),
      ]);

      final boundary =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return BitmapDescriptor.defaultMarker;

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();

      final bytes = byteData?.buffer.asUint8List() ?? Uint8List(0);
      if (bytes.isEmpty) return BitmapDescriptor.defaultMarker;

      final descriptor = BitmapDescriptor.bytes(
        bytes,
        imagePixelRatio: pixelRatio,
      );

      _cache[key] = descriptor;
      return descriptor;
    } catch (_) {
      return BitmapDescriptor.defaultMarker;
    } finally {
      entry.remove();
    }
  }
}
