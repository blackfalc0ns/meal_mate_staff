import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_profile_entity.dart';

class DriverProfileVehicleCard extends StatelessWidget {
  const DriverProfileVehicleCard({
    super.key,
    required this.profile,
  });

  final DriverProfileEntity profile;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outline,
          width: Spacing.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.directions_car_outlined,
                    size: Spacing.iconSm,
                    color: color.primary,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Text(
                    locale.driverVehicleInfo,
                    style: getBoldStyle(
                      color: color.onSurface,
                      fontSize: FontSize.size14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs / 2,
                ),
                decoration: BoxDecoration(
                  color: color.tertiaryContainer,
                  borderRadius: BorderRadius.circular(Spacing.radiusPill),
                ),
                child: Text(
                  locale.driverVehicleActive,
                  style: getMediumStyle(
                    color: color.tertiary,
                    fontSize: FontSize.size10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.driverVehicleType,
                      style: getRegularStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size11,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs / 2),
                    Text(
                      profile.vehicleType,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.driverVehicleModel,
                      style: getRegularStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size11,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs / 2),
                    Text(
                      profile.vehicleModel,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.driverPlateNumber,
                      style: getRegularStyle(
                        color: color.onSurfaceVariant,
                        fontSize: FontSize.size11,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs / 2),
                    Text(
                      profile.plateNumber,
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
          ),
        ],
      ),
    );
  }
}
