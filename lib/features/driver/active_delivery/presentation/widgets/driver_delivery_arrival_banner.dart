import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverDeliveryArrivalBanner extends StatelessWidget {
  const DriverDeliveryArrivalBanner({
    super.key,
    this.title,
    this.subtitle,
  });

  final String? title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F8F0),
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: const Color(0xFF28A745).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: Color(0xFF28A745),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: Spacing.iconMd,
            ),
          ),
          const SizedBox(width: Spacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? locale.driverTripStepArrived,
                  style: getBoldStyle(
                    fontSize: FontSize.size14,
                    color: const Color(0xFF1E7E34),
                  ),
                ),
                const SizedBox(height: Spacing.border),
                Text(
                  subtitle ?? locale.driverActiveTrackingEnRouteSubtitle,
                  style: getRegularStyle(
                    fontSize: FontSize.size11,
                    color: color.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
