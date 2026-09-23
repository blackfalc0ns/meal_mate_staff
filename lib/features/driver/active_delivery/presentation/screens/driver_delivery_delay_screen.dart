import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/active_delivery_trip_entity.dart';
import '../../domain/fake_data/driver_active_delivery_fake_data.dart';
import '../widgets/delivery_delay_actions.dart';
import '../widgets/delivery_delay_header.dart';
import '../widgets/delivery_delay_hero_banner.dart';
import '../widgets/delivery_delay_info_card.dart';

class DriverDeliveryDelayScreen extends StatelessWidget {
  const DriverDeliveryDelayScreen({
    super.key,
    this.trip,
    this.onContinueDelivery,
    this.onContactSupport,
  });

  final ActiveDeliveryTripEntity? trip;
  final VoidCallback? onContinueDelivery;
  final VoidCallback? onContactSupport;

  void _handleContinue(BuildContext context) {
    if (onContinueDelivery != null) {
      onContinueDelivery!();
      return;
    }
    context.pop();
  }

  void _handleContactSupport(BuildContext context) {
    if (onContactSupport != null) {
      onContactSupport!();
      return;
    }
    unawaited(context.pushNamed(AppRoutes.driverSupport));
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final currentTrip = trip ?? DriverActiveDeliveryFakeData.defaultTrip;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: DeliveryDelayHeader(onBackPressed: () => context.maybePopRoute()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.base,
            vertical: Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const DeliveryDelayHeroBanner(),
              const SizedBox(height: Spacing.base),
              DeliveryDelayInfoCard(order: currentTrip.order),
              const SizedBox(height: Spacing.xl),
              DeliveryDelayActions(
                onContinueDelivery: () => _handleContinue(context),
                onContactSupport: () => _handleContactSupport(context),
              ),
              const SizedBox(height: Spacing.base),
            ],
          ),
        ),
      ),
    );
  }
}
