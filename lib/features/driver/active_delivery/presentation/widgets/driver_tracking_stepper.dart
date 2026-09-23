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
        horizontal: Spacing.base,
        vertical: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.outline),
      ),
      child: Row(
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
              height: 2,
              color: isEnRouteOrBeyond ? color.primary : color.outline,
            ),
          ),
          // Step 2: En Route
          _buildStepItem(
            color: color,
            icon: Icons.directions_car,
            isCompleted: isArrivedOrBeyond,
            isActive:
                status == DeliveryTripStatus.enRoute ||
                status == DeliveryTripStatus.delayed,
            label: locale.driverTripStepEnRoute,
          ),
          Expanded(
            child: Container(
              height: 2,
              color: isArrivedOrBeyond ? color.primary : color.outline,
            ),
          ),
          // Step 3: Arrived
          _buildStepItem(
            color: color,
            icon: Icons.place,
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
    final Color bgColor;
    final Color iconColor;
    final Color textColor;

    if (isCompleted) {
      bgColor = color.primary;
      iconColor = color.onPrimary;
      textColor = color.primary;
    } else if (isActive) {
      bgColor = color.primaryContainer;
      iconColor = color.primary;
      textColor = color.primary;
    } else {
      bgColor = color.surfaceContainerHighest;
      iconColor = color.onSurfaceVariant;
      textColor = color.onSurfaceVariant;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? color.primary : color.outline,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Icon(icon, size: Spacing.iconSm, color: iconColor),
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          label,
          style: getMediumStyle(fontSize: FontSize.size11, color: textColor),
        ),
      ],
    );
  }
}
