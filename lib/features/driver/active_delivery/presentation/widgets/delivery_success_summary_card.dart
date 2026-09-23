import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/active_delivery_order_entity.dart';

class DeliverySuccessSummaryCard extends StatelessWidget {
  const DeliverySuccessSummaryCard({
    super.key,
    required this.order,
    this.deliveredTimeText = '02:30 م',
  });

  final ActiveDeliveryOrderEntity order;
  final String deliveredTimeText;

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
              Flexible(
                child: Text(
                  locale.driverOrderSummaryTitle,
                  style: getBoldStyle(
                    fontSize: FontSize.size16,
                    color: color.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.xs,
                ),
                decoration: BoxDecoration(
                  color: color.tertiaryContainer,
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Text(
                  order.boxCode,
                  style: getSemiBoldStyle(
                    fontSize: FontSize.size12,
                    color: color.tertiary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          const Divider(height: Spacing.md),
          const SizedBox(height: Spacing.xs),
          _buildSummaryRow(
            label: locale.driverCustomerNameLabel,
            value: order.customerName,
            color: color,
          ),
          const SizedBox(height: Spacing.sm),
          _buildSummaryRow(
            label: locale.driverDeliveredAtLabel,
            value: deliveredTimeText,
            color: color,
          ),
          const SizedBox(height: Spacing.sm),
          _buildSummaryRow(
            label: locale.driverPaymentMethodLabel,
            value: order.paymentMethod,
            color: color,
          ),
          const SizedBox(height: Spacing.sm),
          _buildSummaryRow(
            label: locale.driverDeliveryAddressLabel,
            value: order.address,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    required ColorScheme color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getMediumStyle(
            fontSize: FontSize.size12,
            color: color.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: Spacing.base),
        Expanded(
          child: Text(
            value,
            style: getSemiBoldStyle(
              fontSize: FontSize.size13,
              color: color.onSurface,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
