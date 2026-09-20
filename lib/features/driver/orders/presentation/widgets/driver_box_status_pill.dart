import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_box_delivery_status.dart';

class DriverBoxStatusPill extends StatelessWidget {
  const DriverBoxStatusPill({
    super.key,
    this.status = DriverBoxDeliveryStatus.ready,
    this.isLoaded,
  });

  final DriverBoxDeliveryStatus status;
  final bool? isLoaded;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final effectiveStatus = status;

    if (effectiveStatus == DriverBoxDeliveryStatus.notLoaded) {
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

    final bool isIssue = effectiveStatus == DriverBoxDeliveryStatus.failed;
    final Color bgColor = isIssue
        ? color.errorContainer
        : color.tertiaryContainer;
    final Color contentColor = isIssue ? color.error : color.tertiary;
    final String label = isIssue
        ? locale.driverStatusIssueOccurred
        : locale.driverStatusReadyForDelivery;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: Spacing.accountStatusReasonBullet,
            height: Spacing.accountStatusReasonBullet,
            decoration: BoxDecoration(
              color: contentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Text(
            label,
            style: getMediumStyle(
              color: contentColor,
              fontSize: FontSize.size10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
