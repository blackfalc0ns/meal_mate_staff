import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/errors/error_widgets/empty_state_widget.dart';
import '../../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/network/failures.dart';
import '../../../../../core/widget/app_button.dart';
import '../../domain/entities/dispatcher_home_map_driver_pin_entity.dart';
import 'dispatcher_home_driver_marker.dart';
import 'dispatcher_home_map_shimmer.dart';

class DispatcherHomeMapCard extends StatefulWidget {
  const DispatcherHomeMapCard({
    super.key,
    required this.pins,
    this.isLoading = false,
    this.failure,
    this.onRetry,
    this.onViewFullMap,
  });

  final List<DispatcherHomeMapDriverPinEntity> pins;
  final bool isLoading;
  final Failure? failure;
  final VoidCallback? onRetry;
  final VoidCallback? onViewFullMap;

  @override
  State<DispatcherHomeMapCard> createState() => _DispatcherHomeMapCardState();
}

class _DispatcherHomeMapCardState extends State<DispatcherHomeMapCard> {
  static const _kuwait = LatLng(29.3759, 47.9774);
  GoogleMapController? _controller;
  final Map<String, BitmapDescriptor> _markerIcons = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMarkerIcons());
  }

  @override
  void didUpdateWidget(covariant DispatcherHomeMapCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pins != widget.pins) {
      _loadMarkerIcons();
      if (!widget.isLoading) _focusDrivers();
    }
  }

  Set<Marker> get _markers => widget.pins.map((driver) {
    return Marker(
      markerId: MarkerId(driver.id),
      position: LatLng(driver.latitude, driver.longitude),
      infoWindow: InfoWindow(
        title: driver.fullName,
        snippet: '${driver.plateNumber} • ${driver.statusText}',
      ),
      icon:
          _markerIcons[_markerCacheKey(driver)] ??
          BitmapDescriptor.defaultMarker,
      anchor: const Offset(0.5, 0.5),
    );
  }).toSet();

  String _markerCacheKey(DispatcherHomeMapDriverPinEntity driver) =>
      '${driver.id}|${driver.avatarUrl}|${driver.plateNumber}|'
      '${driver.status.name}|${driver.statusText}';

  Future<void> _loadMarkerIcons() async {
    if (!mounted) return;
    final next = <String, BitmapDescriptor>{};
    for (final driver in widget.pins) {
      final key = _markerCacheKey(driver);
      next[key] =
          _markerIcons[key] ??
          await DispatcherHomeMarkerBitmapFactory.create(context, driver);
      if (!mounted) return;
    }
    setState(() {
      _markerIcons
        ..clear()
        ..addAll(next);
    });
  }

  Future<void> _focusDrivers() async {
    final controller = _controller;
    if (controller == null) return;
    final pins = widget.pins;
    if (pins.isEmpty) {
      await controller.animateCamera(CameraUpdate.newLatLngZoom(_kuwait, 11));
    } else if (pins.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(pins.first.latitude, pins.first.longitude),
          14,
        ),
      );
    } else {
      final latitudes = pins.map((pin) => pin.latitude);
      final longitudes = pins.map((pin) => pin.longitude);
      await controller.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              latitudes.reduce((a, b) => a < b ? a : b),
              longitudes.reduce((a, b) => a < b ? a : b),
            ),
            northeast: LatLng(
              latitudes.reduce((a, b) => a > b ? a : b),
              longitudes.reduce((a, b) => a > b ? a : b),
            ),
          ),
          42,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locale.homeDriversMapTitle,
                    style: getBoldStyle(
                      fontFamily: FontConstant.alexandria,
                      fontSize: FontSize.size12,
                      color: color.onSurface,
                    ),
                  ),
                  Text(
                    locale.homeDriversMapSubtitle,
                    style: getRegularStyle(
                      fontFamily: FontConstant.alexandria,
                      fontSize: FontSize.size7,
                      color: color.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            AppButton(
              onPressed: widget.onViewFullMap,
              isExpanded: false,
              height: 34,
              variant: AppButtonVariant.text,
              icon: Icons.map_outlined,
              iconSize: Spacing.iconSm,
              text: locale.homeViewFullMap,
              textStyle: getRegularStyle(
                fontFamily: FontConstant.alexandria,
                fontSize: FontSize.size10,
                color: color.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        if (widget.isLoading && widget.pins.isEmpty)
          const DispatcherHomeMapShimmer()
        else if (widget.failure != null && widget.pins.isEmpty)
          InlineApiErrorWidget(
            failure: widget.failure!,
            onRetry: widget.onRetry,
          )
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(Spacing.cardRadius),
            child: SizedBox(
              height: 210,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: const CameraPosition(
                      target: _kuwait,
                      zoom: 11,
                    ),
                    markers: _markers,
                    myLocationButtonEnabled: false,
                    mapToolbarEnabled: false,
                    zoomControlsEnabled: false,
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    rotateGesturesEnabled: true,
                    tiltGesturesEnabled: true,
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<EagerGestureRecognizer>(
                        EagerGestureRecognizer.new,
                      ),
                    },
                    onMapCreated: (controller) {
                      _controller = controller;
                      _focusDrivers();
                    },
                  ),
                  if (widget.pins.isEmpty)
                    Positioned.fill(
                      child: ColoredBox(
                        color: color.surface.withValues(alpha: 0.85),
                        child: Center(
                          child: EmptyStateWidget(
                            title: locale.homeMapNoDrivers,
                            description: locale.homeMapNoDriversDesc,
                          ),
                        ),
                      ),
                    ),
                  PositionedDirectional(
                    end: Spacing.sm,
                    bottom: Spacing.sm,
                    child: FloatingActionButton.small(
                      key: const Key('dispatcher-map-refresh'),
                      heroTag: 'dispatcher-home-map-refresh',
                      backgroundColor: color.surface,
                      foregroundColor: color.primary,
                      disabledElevation: 2,
                      elevation: 2,
                      onPressed: widget.isLoading ? null : widget.onRetry,
                      child: widget.isLoading
                          ? const SizedBox.square(
                              dimension: 17,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_rounded),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (widget.failure != null && widget.pins.isNotEmpty) ...[
          const SizedBox(height: Spacing.sm),
          InlineApiErrorWidget(
            failure: widget.failure!,
            onRetry: widget.onRetry,
          ),
        ],
      ],
    );
  }
}
