import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/core/app_shell/widgets/app_bottom_nav_bar.dart';
import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/empty_state_widget.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/inline_api_error_widget.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import '../../domain/entities/driver_map_stop_entity.dart';
import '../manager/driver_map_event.dart';
import '../manager/driver_map_state.dart';
import '../manager/driver_map_view_model.dart';
import '../widgets/driver_map_active_order_card.dart';
import '../widgets/driver_map_background.dart';
import '../widgets/driver_map_camera_controller.dart';
import '../widgets/driver_map_navigation_launcher.dart';
import '../widgets/driver_map_polyline_decoder.dart';
import '../widgets/driver_map_recenter_button.dart';
import '../widgets/driver_map_shimmer.dart';
import '../widgets/driver_map_stops_carousel.dart';

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({
    super.key,
    this.isActive = true,
    this.viewModel,
    this.initialStops,
    this.initialDriverLocation,
    this.initialRoutePoints,
    this.showBottomNavBar = false,
    @Deprecated('Customer calling is disabled by operations decision')
    this.onCallCustomer,
    this.onAddressTap,
  });

  final bool isActive;
  final DriverMapViewModel? viewModel;
  final List<DriverMapStopEntity>? initialStops;
  final LatLng? initialDriverLocation;
  final List<LatLng>? initialRoutePoints;
  final bool showBottomNavBar;
  final VoidCallback? onCallCustomer;
  final VoidCallback? onAddressTap;

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen>
    with WidgetsBindingObserver {
  late final DriverMapViewModel _viewModel;
  late final bool _isOwnedViewModel;
  late final PageController _pageController;
  final DriverMapCameraController _cameraController =
      const DriverMapCameraController();
  late final DriverMapNavigationLauncher _navigationLauncher;

  GoogleMapController? _mapController;
  String? _lastFittedPolyline;
  String? _lastFittedDestinationId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _navigationLauncher = DriverMapNavigationLauncher();

    if (widget.viewModel != null) {
      _viewModel = widget.viewModel!;
      _isOwnedViewModel = false;
    } else {
      _viewModel = getIt<DriverMapViewModel>();
      _isOwnedViewModel = true;
    }

    final initialStops =
        widget.initialStops ?? _viewModel.state.route?.stops ?? const [];
    final initialPage = initialStops.length > 1
        ? (300 ~/ initialStops.length) * initialStops.length
        : 0;
    _pageController = PageController(
      viewportFraction: 0.45,
      initialPage: initialPage,
    );

    if (widget.isActive) {
      unawaited(_viewModel.doIntent(const DriverMapActivated()));
    }
  }

  @override
  void didUpdateWidget(covariant DriverMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        unawaited(_viewModel.doIntent(const DriverMapActivated()));
      } else {
        unawaited(_viewModel.doIntent(const DriverMapDeactivated()));
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        if (widget.isActive) {
          unawaited(_viewModel.doIntent(const DriverMapAppResumed()));
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        unawaited(_viewModel.doIntent(const DriverMapAppPaused()));
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    _mapController = null;
    if (_isOwnedViewModel) {
      unawaited(_viewModel.close());
    }
    super.dispose();
  }

  void _handleMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _fitCamera(_viewModel.state);
  }

  void _handleRecenter(DriverMapState state) {
    final controller = _mapController;
    if (controller == null) return;
    LatLng target;
    if (state.liveLocation != null) {
      target = LatLng(
        state.liveLocation!.latitude,
        state.liveLocation!.longitude,
      );
    } else if (state.visibleNavigation?.origin != null) {
      target = LatLng(
        state.visibleNavigation!.origin!.latitude,
        state.visibleNavigation!.origin!.longitude,
      );
    } else {
      target = DriverMapCameraController.defaultKuwaitCenter;
    }
    unawaited(
      controller.animateCamera(CameraUpdate.newLatLngZoom(target, 15.0)),
    );
  }

  void _fitCamera(DriverMapState state) {
    final controller = _mapController;
    if (controller == null) return;
    final points = <LatLng>[];

    final encoded = state.visibleNavigation?.encodedPolyline;
    if (encoded != null && encoded.isNotEmpty) {
      points.addAll(DriverMapPolylineDecoder.decodePolyline(encoded));
    }

    if (state.visibleNavigation?.origin != null) {
      points.add(
        LatLng(
          state.visibleNavigation!.origin!.latitude,
          state.visibleNavigation!.origin!.longitude,
        ),
      );
    } else if (state.liveLocation != null) {
      points.add(
        LatLng(state.liveLocation!.latitude, state.liveLocation!.longitude),
      );
    }

    if (state.visibleNavigation?.destination != null) {
      points.add(
        LatLng(
          state.visibleNavigation!.destination!.latitude,
          state.visibleNavigation!.destination!.longitude,
        ),
      );
    } else {
      final selected = state.selectedStop;
      if (selected != null &&
          selected.latitude != null &&
          selected.longitude != null) {
        points.add(LatLng(selected.latitude!, selected.longitude!));
      }
    }

    if (points.isNotEmpty) {
      final update = _cameraController.calculateBoundsUpdate(points);
      unawaited(controller.animateCamera(update));
    }
  }

  int _closestPageForIndex(int targetIndex, int totalStops) {
    if (totalStops <= 0) return 0;
    if (!_pageController.hasClients) {
      return targetIndex;
    }
    final currentPage =
        _pageController.page?.round() ?? _pageController.initialPage;
    final currentModulo = currentPage % totalStops;
    var diff = targetIndex - currentModulo;
    if (diff > totalStops / 2) diff -= totalStops;
    if (diff < -totalStops / 2) diff += totalStops;
    return currentPage + diff;
  }

  void _handleStopSelected(int index, List<DriverMapStopEntity> stops) {
    if (index < 0 || index >= stops.length) return;
    final selectedStop = stops[index];
    if (selectedStop.id != _viewModel.state.selectedStopId) {
      unawaited(_viewModel.doIntent(DriverMapStopSelected(selectedStop.id)));
    }
    if (_pageController.hasClients) {
      final targetPage = _closestPageForIndex(index, stops.length);
      if (_pageController.page?.round() != targetPage) {
        unawaited(
          _pageController.animateToPage(
            targetPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ),
        );
      }
    }
  }

  Future<void> _handleNavigate(DriverMapState state) async {
    if (widget.onAddressTap != null) {
      widget.onAddressTap!();
      return;
    }
    final launched = await _navigationLauncher.launchNavigation(
      navigation: state.visibleNavigation,
      selectedStopId: state.selectedStopId,
    );
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.localization.driverMapLaunchFailed),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _handlePrevious(List<DriverMapStopEntity> stops) {
    if (stops.length > 1 && _pageController.hasClients) {
      unawaited(
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  void _handleNext(List<DriverMapStopEntity> stops) {
    if (stops.length > 1 && _pageController.hasClients) {
      unawaited(
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final bottomPadding =
        (bottomInset > Spacing.md ? bottomInset : Spacing.md) +
        Spacing.bottomNavHeight +
        Spacing.sm;

    return BlocProvider.value(
      value: _viewModel,
      child: BlocConsumer<DriverMapViewModel, DriverMapState>(
        listenWhen: (previous, current) =>
            previous.selectedStopId != current.selectedStopId ||
            previous.visibleNavigation != current.visibleNavigation,
        listener: (context, state) {
          final stops = state.route?.stops ?? const [];
          if (stops.isNotEmpty && state.selectedStopId != null) {
            final targetIndex = stops.indexWhere(
              (s) => s.id == state.selectedStopId,
            );
            if (targetIndex >= 0 && _pageController.hasClients) {
              final targetPage = _closestPageForIndex(
                targetIndex,
                stops.length,
              );
              if (_pageController.page?.round() != targetPage) {
                unawaited(
                  _pageController.animateToPage(
                    targetPage,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                );
              }
            }
          }

          final nav = state.visibleNavigation;
          final polyline = nav?.encodedPolyline;
          final destId = nav?.destinationStopId;
          if (polyline != _lastFittedPolyline ||
              destId != _lastFittedDestinationId) {
            _lastFittedPolyline = polyline;
            _lastFittedDestinationId = destId;
            _fitCamera(state);
          }
        },
        builder: (context, state) {
          final scaffoldChild = _buildBody(context, state, bottomPadding);

          return Scaffold(
            backgroundColor: color.surface,
            extendBody: true,
            bottomNavigationBar: widget.showBottomNavBar
                ? AppBottomNavBar(
                    selectedIndex: 2,
                    onItemSelected: (index) {
                      if (index != 2 && Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                  )
                : null,
            body: scaffoldChild,
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    DriverMapState state,
    double bottomPadding,
  ) {
    final l10n = context.localization;

    // 1. Fatal failure with no displayable stops: ApiErrorWidget
    if (state.failure != null &&
        (state.route == null || state.route!.stops.isEmpty)) {
      return ApiErrorWidget.fromTypedFailure(
        failure: state.failure!,
        onRetry: () => _viewModel.doIntent(const DriverMapRetryRequested()),
      );
    }

    // 2. Empty state: EmptyStateWidget
    if (state.isEmpty || (state.route != null && state.route!.stops.isEmpty)) {
      return EmptyStateWidget(
        title: l10n.driverMapEmptyTitle,
        description: l10n.driverMapEmptyDesc,
        onAction: () => _viewModel.doIntent(const DriverMapRetryRequested()),
      );
    }

    // 3. Initial loading: full skeleton shimmer
    if (state.isLoading || state.route == null) {
      return const DriverMapShimmer();
    }

    // 4. Content state
    final stops = state.route!.stops;
    final activeStop = state.selectedStop ?? stops.first;
    final activeIndex = stops.indexWhere((s) => s.id == activeStop.id);
    final validIndex = activeIndex >= 0 ? activeIndex : 0;

    final routePoints = state.visibleNavigation?.encodedPolyline != null
        ? DriverMapPolylineDecoder.decodePolyline(
            state.visibleNavigation!.encodedPolyline!,
          )
        : const <LatLng>[];

    final driverLocation = state.liveLocation != null
        ? LatLng(state.liveLocation!.latitude, state.liveLocation!.longitude)
        : (state.visibleNavigation?.origin != null
              ? LatLng(
                  state.visibleNavigation!.origin!.latitude,
                  state.visibleNavigation!.origin!.longitude,
                )
              : null);

    final routeOrigin = state.visibleNavigation?.origin != null
        ? LatLng(
            state.visibleNavigation!.origin!.latitude,
            state.visibleNavigation!.origin!.longitude,
          )
        : null;

    final canNavigate = state.visibleNavigation?.canNavigate ?? false;

    return Stack(
      children: [
        Positioned.fill(
          child: DriverMapBackground(
            driverLocation: driverLocation,
            driverHeading: state.liveLocation?.heading,
            routeOrigin: routeOrigin,
            routeOriginLabel: state.visibleNavigation?.origin?.label,
            stops: stops,
            routePoints: routePoints,
            selectedStopIndex: validIndex,
            onMapCreated: _handleMapCreated,
            onMarkerTapped: (index) => _handleStopSelected(index, stops),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Stack(
            children: [
              PositionedDirectional(
                top: Spacing.xs,
                start: Spacing.zero,
                end: Spacing.zero,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (state.failure != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: Spacing.screenH,
                          vertical: Spacing.xs,
                        ),
                        child: InlineApiErrorWidget(
                          failure: state.failure!,
                          onRetry: () => _viewModel.doIntent(
                            const DriverMapRetryRequested(),
                          ),
                        ),
                      ),
                    DriverMapActiveOrderCard(
                      stop: activeStop,
                      canNavigate: canNavigate,
                      onAddressPressed: () => _handleNavigate(state),
                      onCallPressed: widget.onCallCustomer,
                    ),
                  ],
                ),
              ),
              PositionedDirectional(
                start: Spacing.screenH,
                top: 190,
                child: DriverMapRecenterButton(
                  onPressed: () => _handleRecenter(state),
                ),
              ),
              PositionedDirectional(
                start: Spacing.zero,
                end: Spacing.zero,
                bottom: bottomPadding,
                child: DriverMapStopsCarousel(
                  stops: stops,
                  currentIndex: validIndex,
                  pageController: _pageController,
                  onPageChanged: (index) => _handleStopSelected(index, stops),
                  onPrevious: () => _handlePrevious(stops),
                  onNext: () => _handleNext(stops),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
