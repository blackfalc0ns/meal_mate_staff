import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverCallAddressCard extends StatelessWidget {
  const DriverCallAddressCard({
    super.key,
    required this.addressLine,
    required this.area,
  });

  final String addressLine;
  final String area;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.screenH),
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: color.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Spacing.radiusLg),
        border: Border.all(
          color: color.primary.withValues(alpha: 0.22),
          width: Spacing.border,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  locale.driverCallAddressTitle,
                  style: getRegularStyle(
                    fontSize: FontSize.size12,
                    color: color.onPrimary.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  addressLine,
                  style: getMediumStyle(
                    fontSize: FontSize.size14,
                    color: color.onPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Spacing.xs),
                Text(
                  area,
                  style: getRegularStyle(
                    fontSize: FontSize.size12,
                    color: color.primaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.primary.withValues(alpha: 0.2),
            ),
            child: Icon(
              Icons.location_on_outlined,
              size: Spacing.iconMd,
              color: color.primary,
            ),
          ),
        ],
      ),
    );
  }
}
