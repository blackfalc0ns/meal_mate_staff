import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/routing/arguments/driver_active_delivery_route_arguments.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../calling/domain/entities/driver_call_attempt_entity.dart';
import '../../../calling/presentation/widgets/customer_call_attempts_sheet.dart';
import '../../../delivery_issues/domain/entities/delivery_issue_entity.dart';
import '../../../delivery_issues/domain/entities/delivery_issue_reason.dart';
import '../../../map/domain/entities/driver_map_route_entity.dart';
import '../../../map/domain/entities/driver_map_stop_entity.dart';
import '../../../map/presentation/widgets/driver_map_polyline_decoder.dart';
import '../../data/repositories/active_delivery_fake_repository_impl.dart';
import '../../domain/entities/active_delivery_location_entity.dart';
import '../../domain/entities/active_delivery_order_entity.dart';
import '../../domain/entities/active_delivery_trip_entity.dart';
import '../../domain/entities/delivery_trip_status.dart';
import '../../domain/fake_data/driver_active_delivery_fake_data.dart';
import '../../../tracking/presentation/manager/driver_live_location_coordinator.dart';
import '../../domain/repositories/active_delivery_repository.dart';
import '../manager/active_delivery_event.dart';
import '../manager/active_delivery_state.dart';
import '../manager/active_delivery_view_model.dart';
import '../widgets/driver_active_delivery_shimmer.dart';
import '../widgets/driver_tracking_address_card.dart';
import '../widgets/driver_tracking_app_bar.dart';
import '../widgets/driver_tracking_bottom_actions.dart';
import '../widgets/driver_tracking_help_card.dart';
import '../widgets/driver_tracking_map_view.dart';
import '../widgets/driver_tracking_stepper.dart';
import '../widgets/driver_tracking_summary_card.dart';
import '../widgets/driver_tracking_title_section.dart';

class DriverActiveDeliveryTrackingScreen extends StatefulWidget {
  const DriverActiveDeliveryTrackingScreen({
    super.key,
    this.trip,
    this.arguments,
    this.viewModel,
    this.repository,
    this.locationStream,
    this.onConfirmArrival,
    this.onReportDelay,
    this.onReportFailed,
  });

  final ActiveDeliveryTripEntity? trip;
  final DriverActiveDeliveryRouteArguments? arguments;
  final ActiveDeliveryViewModel? viewModel;
  final ActiveDeliveryRepository? repository;
  final Stream<ActiveDeliveryLocationEntity>? locationStream;
  final VoidCallback? onConfirmArrival;
  final VoidCallback? onReportDelay;
  final VoidCallback? onReportFailed;

  @override
  State<DriverActiveDeliveryTrackingScreen> createState() =>
      _DriverActiveDeliveryTrackingScreenState();
}

class _DriverActiveDeliveryTrackingScreenState
    extends State<DriverActiveDeliveryTrackingScreen> {
  ActiveDeliveryViewModel? _viewModel;
  ActiveDeliveryRepository? _repository;
  bool _ownsRepository = false;
  late Stream<ActiveDeliveryLocationEntity> _stream;
  late ActiveDeliveryTripEntity _trip;
  late ActiveDeliveryLocationEntity _driverLocation;
  int _lastHandledNavRevision = 0;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip ?? DriverActiveDeliveryFakeData.defaultTrip;
    _driverLocation = _trip.driverLocation;

    if (widget.viewModel != null) {
      _viewModel = widget.viewModel;
    } else if (widget.trip == null &&
        widget.repository == null &&
        getIt.isRegistered<ActiveDeliveryViewModel>()) {
      _viewModel = getIt<ActiveDeliveryViewModel>();
    }

    if (_viewModel != null) {
      _lastHandledNavRevision = _viewModel!.state.navigationRevision;
      _viewModel!.doIntent(
        LoadActiveDeliveryEvent(stopId: widget.arguments?.stopId),
      );
    }

    if (widget.repository != null) {
      _repository = widget.repository;
      _ownsRepository = false;
    } else if (widget.trip != null || _viewModel == null) {
      _repository = ActiveDeliveryFakeRepositoryImpl(initialTrip: _trip);
      _ownsRepository = true;
    } else {
      _repository = null;
      _ownsRepository = false;
    }

    if (widget.locationStream != null) {
      _stream = widget.locationStream!;
    } else if (_repository != null) {
      _stream = _repository!.watchDriverLocation();
    } else if (getIt.isRegistered<DriverLiveLocationCoordinator>()) {
      final coordinator = getIt<DriverLiveLocationCoordinator>();
      final initial = coordinator.latestLocation;
      if (initial != null) {
        _driverLocation = ActiveDeliveryLocationEntity(
          latitude: initial.latitude,
          longitude: initial.longitude,
          heading: initial.heading ?? 0.0,
        );
      }
      _stream = coordinator.positions.map(
        (sample) => ActiveDeliveryLocationEntity(
          latitude: sample.latitude,
          longitude: sample.longitude,
          heading: sample.heading ?? 0.0,
        ),
      );
    } else {
      _stream = Stream.value(_trip.driverLocation);
    }
  }

  @override
  void dispose() {
    if (_ownsRepository) {
      _repository?.dispose();
    }
    super.dispose();
  }

  void _handleConfirmArrival() {
    if (widget.onConfirmArrival != null) {
      widget.onConfirmArrival!();
      return;
    }

    if (_viewModel != null) {
      _viewModel!.doIntent(
        ConfirmCustomerArrivalEvent(
          latitude: _driverLocation.latitude,
          longitude: _driverLocation.longitude,
        ),
      );
      return;
    }

    unawaited(_repository?.completeDelivery(_trip.tripId));
    unawaited(
      context.pushReplacementNamed(
        AppRoutes.driverDeliveryArrivalConfirmation,
        arguments: DriverActiveDeliveryRouteArguments(
          tripId: _trip.tripId,
        ),
      ),
    );
  }

  void _handleReportDelay() {
    if (widget.onReportDelay != null) {
      widget.onReportDelay!();
      return;
    }
    unawaited(
      context.pushNamed(AppRoutes.driverDeliveryDelay, arguments: _trip),
    );
  }

  void _handleReportFailed() {
    if (widget.onReportFailed != null) {
      widget.onReportFailed!();
      return;
    }
    unawaited(
      context.pushNamed(AppRoutes.driverFailedDelivery, arguments: _trip),
    );
  }

  void _handleCallCustomer() {
    unawaited(
      CustomerCallAttemptsSheet.show(
        context,
        initialAttempt: DriverCallAttemptEntity(
          customerName: _trip.order.customerName,
          customerPhone: _trip.order.customerPhone,
        ),
      ),
    );
  }

  ActiveDeliveryTripEntity _tripFromState(
    DriverMapRouteEntity route,
    DriverMapStopEntity stop,
  ) {
    final nav = route.navigation;
    final dLat = nav?.origin?.latitude ?? 24.7136;
    final dLng = nav?.origin?.longitude ?? 46.6753;
    final cLat = stop.latitude ?? nav?.destination?.latitude ?? 24.7136;
    final cLng = stop.longitude ?? nav?.destination?.longitude ?? 46.6753;
    final polyPoints = nav?.encodedPolyline != null
        ? DriverMapPolylineDecoder.decodePolyline(nav!.encodedPolyline)
            .map(
              (p) => ActiveDeliveryLocationEntity(
                latitude: p.latitude,
                longitude: p.longitude,
              ),
            )
            .toList()
        : <ActiveDeliveryLocationEntity>[];

    return ActiveDeliveryTripEntity(
      tripId: route.tripId,
      order: ActiveDeliveryOrderEntity(
        orderId: stop.boxCode,
        boxCode: stop.boxCode,
        customerName: stop.customerName,
        customerPhone: stop.customerPhone,
        customerAvatar: '',
        address: stop.formattedAddress,
        mealsCount: stop.mealsCount,
        customerNote: stop.customerNote ?? '',
        restaurantName: 'MealMate',
        restaurantAddress: '',
        paymentMethod: 'Prepaid',
      ),
      status: stop.isDelivered
          ? DeliveryTripStatus.delivered
          : DeliveryTripStatus.enRoute,
      driverLocation: ActiveDeliveryLocationEntity(
        latitude: dLat,
        longitude: dLng,
      ),
      customerLocation: ActiveDeliveryLocationEntity(
        latitude: cLat,
        longitude: cLng,
      ),
      restaurantLocation: ActiveDeliveryLocationEntity(
        latitude: dLat,
        longitude: dLng,
      ),
      routePoints: polyPoints,
      estimatedMinutes: nav?.durationSeconds != null
          ? (nav!.durationSeconds! / 60).round()
          : 15,
      distanceKm: nav?.distanceMeters != null
          ? (nav!.distanceMeters! / 1000.0)
          : 5.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel == null) {
      return _buildScaffold(context, _trip);
    }

    return BlocProvider.value(
      value: _viewModel!,
      child: BlocConsumer<ActiveDeliveryViewModel, ActiveDeliveryState>(
        listener: (context, state) {
          if ((state.hasArrived || state.arrivalResult != null) &&
              state.navigationRevision > _lastHandledNavRevision) {
            _lastHandledNavRevision = state.navigationRevision;
            unawaited(
              context.pushReplacementNamed(
                AppRoutes.driverDeliveryArrivalConfirmation,
                arguments: DriverActiveDeliveryRouteArguments(
                  stopId: state.selectedStop?.id ?? widget.arguments?.stopId,
                  tripId: state.route?.tripId ?? widget.arguments?.tripId,
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.isInitialLoading && state.route == null) {
            return Scaffold(
              appBar: DriverTrackingAppBar(
                onBackPressed: () => context.maybePopRoute(),
              ),
              body: const SafeArea(
                bottom: false,
                child: DriverActiveDeliveryShimmer(),
              ),
            );
          }

          final stop = state.selectedStop;
          final route = state.route;
          final currentTrip = (route != null && stop != null)
              ? _tripFromState(route, stop)
              : _trip;

          return _buildScaffold(context, currentTrip, isArriving: state.isArriving);
        },
      ),
    );
  }

  Widget _buildScaffold(
    BuildContext context,
    ActiveDeliveryTripEntity trip, {
    bool isArriving = false,
  }) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: DriverTrackingAppBar(
        onBackPressed: () => context.maybePopRoute(),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.base,
            Spacing.xs,
            Spacing.base,
            Spacing.md,
          ),
          child: DriverTrackingBottomActions(
            onConfirmArrival: isArriving ? () {} : _handleConfirmArrival,
            onReportDelay: _handleReportDelay,
            onReportFailed: _handleReportFailed,
          ),
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Spacing.xs),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.base),
                child: DriverTrackingTitleSection(),
              ),
              const SizedBox(height: Spacing.sm),
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 65, bottom: 65),
                    child: DriverTrackingMapView(
                      height: 320,
                      initialDriverLocation: trip.driverLocation,
                      customerLocation: trip.customerLocation,
                      routePoints: trip.routePoints,
                      locationStream: _stream,
                      onLocationUpdate: (loc) => _driverLocation = loc,
                      onCallCustomer: _handleCallCustomer,
                      onMessageCustomer: () {},
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: Spacing.base,
                    right: Spacing.base,
                    child: DriverTrackingSummaryCard(
                      order: trip.order,
                      onCallPressed: _handleCallCustomer,
                      onNavigatePressed: () {},
                    ),
                  ),
                  Positioned(
                    bottom: -5,
                    left: Spacing.base,
                    right: Spacing.base,
                    child: DriverTrackingAddressCard(order: trip.order),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
                child: DriverTrackingStepper(status: trip.status),
              ),
              const SizedBox(height: Spacing.base),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
                child: DriverTrackingHelpCard(
                  onTap: () {
                    unawaited(
                      context.pushNamed(
                        AppRoutes.driverReportIssue,
                        arguments: DeliveryIssueEntity(
                          boxCode: trip.order.boxCode,
                          customerName: trip.order.customerName,
                          restaurantName: trip.order.restaurantName,
                          area: trip.order.address,
                          status: 'في الطريق للعميل',
                          mealsCountText:
                              '${trip.order.mealsCount} من ${trip.order.mealsCount} وجبة',
                          selectedReason: DeliveryIssueReason.customerNoAnswer,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: Spacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
