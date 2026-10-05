import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';
import 'package:meal_mate_delivery/features/driver/home/domain/entities/driver_current_order_entity.dart';

import 'driver_current_order_details_button.dart';

class DriverCurrentOrderCard extends StatelessWidget {
  const DriverCurrentOrderCard({
    super.key,
    required this.order,
    this.onDetailsTap,
  });

  final DriverCurrentOrderEntity order;
  final VoidCallback? onDetailsTap;

  static const double _detailIconSize = 18;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(Spacing.cardPadding),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
          width: Spacing.hairline,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    locale.driverCurrentOrderLabel,
                    style: getRegularStyle(
                      fontSize: FontSize.size11,
                      color: color.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.orderCode,
                    style: getBoldStyle(
                      fontSize: FontSize.size22,
                      color: color.primary,
                    ),
                  ),
                ],
              ),
              Image.asset(
                order.imageAsset.isNotEmpty
                    ? order.imageAsset
                    : AppAssets.driverOrderBox3d,
                width: 88,
                height: 74,
                fit: BoxFit.contain,
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          _buildDetailRow(
            icon: Icons.person_rounded,
            label: locale.driverClientLabel.replaceAll(':', '').trim(),
            value: order.clientName,
            color: color,
          ),
          const SizedBox(height: Spacing.sm),
          _buildDetailRow(
            icon: Icons.location_on_rounded,
            label: locale.driverAddressLabel.replaceAll(':', '').trim(),
            value: order.address,
            color: color,
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: _buildDetailRow(
                  icon: Icons.restaurant_rounded,
                  label: locale.driverMealsCountLabel
                      .replaceAll(':', '')
                      .trim(),
                  value: '${order.mealsCount} ${locale.driverMealsUnit}',
                  color: color,
                  isExpanded: false,
                ),
              ),
              DriverCurrentOrderDetailsButton(onPressed: onDetailsTap),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          _buildDetailRow(
            icon: Icons.calendar_month_rounded,
            label: locale.driverDeliveryTimeLabel.replaceAll(':', '').trim(),
            value: order.deliveryTime,
            color: color,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme color,
    bool isExpanded = true,
  }) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: getRegularStyle(
            fontSize: FontSize.size10,
            color: color.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 1),
        Text(
          value,
          style: getBoldStyle(
            fontSize: FontSize.size12,
            color: color.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    return Row(
      mainAxisSize: isExpanded ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFF3E8FF),
            borderRadius: BorderRadius.circular(Spacing.radiusSm),
          ),
          child: Icon(icon, color: color.primary, size: _detailIconSize),
        ),
        const SizedBox(width: Spacing.xs),
        if (isExpanded) Expanded(child: content) else Flexible(child: content),
      ],
    );
  }
}
