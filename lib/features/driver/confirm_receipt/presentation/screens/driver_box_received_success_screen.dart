import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_box_received_success_entity.dart';
import '../../domain/fake_data/driver_box_received_success_fake_data.dart';
import '../widgets/driver_box_received_details_card.dart';
import '../widgets/driver_box_received_next_button.dart';
import '../widgets/driver_box_received_safety_card.dart';
import '../widgets/driver_box_received_success_header.dart';
import '../widgets/driver_box_received_success_illustration.dart';

class DriverBoxReceivedSuccessScreen extends StatelessWidget {
  const DriverBoxReceivedSuccessScreen({
    super.key,
    this.box,
    this.onNextOrder,
  });

  final DriverBoxReceivedSuccessEntity? box;
  final VoidCallback? onNextOrder;

  void _handleNextOrder(BuildContext context) {
    if (onNextOrder != null) {
      onNextOrder!();
      return;
    }
    unawaited(
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.driverAssignedBoxes, (route) => false),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final item = box ?? DriverBoxReceivedSuccessFakeData.defaultSuccessBox;

    return Scaffold(
      backgroundColor: color.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.base,
            vertical: Spacing.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: Spacing.sm),
              const DriverBoxReceivedSuccessIllustration(),
              const SizedBox(height: Spacing.md),
              const DriverBoxReceivedSuccessHeader(),
              const SizedBox(height: Spacing.lg),
              DriverBoxReceivedDetailsCard(box: item),
              const SizedBox(height: Spacing.md),
              const DriverBoxReceivedSafetyCard(),
              const SizedBox(height: Spacing.lg),
              DriverBoxReceivedNextButton(
                onPressed: () => _handleNextOrder(context),
              ),
              const SizedBox(height: Spacing.base),
            ],
          ),
        ),
      ),
    );
  }
}
