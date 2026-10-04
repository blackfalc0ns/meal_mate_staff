import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_box_not_assigned_entity.dart';
import '../widgets/driver_box_not_assigned_actions.dart';
import '../widgets/driver_box_not_assigned_card.dart';
import '../widgets/driver_box_not_assigned_header.dart';
import '../widgets/driver_box_not_assigned_illustration.dart';
import '../widgets/driver_box_not_assigned_info_card.dart';

class DriverBoxNotAssignedScreen extends StatelessWidget {
  const DriverBoxNotAssignedScreen({
    super.key,
    this.box,
    this.onScanAnotherCode,
    this.onContactRestaurant,
    this.onReturnToBoxesList,
  });

  final DriverBoxNotAssignedEntity? box;
  final VoidCallback? onScanAnotherCode;
  final VoidCallback? onContactRestaurant;
  final VoidCallback? onReturnToBoxesList;

  void _handleScanAnotherCode(BuildContext context) {
    if (onScanAnotherCode != null) {
      onScanAnotherCode!();
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      unawaited(
        Navigator.of(context).pushReplacementNamed(
          AppRoutes.driverConfirmReceipt,
        ),
      );
    }
  }

  void _handleContactRestaurant(BuildContext context) {
    if (onContactRestaurant != null) {
      onContactRestaurant!();
      return;
    }
    unawaited(
      Navigator.of(context).pushNamed(AppRoutes.driverActiveCall),
    );
  }

  void _handleReturnToBoxesList(BuildContext context) {
    if (onReturnToBoxesList != null) {
      onReturnToBoxesList!();
      return;
    }
    unawaited(
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.driverAssignedBoxes,
        (route) => false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final item = box ?? const DriverBoxNotAssignedEntity(boxCode: '');

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
              const DriverBoxNotAssignedIllustration(),
              const SizedBox(height: Spacing.md),
              const DriverBoxNotAssignedHeader(),
              const SizedBox(height: Spacing.lg),
              DriverBoxNotAssignedCard(boxCode: item.boxCode),
              const SizedBox(height: Spacing.md),
              const DriverBoxNotAssignedInfoCard(),
              const SizedBox(height: Spacing.xl),
              DriverBoxNotAssignedActions(
                onScanAnotherCode: () => _handleScanAnotherCode(context),
                onContactRestaurant: () => _handleContactRestaurant(context),
                onReturnToBoxesList: () => _handleReturnToBoxesList(context),
              ),
              const SizedBox(height: Spacing.base),
            ],
          ),
        ),
      ),
    );
  }
}
