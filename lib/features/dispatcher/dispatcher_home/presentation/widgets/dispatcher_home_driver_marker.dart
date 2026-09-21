import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../core/widget/app_cached_network_image.dart';
import '../../domain/entities/dispatcher_home_map_driver_pin_entity.dart';

class DispatcherHomeDriverMarker extends StatelessWidget {
  const DispatcherHomeDriverMarker({
    super.key,
    required this.driver,
    this.onAvatarResolved,
  });

  final DispatcherHomeMapDriverPinEntity driver;
  final ValueChanged<bool>? onAvatarResolved;

  @override
  Widget build(BuildContext context) {
    final colors = _colors(driver.status);
    return SizedBox(
      width: 104,
      height: 112,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 0,
            left: 17,
            child: Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: AppCachedNetworkImage(
                imageUrl: driver.avatarUrl,
                shape: BoxShape.circle,
                onImageResolved: onAvatarResolved,
                // errorWidget: const ColoredBox(
                //   color: Color(0xFFE9E4F8),
                //   child: Icon(Icons.person_rounded, color: Color(0xFF6946C6)),
                // ),
                //  loadingWidget: const ColoredBox(color: Color(0xFFE9E4F8)),
              ),
            ),
          ),
          Positioned(
            top: 19,
            right: 15,
            child: Container(
              width: 31,
              height: 31,
              decoration: BoxDecoration(
                color: colors.$1,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(color: Color(0x22000000), blurRadius: 3),
                ],
              ),
              child: const Icon(
                Icons.local_shipping_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          Positioned(
            top: 49,
            child: _pill(
              text: driver.plateNumber,
              background: Colors.white,
              foreground: const Color(0xFF171717),
              fontSize: 9,
              horizontalPadding: 8,
            ),
          ),
          Positioned(
            top: 72,
            child: _pill(
              text: driver.statusText,
              background: colors.$1,
              foreground: colors.$2,
              fontSize: 8,
              horizontalPadding: 7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pill({
    required String text,
    required Color background,
    required Color foreground,
    required double fontSize,
    required double horizontalPadding,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 102),
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: foreground,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          fontFamily: 'Alexandria',
          decoration: TextDecoration.none,
        ),
      ),
    );
  }

  (Color, Color) _colors(DispatcherHomePinStatus status) => switch (status) {
    DispatcherHomePinStatus.inDelivery => (
      const Color(0xFF22B96E),
      Colors.white,
    ),
    DispatcherHomePinStatus.enRouteToCustomer => (
      const Color(0xFFFF8A00),
      Colors.white,
    ),
    DispatcherHomePinStatus.onBreak => (const Color(0xFF7F8795), Colors.white),
    DispatcherHomePinStatus.available => (
      const Color(0xFF6946C6),
      Colors.white,
    ),
    DispatcherHomePinStatus.unknown => (const Color(0xFF667085), Colors.white),
  };
}

class DispatcherHomeMarkerBitmapFactory {
  const DispatcherHomeMarkerBitmapFactory._();

  static Future<BitmapDescriptor> create(
    BuildContext context,
    DispatcherHomeMapDriverPinEntity driver,
  ) async {
    final pixelRatio = MediaQuery.devicePixelRatioOf(context).clamp(1.5, 3.0);
    final boundaryKey = GlobalKey();
    final avatarResolved = Completer<void>();
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        left: -500,
        top: -500,
        child: RepaintBoundary(
          key: boundaryKey,
          child: Material(
            color: Colors.transparent,
            child: DispatcherHomeDriverMarker(
              driver: driver,
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
      await WidgetsBinding.instance.endOfFrame;
      await avatarResolved.future;
      final boundary =
          boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return BitmapDescriptor.defaultMarker;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      final bytes = byteData?.buffer.asUint8List() ?? Uint8List(0);
      if (bytes.isEmpty) return BitmapDescriptor.defaultMarker;
      return BitmapDescriptor.bytes(
        bytes,
        imagePixelRatio: pixelRatio,
        width: 104,
        height: 112,
      );
    } finally {
      entry.remove();
    }
  }
}
