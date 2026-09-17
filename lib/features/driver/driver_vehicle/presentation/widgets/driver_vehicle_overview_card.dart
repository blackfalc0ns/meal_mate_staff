import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_vehicle_entity.dart';

class DriverVehicleOverviewCard extends StatelessWidget {
  const DriverVehicleOverviewCard({
    super.key,
    required this.vehicle,
    this.onChangePhotoTap,
  });

  final DriverVehicleEntity vehicle;
  final VoidCallback? onChangePhotoTap;

  Widget _buildSpecItem({
    required BuildContext context,
    required String label,
    required String value,
    Widget? customIcon,
    IconData? icon,
  }) {
    final color = context.colorScheme;

    return Row(
      children: [
        customIcon ??
            Container(
              width: 32,
              height: 30,
              decoration: BoxDecoration(
                color: color.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
              ),
              child: Icon(
                icon ?? Icons.directions_car_rounded,
                size: Spacing.iconSm + 2,
                color: color.primary,
              ),
            ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: getRegularStyle(
                  color: color.onSurfaceVariant,
                  fontSize: FontSize.size10,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorSwatch(ColorScheme color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
      ),
      child: Center(
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.surface,
            shape: BoxShape.circle,
            border: Border.all(color: color.outline, width: Spacing.border),
          ),
        ),
      ),
    );
  }

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Right side in RTL (Start): Specs Column
          Expanded(
            flex: 6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSpecItem(
                  context: context,
                  label: locale.driverVehicleTypeLabel,
                  value: vehicle.brandAndModel,
                  icon: Icons.directions_car_outlined,
                ),
                Divider(
                  height: Spacing.md * 2,
                  thickness: Spacing.hairline,
                  color: color.outline.withValues(alpha: 0.5),
                ),
                _buildSpecItem(
                  context: context,
                  label: locale.driverVehicleColorLabel,
                  value: vehicle.colorName,
                  customIcon: _buildColorSwatch(color),
                ),
                Divider(
                  height: Spacing.md * 2,
                  thickness: Spacing.hairline,
                  color: color.outline.withValues(alpha: 0.5),
                ),
                _buildSpecItem(
                  context: context,
                  label: locale.driverVehicleYearLabel,
                  value: vehicle.manufactureYear,
                  icon: Icons.calendar_today_outlined,
                ),
                Divider(
                  height: Spacing.md * 2,
                  thickness: Spacing.hairline,
                  color: color.outline.withValues(alpha: 0.5),
                ),
                _buildSpecItem(
                  context: context,
                  label: locale.driverVehicleStructureLabel,
                  value: vehicle.bodyType,
                  icon: Icons.directions_car_filled_outlined,
                ),
              ],
            ),
          ),
          const SizedBox(width: Spacing.sm),
          // Vertical divider line
          Container(
            width: Spacing.hairline,
            height: 180,
            color: color.outline.withValues(alpha: 0.6),
          ),
          const SizedBox(width: Spacing.sm),
          // Left side in RTL (End): Car Image + Change Photo button
          Expanded(
            flex: 5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 130,
                  height: 110,
                  decoration: BoxDecoration(
                    color: color.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Image.asset(
                            vehicle.imageAsset,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Icon(
                              Icons.directions_car_rounded,
                              size: 48,
                              color: color.primary,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        child: InkWell(
                          onTap: onChangePhotoTap,
                          borderRadius: BorderRadius.circular(Spacing.radiusLg),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.sm,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.surface,
                              borderRadius: BorderRadius.circular(
                                Spacing.radiusLg,
                              ),
                              border: Border.all(
                                color: color.outline,
                                width: Spacing.border,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.shadow.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined,
                                  size: Spacing.iconXs,
                                  color: color.primary,
                                ),
                                const SizedBox(width: Spacing.xs),
                                Text(
                                  locale.driverVehicleChangePhoto,
                                  style: getMediumStyle(
                                    color: color.primary,
                                    fontSize: FontSize.size10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
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
