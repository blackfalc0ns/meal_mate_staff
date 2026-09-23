import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../data/repositories/active_delivery_fake_repository_impl.dart';
import '../../domain/entities/active_delivery_location_entity.dart';
import '../../domain/entities/active_delivery_trip_entity.dart';
import '../../domain/fake_data/driver_active_delivery_fake_data.dart';
import '../../domain/repositories/active_delivery_repository.dart';
import '../widgets/driver_tracking_app_bar.dart';
import '../widgets/driver_tracking_bottom_actions.dart';
import '../widgets/driver_tracking_customer_card.dart';
import '../widgets/driver_tracking_map_view.dart';
import '../widgets/driver_tracking_stepper.dart';

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

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: DriverTrackingAppBar(
        onBackPressed: () => context.maybePopRoute(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: DriverTrackingMapView(
                initialDriverLocation: _trip.driverLocation,
                customerLocation: _trip.customerLocation,
                routePoints: _trip.routePoints,
                locationStream: _stream,
                onCallCustomer: () {},
                onMessageCustomer: () {},
              ),
            ),
            Expanded(
              flex: 5,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: color.surface,
                  boxShadow: [
                    BoxShadow(
                      color: color.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.base,
                    vertical: Spacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DriverTrackingStepper(status: _trip.status),
                      const SizedBox(height: Spacing.sm),
                      DriverTrackingCustomerCard(
                        order: _trip.order,
                        onCallPressed: () {},
                        onMessagePressed: () {},
                      ),
                      const SizedBox(height: Spacing.md),
                      DriverTrackingBottomActions(
                        onConfirmArrival: _handleConfirmArrival,
                        onReportDelay: _handleReportDelay,
                        onReportFailed: _handleReportFailed,
                      ),
                      const SizedBox(height: Spacing.base),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
