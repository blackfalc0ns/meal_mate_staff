import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/active_delivery_trip_entity.dart';
import '../../domain/entities/delivery_failure_reason_entity.dart';
import '../../domain/fake_data/driver_active_delivery_fake_data.dart';
import '../widgets/failed_delivery_actions.dart';
import '../widgets/failed_delivery_header.dart';
import '../widgets/failed_delivery_hero_card.dart';
import '../widgets/failed_delivery_reason_selector.dart';

class DriverFailedDeliveryScreen extends StatefulWidget {
  const DriverFailedDeliveryScreen({
    super.key,
    this.trip,
    this.reasons,
    this.onSubmitReport,
    this.onRetry,
  });

  final ActiveDeliveryTripEntity? trip;
  final List<DeliveryFailureReasonEntity>? reasons;
  final void Function(String reasonId, String note)? onSubmitReport;
  final VoidCallback? onRetry;

  @override
  State<DriverFailedDeliveryScreen> createState() =>
      _DriverFailedDeliveryScreenState();
}

class _DriverFailedDeliveryScreenState
    extends State<DriverFailedDeliveryScreen> {
  late final TextEditingController _noteController;
  late String _selectedReasonId;
  late final List<DeliveryFailureReasonEntity> _reasons;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _reasons = widget.reasons ?? DriverActiveDeliveryFakeData.failureReasons;
    _selectedReasonId = _reasons.isNotEmpty ? _reasons.first.id : '';
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final note = _noteController.text.trim();
    if (widget.onSubmitReport != null) {
      widget.onSubmitReport!(_selectedReasonId, note);
      return;
    }
    final currentTrip = widget.trip ?? DriverActiveDeliveryFakeData.defaultTrip;
    final selectedReason = _reasons.firstWhere(
      (r) => r.id == _selectedReasonId,
      orElse: () => _reasons.first,
    );
    final returnBox = DriverActiveDeliveryFakeData.createReturnBox(
      failureReason: selectedReason.title,
      note: note.isNotEmpty ? note : null,
    );
    final updatedTrip = currentTrip.copyWith(
      failureReason: selectedReason,
      returnBox: returnBox,
    );

    unawaited(
      context.pushReplacementNamed(
        AppRoutes.driverReturnBoxToRestaurant,
        arguments: updatedTrip,
      ),
    );
  }

  void _handleRetry() {
    if (widget.onRetry != null) {
      widget.onRetry!();
      return;
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;

    return Scaffold(
      backgroundColor: color.surface,
      appBar: FailedDeliveryHeader(
        onBackPressed: () => context.maybePopRoute(),
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
              const FailedDeliveryHeroCard(),
              const SizedBox(height: Spacing.base),
              FailedDeliveryReasonSelector(
                reasons: _reasons,
                selectedReasonId: _selectedReasonId,
                noteController: _noteController,
                onReasonSelected: (id) {
                  setState(() {
                    _selectedReasonId = id;
                  });
                },
              ),
              const SizedBox(height: Spacing.xl),
              FailedDeliveryActions(
                onSubmit: _handleSubmit,
                onRetry: _handleRetry,
              ),
              const SizedBox(height: Spacing.base),
            ],
          ),
        ),
      ),
    );
  }
}
