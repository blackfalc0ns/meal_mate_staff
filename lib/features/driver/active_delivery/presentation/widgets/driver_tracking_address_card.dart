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
                        fontSize: FontSize.size13,
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
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.primaryContainer,
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: color.primary,
                  size: Spacing.iconMd - 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
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
                      style: getMediumStyle(
                        fontSize: FontSize.size12,
                        color: color.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm + 2),

              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                ),
                child: const Icon(
                  Icons.article_rounded,
                  color: Color(0xFFF57C00),
                  size: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
