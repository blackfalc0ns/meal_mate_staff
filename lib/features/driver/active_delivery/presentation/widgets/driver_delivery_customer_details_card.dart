import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../../map/domain/entities/driver_map_stop_entity.dart';

class DriverDeliveryCustomerDetailsCard extends StatelessWidget {
  const DriverDeliveryCustomerDetailsCard({
    super.key,
    required this.stop,
  });

  final DriverMapStopEntity stop;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.outlineVariant.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: color.primary,
                  size: Spacing.iconMd,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.driverStartRouteCustomerLabel,
                      style: getRegularStyle(
                        fontSize: FontSize.size10,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Spacing.border),
                    Text(
                      stop.customerName,
                      style: getBoldStyle(
                        fontSize: FontSize.size14,
                        color: color.onSurface,
                      ),
                    ),
                    const SizedBox(height: Spacing.border),
                    Text(
                      stop.formattedAddress,
                      style: getRegularStyle(
                        fontSize: FontSize.size10,
                        color: color.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      locale.driverOrderNumberLabel,
                      style: getRegularStyle(
                        fontSize: FontSize.size10,
                        color: color.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      stop.boxCode,
                      style: getSemiBoldStyle(
                        fontSize: FontSize.size12,
                        color: color.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Container(
                height: 28,
                width: 1,
                color: color.outlineVariant.withValues(alpha: 0.5),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      locale.driverStartRouteBoxesCountLabel,
                      style: getRegularStyle(
                        fontSize: FontSize.size10,
                        color: color.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      locale.driverStartRouteBoxesCountValue(stop.mealsCount),
                      style: getSemiBoldStyle(
                        fontSize: FontSize.size12,
                        color: color.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              Container(
                height: 28,
                width: 1,
                color: color.outlineVariant.withValues(alpha: 0.5),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      locale.driverStartRouteExpectedDeliveryTimeLabel,
                      style: getRegularStyle(
                        fontSize: FontSize.size10,
                        color: color.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      stop.deliveryTimeSlot,
                      style: getSemiBoldStyle(
                        fontSize: FontSize.size12,
                        color: color.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if ((stop.customerNote ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: Spacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm + 2,
              ),
              decoration: BoxDecoration(
                color: color.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: color.primary,
                      borderRadius: BorderRadius.circular(Spacing.radiusXs),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.subject_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locale.driverStartRouteCustomerNotesTitle,
                          style: getSemiBoldStyle(
                            fontSize: FontSize.size11,
                            color: color.onSurface,
                          ),
                        ),
                        const SizedBox(height: Spacing.border),
                        Text(
                          stop.customerNote!,
                          style: getRegularStyle(
                            fontSize: FontSize.size10,
                            color: color.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
