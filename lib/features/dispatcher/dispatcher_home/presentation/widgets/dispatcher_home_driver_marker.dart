import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../config/theme/colors.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
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
    final color = context.colorScheme;
    final colors = _colors(color, driver.status);

    return SizedBox(
      width: 104,
      height: 112,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: AlignmentDirectional.topCenter,
        children: [
          PositionedDirectional(
            top: 0,
            start: Spacing.base + Spacing.border,
            child: Container(
              width: Spacing.xxxl,
              height: Spacing.xxxl,
              padding: const EdgeInsets.all(Spacing.border * 2),
              decoration: BoxDecoration(
                color: color.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.shadow.withValues(alpha: 0.2),
                    blurRadius: Spacing.xs + Spacing.border,
                    offset: const Offset(0, Spacing.border * 2),
                  ),
                ],
              ),
              child: AppCachedNetworkImage(
                imageUrl: driver.avatarUrl,
                shape: BoxShape.circle,
                onImageResolved: onAvatarResolved,
              ),
            ),
          ),
          PositionedDirectional(
            top: Spacing.lg - Spacing.border,
            end: Spacing.base - Spacing.border,
            child: Container(
              width: Spacing.xxl - Spacing.border,
              height: Spacing.xxl - Spacing.border,
              decoration: BoxDecoration(
                color: colors.$1,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.surface,
                  width: Spacing.border * 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.shadow.withValues(alpha: 0.15),
                    blurRadius: Spacing.xs - Spacing.border,
                  ),
                ],
              ),
              child: Icon(
                Icons.local_shipping_rounded,
                color: color.onPrimary,
                size: Spacing.iconSm,
              ),
            ),
          ),
          Positioned(
            top: Spacing.xxxl + Spacing.border,
            child: _pill(
              text: driver.plateNumber,
              background: color.surface,
              foreground: color.onSurface,
              fontSize: FontSize.size9,
              horizontalPadding: Spacing.sm,
              shadowColor: color.shadow.withValues(alpha: 0.12),
            ),
          ),
          Positioned(
            top: Spacing.bottomNavHeight,
            child: _pill(
              text: driver.statusText,
              background: colors.$1,
              foreground: colors.$2,
              fontSize: FontSize.size8,
              horizontalPadding: Spacing.sm - Spacing.border,
              shadowColor: color.shadow.withValues(alpha: 0.12),
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
    required Color shadowColor,
  }) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 102),
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: Spacing.xs - Spacing.border,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: Spacing.xs - Spacing.border,
            offset: const Offset(0, Spacing.border),
          ),
        ],
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: getBoldStyle(
          color: foreground,
          fontSize: fontSize,
        ),
      ),
    );
  }

  (Color, Color) _colors(ColorScheme color, DispatcherHomePinStatus status) =>
      switch (status) {
        DispatcherHomePinStatus.inDelivery => (
          color.homeTagDeliveryBg,
          color.onPrimary,
        ),
        DispatcherHomePinStatus.enRouteToCustomer => (
          color.homeTagLoadingBg,
          color.onPrimary,
        ),
        DispatcherHomePinStatus.onBreak => (
          color.homeTagPausedDot,
          color.onPrimary,
        ),
        DispatcherHomePinStatus.available => (
          color.homeActionIconPurple,
          color.onPrimary,
        ),
        DispatcherHomePinStatus.unknown => (
          color.homeMutedText,
          color.onPrimary,
        ),
      };
}

class DispatcherHomeMarkerBitmapFactory {
  const DispatcherHomeMarkerBitmapFactory._();

  static Future<BitmapDescriptor> create(
    BuildContext context,
    DispatcherHomeMapDriverPinEntity driver,
  ) async {
    final color = context.colorScheme;
    final directionality = Directionality.of(context);
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
            color: color.transparent,
            child: Directionality(
              textDirection: directionality,
              child: DispatcherHomeDriverMarker(
                driver: driver,
                onAvatarResolved: (_) {
                  if (!avatarResolved.isCompleted) avatarResolved.complete();
                },
              ),
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
