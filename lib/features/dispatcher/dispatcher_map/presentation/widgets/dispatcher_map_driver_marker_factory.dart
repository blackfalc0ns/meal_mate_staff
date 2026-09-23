import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../domain/entities/dispatcher_map_driver_entity.dart';
import 'dispatcher_map_marker_item.dart';

class DispatcherMapMarkerBitmapFactory {
  DispatcherMapMarkerBitmapFactory._();

  static final Map<String, BitmapDescriptor> _cache = {};

  static String cacheKey(
    DispatcherMapDriverEntity driver, {
    required bool isSelected,
  }) {
    return '${driver.id}|${driver.boxId}|${driver.status.name}|'
        '${driver.statusText ?? ''}|${driver.avatarUrl ?? ''}|$isSelected';
  }

  static void clearCache() {
    _cache.clear();
  }

  static Future<BitmapDescriptor> create(
    BuildContext context,
    DispatcherMapDriverEntity driver, {
    required bool isSelected,
  }) async {
    final key = cacheKey(driver, isSelected: isSelected);
    final cached = _cache[key];
    if (cached != null) {
      return cached;
    }

    final pixelRatio =
        MediaQuery.maybeDevicePixelRatioOf(context)?.clamp(1.5, 3.0) ?? 2.0;
    final boundaryKey = GlobalKey();
    final avatarResolved = Completer<void>();
    final overlay = Overlay.maybeOf(context);

    if (overlay == null) {
      return BitmapDescriptor.defaultMarker;
    }

    final entry = OverlayEntry(
      builder: (_) => Positioned(
        left: -1000,
        top: -1000,
        child: RepaintBoundary(
          key: boundaryKey,
          child: Material(
            color: Colors.transparent,
            child: DispatcherMapMarkerItem(
              driver: driver,
              isSelected: isSelected,
              onAvatarResolved: (_) {
                if (!avatarResolved.isCompleted) avatarResolved.complete();
              },
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    try {
      await Future.any([
        WidgetsBinding.instance.endOfFrame,
        Future<void>.delayed(const Duration(milliseconds: 50)),
      ]);
      await avatarResolved.future.timeout(
        const Duration(milliseconds: 250),
        onTimeout: () {},
      );

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
