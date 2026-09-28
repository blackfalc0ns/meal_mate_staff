import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/colors.dart';
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

  static const double _boxImageSize = 44;
  static const double _detailIconSize = 14;

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
          color: color.driverCardBorder,
          width: Spacing.hairline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(
                order.imageAsset.isNotEmpty
                    ? order.imageAsset
                    : AppAssets.driverBox3d,
                width: _boxImageSize,
                height: _boxImageSize,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
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
                        fontSize: FontSize.size16,
                        color: color.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              DriverCurrentOrderDetailsButton(onPressed: onDetailsTap),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Divider(
            color: color.driverCardBorder,
            height: Spacing.hairline,
            thickness: Spacing.hairline,
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                color: color.onSurfaceVariant,
                size: _detailIconSize,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                '${locale.driverClientLabel} : ',
                style: getRegularStyle(
                  fontSize: FontSize.size11,
                  color: color.onSurfaceVariant,
                ),
              ),
              Expanded(
                child: Text(
                  order.clientName,
                  style: getMediumStyle(
                    fontSize: FontSize.size11,
                    color: color.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
                color: color.onSurfaceVariant,
                size: _detailIconSize,
              ),
              const SizedBox(width: Spacing.xs),
              Text(
                '${locale.driverAddressLabel} : ',
                style: getRegularStyle(
                  fontSize: FontSize.size11,
                  color: color.onSurfaceVariant,
                ),
              ),
              Expanded(
                child: Text(
                  order.address,
                  style: getMediumStyle(
                    fontSize: FontSize.size11,
                    color: color.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      color: color.onSurfaceVariant,
                      size: _detailIconSize,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Expanded(
                      child: Text(
                        '${locale.driverMealsCountLabel}: ${order.mealsCount} ${locale.driverMealsUnit}',
                        style: getRegularStyle(
                          fontSize: FontSize.size11,
                          color: color.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      color: color.onSurfaceVariant,
                      size: _detailIconSize,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Expanded(
                      child: Text(
                        '${locale.driverDeliveryTimeLabel}: ${order.deliveryTime}',
                        style: getRegularStyle(
                          fontSize: FontSize.size11,
                          color: color.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
