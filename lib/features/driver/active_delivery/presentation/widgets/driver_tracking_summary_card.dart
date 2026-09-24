import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/active_delivery_order_entity.dart';

class DriverTrackingSummaryCard extends StatelessWidget {
  const DriverTrackingSummaryCard({
    super.key,
    required this.order,
    this.estimatedDeliveryTime = '10:20 ص',
    this.onCallPressed,
    this.onNavigatePressed,
  });

  final ActiveDeliveryOrderEntity order;
  final String estimatedDeliveryTime;
  final VoidCallback? onCallPressed;
  final VoidCallback? onNavigatePressed;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        border: Border.all(color: color.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withValues(alpha: 0.04),
            blurRadius: 8,
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.primaryContainer,
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Icon(
                  Icons.person,
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
                      order.customerName,
                      style: getBoldStyle(
                        fontSize: FontSize.size13,
                        color: color.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.border),
                    Text(
                      order.orderId,
                      style: getRegularStyle(
                        fontSize: FontSize.size10,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: color.tertiaryContainer,
                  borderRadius: BorderRadius.circular(Spacing.radiusPill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_shipping,
                      size: Spacing.iconXs,
                      color: color.tertiary,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      locale.driverStatusEnRouteBadge,
                      style: getMediumStyle(
                        fontSize: FontSize.size10,
                        color: color.tertiary,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color.tertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              InkWell(
                onTap: onCallPressed,
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.primaryContainer,
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  ),
                  child: Icon(
                    Icons.call,
                    color: color.primary,
                    size: Spacing.iconSm,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Divider(
            height: Spacing.md,
            thickness: 1,
            color: color.outlineVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: Spacing.xs),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: Spacing.iconXs,
                          color: color.onSurfaceVariant,
                        ),
                        const SizedBox(width: Spacing.border),
                        Flexible(
                          child: Text(
                            locale.driverOrderNumberLabel,
                            style: getRegularStyle(
                              fontSize: FontSize.size10,
                              color: color.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      order.orderId,
                      style: getBoldStyle(
                        fontSize: FontSize.size11,
                        color: color.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                height: 28,
                width: 1,
                color: color.outlineVariant.withValues(alpha: 0.6),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: Spacing.iconXs,
                          color: color.onSurfaceVariant,
                        ),
                        const SizedBox(width: Spacing.border),
                        Flexible(
                          child: Text(
                            locale.driverStartRouteBoxesCountLabel,
                            style: getRegularStyle(
                              fontSize: FontSize.size10,
                              color: color.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      locale.driverMealsCountFormatted(order.mealsCount),
                      style: getBoldStyle(
                        fontSize: FontSize.size11,
                        color: color.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                height: 28,
                width: 1,
                color: color.outlineVariant.withValues(alpha: 0.6),
              ),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time,
                          size: Spacing.iconXs,
                          color: color.onSurfaceVariant,
                        ),
                        const SizedBox(width: Spacing.border),
                        Flexible(
                          child: Text(
                            locale.driverDeliveryTimeLabel,
                            style: getRegularStyle(
                              fontSize: FontSize.size10,
                              color: color.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      estimatedDeliveryTime,
                      style: getBoldStyle(
                        fontSize: FontSize.size11,
                        color: color.onSurface,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.xs),
              InkWell(
                onTap: onNavigatePressed,
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: color.primaryContainer,
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  ),
                  child: Icon(
                    Icons.near_me_rounded,
                    color: color.primary,
                    size: Spacing.iconSm,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
