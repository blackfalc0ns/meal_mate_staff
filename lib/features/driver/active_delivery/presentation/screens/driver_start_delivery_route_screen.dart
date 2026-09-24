import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/active_delivery_trip_entity.dart';
import '../../domain/fake_data/driver_active_delivery_fake_data.dart';
import '../widgets/start_route_action_button.dart';
import '../widgets/start_route_customer_card.dart';
import '../widgets/start_route_header.dart';
import '../widgets/start_route_map_preview.dart';
import '../widgets/start_route_title_section.dart';

class DriverStartDeliveryRouteScreen extends StatelessWidget {
  const DriverStartDeliveryRouteScreen({
    super.key,
    this.trip,
    this.onStartRoute,
  });

  final ActiveDeliveryTripEntity? trip;
  final VoidCallback? onStartRoute;

  void _handleStartRoute(BuildContext context) {
    if (onStartRoute != null) {
      onStartRoute!();
      return;
    }
    unawaited(
      context.pushReplacementNamed(AppRoutes.driverActiveDeliveryTracking),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final currentTrip = trip ?? DriverActiveDeliveryFakeData.defaultTrip;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: StartRouteHeader(onBackPressed: () => context.maybePopRoute()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
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
              ),
              const SizedBox(height: Spacing.md),
              StartRouteCustomerCard(
                order: currentTrip.order,
                estimatedMinutes: currentTrip.estimatedMinutes,
                distanceKm: currentTrip.distanceKm,
              ),
              const SizedBox(height: Spacing.base),
              StartRouteActionButton(
                onPressed: () => _handleStartRoute(context),
              ),
              const SizedBox(height: Spacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
