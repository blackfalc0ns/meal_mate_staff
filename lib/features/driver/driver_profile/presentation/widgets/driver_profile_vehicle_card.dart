import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_profile_vehicle_entity.dart';

class DriverProfileVehicleCard extends StatelessWidget {
  const DriverProfileVehicleCard({
    super.key,
    this.vehicle,
    this.onTap,
  });

  final DriverProfileVehicleEntity? vehicle;
  final VoidCallback? onTap;

  static const double _activeDotSize = 7.0;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    if (vehicle == null) {
      return Container(
        key: const Key('driver_profile_vehicle_empty'),
        decoration: BoxDecoration(
          color: color.surface,
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          border: Border.all(
            color: color.outlineVariant,
            width: Spacing.border,
          ),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.base,
          vertical: Spacing.md,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_car_outlined,
                  size: 20,
                  color: color.primary,
                ),
                const SizedBox(width: Spacing.sm),
                Text(
                  locale.driverVehicleInfo,
                  style: getBoldStyle(
                    fontSize: FontSize.size13,
                    color: color.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              locale.driverVehicleEmpty,
              style: getRegularStyle(
                fontSize: FontSize.size12,
                color: color.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    final v = vehicle!;

    final modelParts = <String>[];
    if (v.vehicleModel != null && v.vehicleModel!.isNotEmpty) {
      modelParts.add(v.vehicleModel!);
    }
    if (v.vehicleYear != null) {
      modelParts.add('(${v.vehicleYear})');
    }
    final modelYearText = modelParts.isNotEmpty ? modelParts.join(' ') : '-';

    Color verificationBg = color.tertiaryContainer;
    Color verificationFg = color.tertiary;

    final status = v.verificationStatus?.toLowerCase();
    if (status == 'pending' || status == 'underreview') {
      verificationBg = color.primaryContainer;
      verificationFg = color.primary;
    } else if (status == 'rejected') {
      verificationBg = color.errorContainer;
      verificationFg = color.error;
    }

    return Container(
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant,
          width: Spacing.border,
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.base,
        vertical: Spacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.directions_car_outlined,
                size: 20,
                color: color.primary,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  locale.driverVehicleInfo,
                  style: getBoldStyle(
                    fontSize: FontSize.size13,
                    color: color.onSurface,
                  ),
                ),
              ),
              if (v.verificationStatusText != null &&
                  v.verificationStatusText!.isNotEmpty) ...[
                Container(
                  key: Key(
                    'driver_vehicle_status_${v.verificationStatus?.toLowerCase()}',
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: verificationBg,
                    borderRadius: BorderRadius.circular(Spacing.radiusPill),
                  ),
                  child: Text(
                    v.verificationStatusText!,
                    style: getMediumStyle(
                      fontSize: FontSize.size10,
                      color: verificationFg,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.xs),
              ],
              if (v.isVehicleActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: color.tertiaryContainer,
                    borderRadius: BorderRadius.circular(Spacing.radiusPill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: _activeDotSize,
                        height: _activeDotSize,
                        decoration: BoxDecoration(
                          color: color.tertiary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(
                        locale.driverVehicleActive,
                        style: getMediumStyle(
                          fontSize: FontSize.size10,
                          color: color.tertiary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.driverVehicleType,
                      style: getRegularStyle(
                        fontSize: FontSize.size10,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      v.vehicleType ?? '-',
                      style: getBoldStyle(
                        fontSize: FontSize.size11,
                        color: color.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.driverVehicleModel,
                      style: getRegularStyle(
                        fontSize: FontSize.size10,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      modelYearText,
                      style: getBoldStyle(
                        fontSize: FontSize.size11,
                        color: color.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      locale.driverPlateNumber,
                      style: getRegularStyle(
                        fontSize: FontSize.size10,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      v.plateNumber ?? '-',
                      style: getBoldStyle(
                        fontSize: FontSize.size11,
                        color: color.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if ((v.color != null && v.color!.isNotEmpty) ||
              (v.plateGovernorate != null &&
                  v.plateGovernorate!.isNotEmpty)) ...[
            const SizedBox(height: Spacing.sm),
            const Divider(height: 1),
            const SizedBox(height: Spacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (v.color != null && v.color!.isNotEmpty)
                  Text(
                    '${locale.driverVehicleColor}: ${v.color}',
                    style: getRegularStyle(
                      fontSize: FontSize.size10,
                      color: color.onSurfaceVariant,
                    ),
                  ),
                if (v.plateGovernorate != null &&
                    v.plateGovernorate!.isNotEmpty)
                  Text(
                    '${locale.driverVehiclePlateGovernorate}: ${v.plateGovernorate}',
                    style: getRegularStyle(
                      fontSize: FontSize.size10,
                      color: color.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
