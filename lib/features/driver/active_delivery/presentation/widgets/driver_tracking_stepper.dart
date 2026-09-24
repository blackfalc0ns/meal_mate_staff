import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/delivery_trip_status.dart';

class DriverTrackingStepper extends StatelessWidget {
  const DriverTrackingStepper({super.key, required this.status});

  final DeliveryTripStatus status;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final isEnRouteOrBeyond =
        status == DeliveryTripStatus.enRoute ||
        status == DeliveryTripStatus.arrived ||
        status == DeliveryTripStatus.delivered ||
        status == DeliveryTripStatus.delayed;

    final isArrivedOrBeyond =
        status == DeliveryTripStatus.arrived ||
        status == DeliveryTripStatus.delivered;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(color: color.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Step 1: Start
          _buildStepItem(
            color: color,
            icon: Icons.check,
            isCompleted: true,
            isActive: false,
            label: locale.driverTripStepStart,
          ),
          Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: Spacing.xs),
              decoration: BoxDecoration(
                color: isEnRouteOrBeyond
                    ? color.primary
                    : color.primaryContainer,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Step 2: En Route
          _buildStepItem(
            color: color,
            icon: Icons.local_shipping,
            isCompleted: isArrivedOrBeyond,
            isActive:
                status == DeliveryTripStatus.enRoute ||
                status == DeliveryTripStatus.delayed,
            label: locale.driverTripStepEnRoute,
          ),
          Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: Spacing.xs),
              decoration: BoxDecoration(
                color: isArrivedOrBeyond
                    ? color.primary
                    : color.primaryContainer,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Step 3: Arrived
          _buildStepItem(
            color: color,
            icon: Icons.check,
            isCompleted: status == DeliveryTripStatus.delivered,
            isActive: status == DeliveryTripStatus.arrived,
            label: locale.driverTripStepArrived,
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required ColorScheme color,
    required IconData icon,
    required bool isCompleted,
    required bool isActive,
    required String label,
  }) {
    if (isActive) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: color.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: color.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: Spacing.iconSm, color: color.onPrimary),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            label,
            style: getSemiBoldStyle(
              fontSize: FontSize.size10,
              color: color.primary,
            ),
          ),
        ],
      );
    }

    final Color iconColor = isCompleted
        ? color.primary
        : color.onSurfaceVariant.withValues(alpha: 0.5);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: color.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: Spacing.iconXs, color: iconColor),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          label,
          style: getRegularStyle(
            fontSize: FontSize.size10,
            color: isCompleted ? color.onSurface : color.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
