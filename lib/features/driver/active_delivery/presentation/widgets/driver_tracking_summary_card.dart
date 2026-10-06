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
    @Deprecated('Customer calling is disabled by operations decision')
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
                width: 40,
                height: 40,
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
                      order.customerName,
                      style: getBoldStyle(
                        fontSize: FontSize.size14,
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
                  horizontal: Spacing.sm + 2,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8F0),
                  borderRadius: BorderRadius.circular(Spacing.radiusPill),
                  border: Border.all(
                    color: const Color(0xFF28A745).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_shipping_rounded,
                      size: Spacing.iconXs,
                      color: Color(0xFF28A745),
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      locale.driverStatusEnRouteBadge,
                      style: getMediumStyle(
                        fontSize: FontSize.size11,
                        color: const Color(0xFF28A745),
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF28A745),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.xs + 2),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onCallPressed,
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: color.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(Spacing.radiusMd),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.phone_rounded,
                      color: color.primary,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Divider(
            height: Spacing.md,
            thickness: 1,
            color: color.outlineVariant.withValues(alpha: 0.5),
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
