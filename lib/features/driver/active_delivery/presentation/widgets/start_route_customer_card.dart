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
    this.estimatedMinutes = 15,
    this.distanceKm = 4.2,
    this.onCallCustomer,
  });

  final ActiveDeliveryOrderEntity order;
  final int estimatedMinutes;
  final double distanceKm;
  final VoidCallback? onCallCustomer;

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.primaryContainer,
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
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
                      locale.driverStartRouteCustomerLabel,
                      style: getRegularStyle(
                        fontSize: FontSize.size10,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Spacing.border),
                    Text(
                      order.customerName,
                      style: getBoldStyle(
                        fontSize: FontSize.size14,
                        color: color.onSurface,
                      ),
                    ),
                    const SizedBox(height: Spacing.border),
                    Text(
                      order.address,
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
              const SizedBox(width: Spacing.sm),
              InkWell(
                onTap: onCallCustomer,
                borderRadius: BorderRadius.circular(Spacing.radiusMd),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.primaryContainer,
                    borderRadius: BorderRadius.circular(Spacing.radiusMd),
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
                      order.orderId,
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
                color: color.outlineVariant.withValues(alpha: 0.6),
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
                      locale.driverStartRouteBoxesCountValue(order.mealsCount),
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
                color: color.outlineVariant.withValues(alpha: 0.6),
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
                      locale.driverStartRouteExpectedDeliveryWindow,
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
          const SizedBox(height: Spacing.xs),
          Divider(
            height: Spacing.md,
            thickness: 1,
            color: color.outlineVariant.withValues(alpha: 0.6),
          ),
          const SizedBox(height: Spacing.xs),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            decoration: BoxDecoration(
              color: color.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.description_outlined,
                  size: Spacing.iconSm,
                  color: color.primary,
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale.driverStartRouteCustomerNotesTitle,
                        style: getSemiBoldStyle(
                          fontSize: FontSize.size10,
                          color: color.onSurface,
                        ),
                      ),
                      const SizedBox(height: Spacing.border),
                      Text(
                        order.customerNote.isNotEmpty
                            ? order.customerNote
                            : locale.driverCustomerNotesLabel,
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
      ),
    );
  }
}
