import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/active_delivery_order_entity.dart';

class DriverTrackingAddressCard extends StatelessWidget {
  const DriverTrackingAddressCard({super.key, required this.order});

  final ActiveDeliveryOrderEntity order;

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.driverCustomerAddressLabel,
                      style: getRegularStyle(
                        fontSize: FontSize.size10,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Spacing.border),
                    Text(
                      order.address,
                      style: getBoldStyle(
                        fontSize: FontSize.size12,
                        color: color.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: color.primary,
                  size: Spacing.iconSm,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      locale.driverStartRouteCustomerNotesTitle,
                      style: getRegularStyle(
                        fontSize: FontSize.size10,
                        color: color.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Spacing.border),
                    Text(
                      order.customerNote.isNotEmpty
                          ? order.customerNote
                          : locale.driverCustomerNotesLabel,
                      style: getRegularStyle(
                        fontSize: FontSize.size11,
                        color: color.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.secondaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.description_rounded,
                  color: color.secondary,
                  size: Spacing.iconSm,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
