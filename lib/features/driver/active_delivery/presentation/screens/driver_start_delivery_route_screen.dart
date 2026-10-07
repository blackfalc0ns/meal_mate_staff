import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/routing/arguments/driver_active_delivery_route_arguments.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';
import '../../../map/presentation/widgets/driver_map_polyline_decoder.dart';
import '../../domain/entities/active_delivery_trip_entity.dart';
import '../../domain/fake_data/driver_active_delivery_fake_data.dart';
import '../manager/active_delivery_event.dart';
import '../manager/active_delivery_state.dart';
import '../manager/active_delivery_view_model.dart';
import '../widgets/driver_active_delivery_shimmer.dart';
import '../widgets/start_route_action_button.dart';
import '../widgets/start_route_customer_card.dart';
import '../widgets/start_route_map_preview.dart';
import '../widgets/start_route_title_section.dart';

class DriverStartDeliveryRouteScreen extends StatefulWidget {
  const DriverStartDeliveryRouteScreen({
    super.key,
    this.trip,
    this.arguments,
    this.viewModel,
    this.onStartRoute,
  });

  final ActiveDeliveryTripEntity? trip;
  final DriverActiveDeliveryRouteArguments? arguments;
  final ActiveDeliveryViewModel? viewModel;
  final VoidCallback? onStartRoute;

  @override
  State<DriverStartDeliveryRouteScreen> createState() =>
      _DriverStartDeliveryRouteScreenState();
}

class _DriverStartDeliveryRouteScreenState
    extends State<DriverStartDeliveryRouteScreen> {
  ActiveDeliveryViewModel? _viewModel;
  int _lastHandledNavRevision = 0;

  @override
  void initState() {
    super.initState();
    if (widget.trip == null) {
      if (widget.viewModel != null) {
        _viewModel = widget.viewModel;
      } else if (getIt.isRegistered<ActiveDeliveryViewModel>()) {
        _viewModel = getIt<ActiveDeliveryViewModel>();
      }
      if (_viewModel != null) {
        _lastHandledNavRevision = _viewModel!.state.navigationRevision;
        _viewModel!.doIntent(
          LoadActiveDeliveryEvent(stopId: widget.arguments?.stopId),
        );
      }
    }
  }

  void _handleStartRoute(BuildContext context) {
    if (widget.onStartRoute != null) {
      widget.onStartRoute!();
      return;
    }

    if (_viewModel != null) {
      _viewModel!.doIntent(const StartActiveDeliveryRouteEvent());
      return;
    }

    unawaited(
      context.pushReplacementNamed(
        AppRoutes.driverActiveDeliveryTracking,
        arguments: widget.arguments ??
            (widget.trip != null
                ? null
                : const DriverActiveDeliveryRouteArguments()),
      ),
    );
  }

  void _navigateToTracking(BuildContext context, ActiveDeliveryState state) {
    final stop = state.selectedStop;
    final tripId = state.route?.tripId ?? widget.arguments?.tripId;
    unawaited(
      context.pushReplacementNamed(
        AppRoutes.driverActiveDeliveryTracking,
        arguments: DriverActiveDeliveryRouteArguments(
          stopId: stop?.id ?? widget.arguments?.stopId,
          tripId: tripId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trip != null || _viewModel == null) {
      final currentTrip = widget.trip ?? DriverActiveDeliveryFakeData.defaultTrip;
      return _buildTripView(context, currentTrip);
    }

    return BlocProvider.value(
      value: _viewModel!,
      child: BlocConsumer<ActiveDeliveryViewModel, ActiveDeliveryState>(
        listener: (context, state) {
          if (state.navigationRevision > _lastHandledNavRevision &&
              state.isEligibleToStart) {
            _lastHandledNavRevision = state.navigationRevision;
            _navigateToTracking(context, state);
          }
        },
        builder: (context, state) {
          if (state.isInitialLoading) {
            return Scaffold(
              appBar: CustomAppBar.logo(showBackButton: true),
              body: const SafeArea(
                bottom: false,
                child: DriverActiveDeliveryShimmer(),
              ),
            );
          }

          if (state.loadFailure != null && state.route == null) {
            return Scaffold(
              appBar: CustomAppBar.logo(showBackButton: true),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.base),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 48,
                        color: context.colorScheme.error,
                      ),
                      const SizedBox(height: Spacing.sm),
                      Text(
                        state.loadFailure?.errorMessage ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: context.colorScheme.onSurface),
                      ),
                      const SizedBox(height: Spacing.base),
                      ElevatedButton(
                        onPressed: () => _viewModel?.doIntent(
                          const RefreshActiveDeliveryEvent(),
                        ),
                        child: Text(context.localization.driverRetryDelivery),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final stop = state.selectedStop;
          if (state.isEmpty || stop == null) {
            return Scaffold(
              appBar: CustomAppBar.logo(showBackButton: true),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.base),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.inbox_outlined,
                        size: 48,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: Spacing.sm),
                      Text(
                        context.localization.driversStatusEmpty,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: Spacing.base),
                      ElevatedButton(
                        onPressed: () => _viewModel?.doIntent(
                          const RefreshActiveDeliveryEvent(),
                        ),
                        child: Text(context.localization.driverRetryDelivery),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          final screenHeight = MediaQuery.sizeOf(context).height;
          final mapHeight = (screenHeight - 460).clamp(280.0, 440.0);
          final nav = state.route?.navigation;
          final originLatLng = nav?.origin != null
              ? LatLng(nav!.origin!.latitude, nav.origin!.longitude)
              : null;
          final destLatLng = nav?.destination != null
              ? LatLng(nav!.destination!.latitude, nav.destination!.longitude)
              : (stop.latitude != null && stop.longitude != null
                  ? LatLng(stop.latitude!, stop.longitude!)
                  : null);
          final polylinePoints = nav?.encodedPolyline != null
              ? DriverMapPolylineDecoder.decodePolyline(nav!.encodedPolyline)
              : const <LatLng>[];
          final estimatedMinutes = nav?.durationSeconds != null
              ? (nav!.durationSeconds! / 60).round()
              : null;
          final distanceKm = nav?.distanceMeters != null
              ? (nav!.distanceMeters! / 1000.0)
              : null;

          return Scaffold(
            appBar: CustomAppBar.logo(showBackButton: true),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  Spacing.base,
                  Spacing.xs,
                  Spacing.base,
                  Spacing.md,
                ),
                child: StartRouteActionButton(
                  onPressed: () => _handleStartRoute(context),
                ),
              ),
            ),
            body: SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.base,
                  vertical: Spacing.xs,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: Spacing.xs),
                    const StartRouteTitleSection(),
                    const SizedBox(height: Spacing.base),
                    StartRouteMapPreview(
                      originLatLng: originLatLng,
                      destinationLatLng: destLatLng,
                      polylinePoints: polylinePoints,
                      height: mapHeight,
                    ),
                    const SizedBox(height: Spacing.md),
                    StartRouteCustomerCard(
                      stop: stop,
                      estimatedMinutes: estimatedMinutes,
                      distanceKm: distanceKm,
                    ),
                    const SizedBox(height: Spacing.sm),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTripView(BuildContext context, ActiveDeliveryTripEntity currentTrip) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final mapHeight = (screenHeight - 460).clamp(280.0, 440.0);

    return Scaffold(
      appBar: CustomAppBar.logo(showBackButton: true),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.base,
            Spacing.xs,
            Spacing.base,
            Spacing.md,
          ),
          child: StartRouteActionButton(
            onPressed: () => _handleStartRoute(context),
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.base,
            vertical: Spacing.xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Spacing.xs),
              const StartRouteTitleSection(),
              const SizedBox(height: Spacing.base),
              StartRouteMapPreview(
                driverLocation: currentTrip.driverLocation,
                customerLocation: currentTrip.customerLocation,
                routePoints: currentTrip.routePoints,
                height: mapHeight,
              ),
              const SizedBox(height: Spacing.md),
              StartRouteCustomerCard(
                order: currentTrip.order,
                estimatedMinutes: currentTrip.estimatedMinutes,
                distanceKm: currentTrip.distanceKm,
              ),
              const SizedBox(height: Spacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}
