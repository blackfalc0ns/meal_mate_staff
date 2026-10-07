import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/routing/arguments/driver_active_delivery_route_arguments.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/active_delivery_order_entity.dart';
import '../../domain/entities/active_delivery_trip_entity.dart';
import '../../domain/fake_data/driver_active_delivery_fake_data.dart';
import '../manager/active_delivery_view_model.dart';
import '../widgets/delivery_success_action_button.dart';
import '../widgets/delivery_success_header.dart';
import '../widgets/delivery_success_hero_banner.dart';
import '../widgets/delivery_success_summary_card.dart';

class DriverDeliverySuccessScreen extends StatelessWidget {
  const DriverDeliverySuccessScreen({
    super.key,
    this.trip,
    this.arguments,
    this.viewModel,
    this.onConfirmed,
    this.onBackToOrders,
  });

  final ActiveDeliveryTripEntity? trip;
  final DriverActiveDeliveryRouteArguments? arguments;
  final ActiveDeliveryViewModel? viewModel;
  final VoidCallback? onConfirmed;
  final VoidCallback? onBackToOrders;

  void _handleConfirmed(BuildContext context) {
    if (onConfirmed != null) {
      onConfirmed!();
      return;
    }

    final vm = viewModel ??
        (getIt.isRegistered<ActiveDeliveryViewModel>()
            ? getIt<ActiveDeliveryViewModel>()
            : null);

    if (vm != null) {
      final currentStopId = arguments?.stopId ?? vm.state.selectedStopId;
      final nextStops = vm.state.route?.stops
              .where((s) => !s.isDelivered && s.id != currentStopId)
              .toList() ??
          [];
      if (nextStops.isNotEmpty) {
        unawaited(
          context.pushReplacementNamed(
            AppRoutes.driverStartDeliveryRoute,
            arguments: DriverActiveDeliveryRouteArguments(
              stopId: nextStops.first.id,
              tripId: vm.state.route?.tripId ?? arguments?.tripId,
            ),
          ),
        );
        return;
      }
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
    final completedStop = arguments?.completedStop;
    final currentOrder = (completedStop != null)
        ? ActiveDeliveryOrderEntity(
            orderId: completedStop.boxCode,
            boxCode: completedStop.boxCode,
            customerName: completedStop.customerName,
            customerPhone: completedStop.customerPhone,
            customerAvatar: '',
            address: completedStop.formattedAddress,
            mealsCount: completedStop.mealsCount,
            customerNote: completedStop.customerNote ?? '',
            restaurantName: 'MealMate',
            restaurantAddress: '',
            paymentMethod: 'Prepaid',
          )
        : (trip?.order ?? DriverActiveDeliveryFakeData.defaultTrip.order);

    final deliveredTimeText = arguments?.deliveryResult != null
        ? '${arguments!.deliveryResult!.deliveredAtUtc.toLocal().hour.toString().padLeft(2, '0')}:${arguments!.deliveryResult!.deliveredAtUtc.toLocal().minute.toString().padLeft(2, '0')}'
        : '02:30 م';

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
              DeliverySuccessSummaryCard(
                order: currentOrder,
                deliveredTimeText: deliveredTimeText,
              ),
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
