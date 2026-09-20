import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverEditVehiclePhotoCard extends StatelessWidget {
  const DriverEditVehiclePhotoCard({
    super.key,
    required this.imageAsset,
    this.onChangePhotoTap,
  });

  final String imageAsset;
  final VoidCallback? onChangePhotoTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: color.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.outline, width: Spacing.border),
      ),
      child: Row(
        children: [
          // Info & Change Photo button (Start / Right in RTL)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  locale.driverEditVehiclePhotoTitle,
                  style: getBoldStyle(
                    color: color.onSurface,
                    fontSize: FontSize.size14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  locale.driverEditVehiclePhotoSubtitle,
                  style: getRegularStyle(
                    color: color.onSurfaceVariant,
                    fontSize: FontSize.size11,
                  ),
                ),
                const SizedBox(height: Spacing.sm),
                InkWell(
                  onTap: onChangePhotoTap,
                  borderRadius: BorderRadius.circular(Spacing.radiusLg),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.sm,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.primaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(Spacing.radiusLg),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          size: Spacing.iconSm,
                          color: color.primary,
                        ),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          locale.driverVehicleChangePhoto,
                          style: getBoldStyle(
                            color: color.primary,
                            fontSize: FontSize.size11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.md),
          // Vehicle Image Container (End / Left in RTL)
          Container(
            width: 140,
            height: 90,
            decoration: BoxDecoration(
              color: color.surface,
              borderRadius: BorderRadius.circular(Spacing.radiusMd),
              border: Border.all(color: color.outline, width: Spacing.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(Spacing.radiusMd),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Icon(
                  Icons.directions_car_rounded,
                  size: 40,
                  color: color.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
