import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/active_delivery_order_entity.dart';

class DeliveryDelayInfoCard extends StatelessWidget {
  const DeliveryDelayInfoCard({
    super.key,
    required this.order,
    this.delayMinutes = 12,
  });

  final ActiveDeliveryOrderEntity order;
  final int delayMinutes;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order.boxCode,
                style: getBoldStyle(
                  fontSize: FontSize.size16,
                  color: color.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: color.secondaryContainer,
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Text(
                  '+$delayMinutes min',
                  style: getSemiBoldStyle(
                    fontSize: FontSize.size12,
                    color: color.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          const Divider(height: Spacing.md),
          const SizedBox(height: Spacing.xs),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: Spacing.iconSm,
                color: color.onSurfaceVariant,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                locale.driverCustomerNameLabel,
                style: getMediumStyle(
                  fontSize: FontSize.size12,
                  color: color.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  order.customerName,
                  style: getSemiBoldStyle(
                    fontSize: FontSize.size13,
                    color: color.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on_outlined,
                size: Spacing.iconSm,
                color: color.onSurfaceVariant,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                locale.driverDeliveryAddressLabel,
                style: getMediumStyle(
                  fontSize: FontSize.size12,
                  color: color.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  order.address,
                  style: getRegularStyle(
                    fontSize: FontSize.size12,
                    color: color.onSurface,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
