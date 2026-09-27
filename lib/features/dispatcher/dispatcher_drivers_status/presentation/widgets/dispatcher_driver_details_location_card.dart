import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/dispatcher_driver_location_entity.dart';

class DispatcherDriverDetailsLocationCard extends StatelessWidget {
  const DispatcherDriverDetailsLocationCard({
    super.key,
    required this.location,
    this.onShowOnMap,
  });

  final DispatcherDriverLocationEntity location;
  final VoidCallback? onShowOnMap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.base),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
          width: Spacing.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: Spacing.iconSm,
                color: color.primary,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                locale.driverDetailsLocationTitle,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size13,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                location.areaName,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size13,
                ),
              ),
              Text(
                locale.driverDetailsUpdatedTwoMinAgo,
                style: getRegularStyle(
                  color: color.onSurfaceVariant,
                  fontSize: FontSize.size11,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(Spacing.radiusSm),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  location.mapPreviewAsset,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 110,
                    color: color.surfaceContainerHighest,
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.map_outlined,
                      size: Spacing.iconLg,
                      color: color.onSurfaceVariant,
                    ),
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: color.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.location_on_rounded,
                      size: Spacing.iconSm,
                      color: color.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onShowOnMap,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: color.primary.withValues(alpha: 0.5),
                  width: Spacing.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                padding: const EdgeInsets.symmetric(vertical: Spacing.xs * 1.5),
              ),
              icon: Icon(
                Icons.map_outlined,
                size: Spacing.iconSm,
                color: color.primary,
              ),
              label: Text(
                locale.driverDetailsShowOnMap,
                style: getSemiBoldStyle(
                  color: color.primary,
                  fontSize: FontSize.size12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
