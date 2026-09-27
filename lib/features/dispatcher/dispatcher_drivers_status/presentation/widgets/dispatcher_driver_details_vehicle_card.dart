import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../../../core/widget/custom_snak_bar.dart';
import '../../domain/entities/dispatcher_driver_vehicle_entity.dart';

class DispatcherDriverDetailsVehicleCard extends StatelessWidget {
  const DispatcherDriverDetailsVehicleCard({
    super.key,
    required this.vehicle,
    this.onTap,
  });

  final DispatcherDriverVehicleEntity vehicle;
  final VoidCallback? onTap;

  void _handleCopyPlate(BuildContext context) {
    unawaited(Clipboard.setData(ClipboardData(text: vehicle.plateNumber)));
    CustomSnackbar.showSuccess(
      context: context,
      message: context.localization.driverDetailsCopiedToClipboard,
    );
  }

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
                Icons.directions_car_outlined,
                size: Spacing.iconSm,
                color: color.primary,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                locale.driverDetailsVehicleInfoTitle,
                style: getBoldStyle(
                  color: color.onSurface,
                  fontSize: FontSize.size13,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(Spacing.radiusSm),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Spacing.radiusXs),
                  child: Image.asset(
                    vehicle.imageAsset,
                    width: 76,
                    height: 48,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.directions_car_rounded,
                      size: Spacing.iconLg,
                      color: color.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.model,
                        style: getBoldStyle(
                          color: color.onSurface,
                          fontSize: FontSize.size13,
                        ),
                      ),
                      const SizedBox(height: Spacing.xs / 2),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: color.outline,
                                width: Spacing.border,
                              ),
                            ),
                          ),
                          const SizedBox(width: Spacing.xs / 2),
                          Text(
                            vehicle.colorName,
                            style: getRegularStyle(
                              color: color.onSurfaceVariant,
                              fontSize: FontSize.size11,
                            ),
                          ),
                          const SizedBox(width: Spacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.xs,
                              vertical: Spacing.xs / 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.surfaceContainerHighest,
                              borderRadius:
                                  BorderRadius.circular(Spacing.radiusXs),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  vehicle.plateNumber,
                                  style: getSemiBoldStyle(
                                    color: color.onSurface,
                                    fontSize: FontSize.size11,
                                  ),
                                ),
                                const SizedBox(width: Spacing.xs / 4),
                                InkWell(
                                  onTap: () => _handleCopyPlate(context),
                                  child: Icon(
                                    Icons.copy_rounded,
                                    size: Spacing.iconXs * 0.8,
                                    color: color.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: Spacing.iconXs,
                  color: color.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
