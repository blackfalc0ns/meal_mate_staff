import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
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

    if (driver.avatarUrl.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onAvatarResolved?.call(true);
      });
    }

    final displayCode =
        (driver.activeOrderId != null && driver.activeOrderId!.isNotEmpty)
            ? driver.activeOrderId!
            : driver.plateNumber;

    return SizedBox(
      width: 104,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: AlignmentDirectional.center,
            children: [
              Container(
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
              PositionedDirectional(
                bottom: -Spacing.border,
                end: -Spacing.border,
                child: Container(
                  width: Spacing.xxl - Spacing.border * 4,
                  height: Spacing.xxl - Spacing.border * 4,
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
                    _statusIcon(driver.status),
                    color: color.onPrimary,
                    size: Spacing.iconSm,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          _pill(
            text: displayCode,
            background: color.surface,
            foreground: color.onSurface,
            fontSize: FontSize.size9,
            horizontalPadding: Spacing.sm,
            shadowColor: color.shadow.withValues(alpha: 0.12),
          ),
          const SizedBox(height: Spacing.border * 2),
          _pill(
            text: driver.statusText,
            background: colors.$1,
            foreground: colors.$2,
            fontSize: FontSize.size8,
            horizontalPadding: Spacing.sm - Spacing.border,
            shadowColor: color.shadow.withValues(alpha: 0.12),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(DispatcherHomePinStatus status) => switch (status) {
        DispatcherHomePinStatus.inDelivery => Icons.local_shipping_rounded,
        DispatcherHomePinStatus.enRouteToCustomer =>
          Icons.local_shipping_rounded,
        DispatcherHomePinStatus.onBreak => Icons.pause_rounded,
        DispatcherHomePinStatus.available => Icons.local_shipping_rounded,
        DispatcherHomePinStatus.unknown => Icons.local_shipping_rounded,
      };

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
  DispatcherHomeMarkerBitmapFactory._();

  static final Map<String, BitmapDescriptor> _cache = {};

  static String cacheKey(DispatcherHomeMapDriverPinEntity driver) =>
      '${driver.id}|${driver.avatarUrl}|${driver.activeOrderId ?? ''}|'
      '${driver.plateNumber}|${driver.status.name}|${driver.statusText}';

  static void clearCache() => _cache.clear();

  static Future<BitmapDescriptor> create(
    BuildContext context,
    DispatcherHomeMapDriverPinEntity driver,
  ) async {
    final key = cacheKey(driver);
    final cached = _cache[key];
    if (cached != null) return cached;

    final pixelRatio =
        MediaQuery.maybeDevicePixelRatioOf(context)?.clamp(1.5, 3.0) ?? 2.0;
    final boundaryKey = GlobalKey();
    final avatarResolved = Completer<void>();
    final overlay = Overlay.maybeOf(context);

    if (overlay == null) return BitmapDescriptor.defaultMarker;

    final entry = OverlayEntry(
      builder: (_) => Positioned(
        left: -1000,
        top: -1000,
        child: RepaintBoundary(
          key: boundaryKey,
          child: Material(
            color: Colors.transparent,
            child: Directionality(
              textDirection: Directionality.of(context),
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

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      await Future<void>.delayed(Duration.zero);
    }

    if (!overlay.mounted) return BitmapDescriptor.defaultMarker;

    overlay.insert(entry);

    final isTest =
        WidgetsBinding.instance.runtimeType.toString().contains('Test');

    if (driver.avatarUrl.isEmpty && !avatarResolved.isCompleted) {
      avatarResolved.complete();
    }

    try {
      await Future.any([
        WidgetsBinding.instance.endOfFrame,
        Future<void>.delayed(const Duration(milliseconds: 40)),
      ]);
      if (!isTest) {
        await avatarResolved.future.timeout(
          const Duration(milliseconds: 250),
          onTimeout: () {},
        );
      }

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
