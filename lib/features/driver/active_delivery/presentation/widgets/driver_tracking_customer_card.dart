import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/active_delivery_order_entity.dart';

class DriverTrackingCustomerCard extends StatelessWidget {
  const DriverTrackingCustomerCard({
    super.key,
    required this.order,
    this.onCallPressed,
    this.onMessagePressed,
  });

  final ActiveDeliveryOrderEntity order;
  final VoidCallback? onCallPressed;
  final VoidCallback? onMessagePressed;

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
                  width: 44,
                  height: 44,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => CircleAvatar(
                    radius: 22,
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
                        fontSize: FontSize.size15,
                        color: color.onSurface,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      order.boxCode,
                      style: getMediumStyle(
                        fontSize: FontSize.size12,
                        color: color.primary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onCallPressed != null)
                IconButton(
                  icon: const Icon(Icons.phone),
                  color: color.tertiary,
                  iconSize: Spacing.iconMd,
                  onPressed: onCallPressed,
                  tooltip: locale.driverCallCustomer,
                ),
              if (onMessagePressed != null)
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: color.primary,
                  iconSize: Spacing.iconMd,
                  onPressed: onMessagePressed,
                  tooltip: locale.driverMessageCustomer,
                ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          const Divider(height: Spacing.md),
          const SizedBox(height: Spacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.location_on,
                size: Spacing.iconSm + 2,
                color: color.primary,
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(
                  order.address,
                  style: getRegularStyle(
                    fontSize: FontSize.size13,
                    color: color.onSurface,
                  ),
                ),
              ),
            ],
          ),
          if (order.customerNote.isNotEmpty) ...[
            const SizedBox(height: Spacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.sm,
                vertical: Spacing.xs,
              ),
              decoration: BoxDecoration(
                color: color.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(Spacing.radiusSm),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: Spacing.iconXs + 2,
                    color: color.onSurfaceVariant,
                  ),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      order.customerNote,
                      style: getRegularStyle(
                        fontSize: FontSize.size11,
                        color: color.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
