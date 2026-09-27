import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_box_delivery_status.dart';

class DriverBoxStatusPill extends StatelessWidget {
  const DriverBoxStatusPill({
    super.key,
    this.status = DriverBoxDeliveryStatus.pendingScan,
    this.isLoaded,
  });

  final DriverBoxDeliveryStatus status;
  final bool? isLoaded;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final isPickedUp = (isLoaded ?? false) || status == DriverBoxDeliveryStatus.pickedUp;

    if (!isPickedUp) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
        decoration: BoxDecoration(
          color: color.primaryContainer,
          borderRadius: BorderRadius.circular(Spacing.radiusPill),
        ),
        child: Text(
          locale.driverStatusNotLoaded,
          style: getMediumStyle(
            color: color.primary,
            fontSize: FontSize.size10,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.tertiaryContainer,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: Spacing.accountStatusReasonBullet,
            height: Spacing.accountStatusReasonBullet,
            decoration: BoxDecoration(
              color: color.tertiary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Text(
            locale.driverStatusLoaded,
            style: getMediumStyle(
              color: color.tertiary,
              fontSize: FontSize.size10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
