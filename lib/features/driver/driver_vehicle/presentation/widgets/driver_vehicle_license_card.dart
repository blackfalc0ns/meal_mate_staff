import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_vehicle_entity.dart';
import 'driver_vehicle_kuwait_plate.dart';

class DriverVehicleLicenseCard extends StatelessWidget {
  const DriverVehicleLicenseCard({super.key, required this.vehicle});

  final DriverVehicleEntity vehicle;

  Widget _buildRowItem({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    final color = context.colorScheme;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(Spacing.radiusSm),
          ),
          child: Icon(icon, size: Spacing.iconSm + 2, color: color.primary),
        ),
        const SizedBox(width: Spacing.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: getRegularStyle(
                  color: color.onSurfaceVariant,
                  fontSize: FontSize.size11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size12,
                ),
              ),
            ],
          ),
        ),
      ],
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Title & Icon
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Icon(
                  Icons.badge_outlined,
                  size: Spacing.iconSm,
                  color: color.primary,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                locale.driverVehiclePlateTitle,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size13,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.base),
          // Plate Graphic
          DriverVehicleKuwaitPlate(
            plateNumber: vehicle.plateNumber,
            plateLetter: vehicle.plateLetter,
            plateLetterEn: vehicle.plateLetterEn,
          ),
          const SizedBox(height: Spacing.base),
          Divider(height: 1, thickness: Spacing.border, color: color.outline),
          const SizedBox(height: Spacing.xs),
          _buildRowItem(
            context: context,
            label: locale.driverVehicleLicenseNumberLabel,
            value: vehicle.licenseNumber,
            icon: Icons.credit_card_outlined,
          ),
          const SizedBox(height: Spacing.sm),
          Divider(height: 1, thickness: Spacing.border, color: color.outline),
          const SizedBox(height: Spacing.sm),
          _buildRowItem(
            context: context,
            label: locale.driverVehicleLicenseExpiryLabel,
            value: vehicle.licenseExpiryDate,
            icon: Icons.calendar_today_outlined,
          ),
        ],
      ),
    );
  }
}
