import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/active_delivery_trip_entity.dart';
import '../../domain/entities/return_box_entity.dart';
import '../../domain/fake_data/driver_active_delivery_fake_data.dart';
import '../widgets/return_box_actions.dart';
import '../widgets/return_box_form.dart';
import '../widgets/return_box_header.dart';
import '../widgets/return_box_map_view.dart';
import '../widgets/return_box_status_card.dart';

class DriverReturnBoxToRestaurantScreen extends StatelessWidget {
  const DriverReturnBoxToRestaurantScreen({
    super.key,
    this.trip,
    this.returnBox,
    this.onConfirmReturn,
  });

  final ActiveDeliveryTripEntity? trip;
  final ReturnBoxEntity? returnBox;
  final VoidCallback? onConfirmReturn;

  void _handleConfirmReturn(BuildContext context) {
    if (onConfirmReturn != null) {
      onConfirmReturn!();
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
    final currentReturnBox =
        returnBox ??
        currentTrip.returnBox ??
        DriverActiveDeliveryFakeData.createReturnBox(
          failureReason: 'العميل لا يجيب على الهاتف',
        );

    return Scaffold(
      backgroundColor: color.surface,
      appBar: ReturnBoxHeader(onBackPressed: () => context.maybePopRoute()),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.base,
            vertical: Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ReturnBoxMapView(
                driverLocation: currentTrip.driverLocation,
                restaurantLocation: currentTrip.restaurantLocation,
                returnRoutePoints:
                    DriverActiveDeliveryFakeData.returnRoutePoints,
              ),
              const SizedBox(height: Spacing.base),
              ReturnBoxStatusCard(returnBox: currentReturnBox),
              const SizedBox(height: Spacing.base),
              ReturnBoxForm(
                note: currentReturnBox.note,
                attachmentPath: currentReturnBox.attachmentPath,
                onAttachImagePressed: () {},
              ),
              const SizedBox(height: Spacing.xl),
              ReturnBoxActions(
                onConfirmReturn: () => _handleConfirmReturn(context),
              ),
              const SizedBox(height: Spacing.base),
            ],
          ),
        ),
      ),
    );
  }
}
