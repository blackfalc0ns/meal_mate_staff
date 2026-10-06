import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../tracking/presentation/manager/driver_live_location_coordinator.dart';
import '../../data/repositories/active_delivery_fake_repository_impl.dart';
import '../../domain/entities/active_delivery_location_entity.dart';
import '../../domain/entities/active_delivery_trip_entity.dart';
import '../../domain/fake_data/driver_active_delivery_fake_data.dart';
import '../../domain/repositories/active_delivery_repository.dart';
import '../widgets/driver_tracking_address_card.dart';
import '../widgets/driver_tracking_app_bar.dart';
import '../widgets/driver_tracking_bottom_actions.dart';
import '../widgets/driver_tracking_help_card.dart';
import '../widgets/driver_tracking_map_view.dart';
import '../widgets/driver_tracking_stepper.dart';
import '../widgets/driver_tracking_summary_card.dart';
import '../widgets/driver_tracking_title_section.dart';
import '../../../calling/domain/entities/driver_call_attempt_entity.dart';
import '../../../calling/presentation/widgets/customer_call_attempts_sheet.dart';

class DriverActiveDeliveryTrackingScreen extends StatefulWidget {
  const DriverActiveDeliveryTrackingScreen({
    super.key,
    this.trip,
    this.repository,
    this.locationStream,
    this.onConfirmArrival,
    this.onReportDelay,
    this.onReportFailed,
  });

  final ActiveDeliveryTripEntity? trip;
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
  late final ActiveDeliveryRepository _repository;
  late final bool _ownsRepository;
  late final Stream<ActiveDeliveryLocationEntity> _stream;
  late ActiveDeliveryTripEntity _trip;

  @override
  void initState() {
    super.initState();
    _trip = widget.trip ?? DriverActiveDeliveryFakeData.defaultTrip;
    if (widget.repository != null) {
      _repository = widget.repository!;
      _ownsRepository = false;
    } else {
      _repository = ActiveDeliveryFakeRepositoryImpl(initialTrip: _trip);
      _ownsRepository = true;
    }
    _stream = widget.locationStream ?? _repository.watchDriverLocation();
    if (getIt.isRegistered<DriverLiveLocationCoordinator>()) {
      unawaited(getIt<DriverLiveLocationCoordinator>().setActiveBoxesCount(1));
    }
  }

  @override
  void dispose() {
    if (_ownsRepository) {
      _repository.dispose();
    }
    super.dispose();
  }

  void _handleConfirmArrival() {
    if (widget.onConfirmArrival != null) {
      widget.onConfirmArrival!();
      return;
    }
    unawaited(_repository.completeDelivery(_trip.tripId));
    unawaited(
      context.pushReplacementNamed(
        AppRoutes.driverDeliverySuccess,
        arguments: _trip,
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

  @override
  Widget build(BuildContext context) {
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
            onConfirmArrival: _handleConfirmArrival,
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
                      initialDriverLocation: _trip.driverLocation,
                      customerLocation: _trip.customerLocation,
                      routePoints: _trip.routePoints,
                      locationStream: _stream,
                      onCallCustomer: _handleCallCustomer,
                      onMessageCustomer: () {},
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: Spacing.base,
                    right: Spacing.base,
                    child: DriverTrackingSummaryCard(
                      order: _trip.order,
                      onCallPressed: _handleCallCustomer,
                      onNavigatePressed: () {},
                    ),
                  ),
                  Positioned(
                    bottom: -5,
                    left: Spacing.base,
                    right: Spacing.base,
                    child: DriverTrackingAddressCard(order: _trip.order),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.base),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.base),
                child: DriverTrackingStepper(status: _trip.status),
              ),
              const SizedBox(height: Spacing.base),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: Spacing.base),
                child: DriverTrackingHelpCard(),
              ),
              const SizedBox(height: Spacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
