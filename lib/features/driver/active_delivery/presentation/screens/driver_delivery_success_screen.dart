import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/active_delivery_trip_entity.dart';
import '../../domain/fake_data/driver_active_delivery_fake_data.dart';
import '../widgets/delivery_success_action_button.dart';
import '../widgets/delivery_success_header.dart';
import '../widgets/delivery_success_hero_banner.dart';
import '../widgets/delivery_success_summary_card.dart';

class DriverDeliverySuccessScreen extends StatelessWidget {
  const DriverDeliverySuccessScreen({
    super.key,
    this.trip,
    this.onConfirmed,
    this.onBackToOrders,
  });

  final ActiveDeliveryTripEntity? trip;
  final VoidCallback? onConfirmed;
  final VoidCallback? onBackToOrders;

  void _handleConfirmed(BuildContext context) {
    if (onConfirmed != null) {
      onConfirmed!();
      return;
    }
    unawaited(
      context.pushNamedAndRemoveUntil(
        AppRoutes.driverAssignedBoxes,
        (route) => false,
      ),
    );
  }

  void _handleBackToOrders(BuildContext context) {
    if (onBackToOrders != null) {
      onBackToOrders!();
      return;
    }
    unawaited(
      context.pushNamedAndRemoveUntil(
        AppRoutes.driverAssignedBoxes,
        (route) => false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final currentTrip = trip ?? DriverActiveDeliveryFakeData.defaultTrip;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: DeliverySuccessHeader(
        onClosePressed: () => _handleBackToOrders(context),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.base,
            vertical: Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DeliverySuccessHeroBanner(),
              const SizedBox(height: Spacing.base),
              DeliverySuccessSummaryCard(order: currentTrip.order),
              const SizedBox(height: Spacing.xl),
              DeliverySuccessActionButton(
                onConfirmed: () => _handleConfirmed(context),
                onBackToOrders: () => _handleBackToOrders(context),
              ),
              const SizedBox(height: Spacing.base),
            ],
          ),
        ),
      ),
    );
  }
}
