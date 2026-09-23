import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/active_delivery_order_entity.dart';

class StartRouteCustomerCard extends StatelessWidget {
  const StartRouteCustomerCard({
    super.key,
    required this.order,
    required this.estimatedMinutes,
    required this.distanceKm,
  });

  final ActiveDeliveryOrderEntity order;
  final int estimatedMinutes;
  final double distanceKm;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(color: color.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Spacing.radiusPill),
                child: Image.asset(
                  order.customerAvatar,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => CircleAvatar(
                    radius: 24,
                    backgroundColor: color.primaryContainer,
                    child: Icon(Icons.person, color: color.primary),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.customerName,
                      style: getBoldStyle(
                        fontSize: FontSize.size16,
                        color: color.onSurface,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: Spacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: color.primaryContainer,
                        borderRadius: BorderRadius.circular(Spacing.radiusSm),
                      ),
                      child: Text(
                        order.boxCode,
                        style: getSemiBoldStyle(
                          fontSize: FontSize.size12,
                          color: color.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.base),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: color.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_filled,
                        size: Spacing.iconSm,
                        color: color.primary,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Expanded(
                        child: Text(
                          locale.driverEstimatedEtaDistance(
                            estimatedMinutes,
                            distanceKm,
                          ),
                          style: getMediumStyle(
                            fontSize: FontSize.size12,
                            color: color.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: color.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2,
                      size: Spacing.iconSm,
                      color: color.primary,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      locale.driverMealsCountFormatted(order.mealsCount),
                      style: getMediumStyle(
                        fontSize: FontSize.size12,
                        color: color.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.base),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                size: Spacing.iconMd,
                color: color.primary,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.driverDeliveryAddressLabel,
                      style: getMediumStyle(
                        fontSize: FontSize.size12,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      order.address,
                      style: getSemiBoldStyle(
                        fontSize: FontSize.size14,
                        color: color.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (order.customerNote.isNotEmpty) ...[
            const SizedBox(height: Spacing.base),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(Spacing.md),
              decoration: BoxDecoration(
                color: color.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
                border: Border.all(color: color.outline),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: Spacing.iconSm,
                    color: color.primary,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          locale.driverCustomerNotesLabel,
                          style: getSemiBoldStyle(
                            fontSize: FontSize.size12,
                            color: color.primary,
                          ),
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          order.customerNote,
                          style: getRegularStyle(
                            fontSize: FontSize.size12,
                            color: color.onSurface,
                          ),
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
