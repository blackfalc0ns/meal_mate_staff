import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_app_bar.dart';
import '../../domain/entities/active_delivery_trip_entity.dart';
import '../../domain/fake_data/driver_active_delivery_fake_data.dart';
import '../widgets/start_route_action_button.dart';
import '../widgets/start_route_customer_card.dart';
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
    final currentTrip = trip ?? DriverActiveDeliveryFakeData.defaultTrip;
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
