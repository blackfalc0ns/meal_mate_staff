import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/colors.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

class DriverActiveStatusChip extends StatelessWidget {
  const DriverActiveStatusChip({
    super.key,
    this.statusText,
  });

  final String? statusText;

  static const double _dotSize = 6;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final resolvedText = statusText ?? locale.driverStatusInDelivery;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.driverActiveStatusBg,
        borderRadius: BorderRadius.circular(Spacing.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            locale.driverCurrentStatusLabel,
            style: getRegularStyle(
              fontSize: FontSize.size11,
              color: color.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Container(
            width: _dotSize,
            height: _dotSize,
            decoration: BoxDecoration(
              color: color.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Text(
            resolvedText,
            style: getBoldStyle(
              fontSize: FontSize.size11,
              color: color.success,
            ),
          ),
        ],
      ),
    );
  }
}
