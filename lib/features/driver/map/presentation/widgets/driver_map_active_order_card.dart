import 'package:flutter/material.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/extensions/extensions.dart';

import '../../../orders/domain/entities/driver_delivery_status.dart';
import '../../domain/entities/driver_map_stop_entity.dart';
import 'driver_map_order_stat_column.dart';

class DriverMapActiveOrderCard extends StatelessWidget {
  const DriverMapActiveOrderCard({
    super.key,
    required this.stop,
    this.onCallPressed,
    this.onAddressPressed,
  });

  final DriverMapStopEntity stop;
  final VoidCallback? onCallPressed;
  final VoidCallback? onAddressPressed;

  String _resolveStatusText(BuildContext context, DriverDeliveryStatus status) {
    final locale = context.localization;
    switch (status) {
      case DriverDeliveryStatus.delivered:
        return locale.driverSummaryDelivered;
      case DriverDeliveryStatus.inProgress:
        return locale.driverDetailsStatusOutForDelivery;
      default:
        return locale.driverStatusOnTheWayToCustomer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final statusText = _resolveStatusText(context, stop.status);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.screenH),
      padding: const EdgeInsets.all(Spacing.base),
      decoration: BoxDecoration(
        color: color.primary,
        borderRadius: BorderRadius.circular(Spacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.onPrimary.withValues(alpha: 0.20),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: Spacing.iconMd,
                  color: color.onPrimary,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      stop.boxCode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getBoldStyle(
                        fontSize: FontSize.size14,
                        color: color.onPrimary,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: color.onPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(Spacing.radiusPill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: color.secondaryContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: Spacing.xs),
                          Flexible(
                            child: Text(
                              statusText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: getMediumStyle(
                                fontSize: FontSize.size10,
                                color: color.onPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          locale.driverMapCustomerPrefix,
                          style: getRegularStyle(
                            fontSize: FontSize.size10,
                            color: color.onPrimary.withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(width: Spacing.xs),
                        Icon(
                          Icons.person_outline_rounded,
                          size: Spacing.iconXs,
                          color: color.onPrimary.withValues(alpha: 0.75),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stop.customerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getBoldStyle(
                        fontSize: FontSize.size13,
                        color: color.onPrimary,
                      ),
                    ),
                    Text(
                      stop.customerPhone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textDirection: TextDirection.ltr,
                      style: getRegularStyle(
                        fontSize: FontSize.size10,
                        color: color.onPrimary.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              InkWell(
                onTap: onCallPressed,
                borderRadius: BorderRadius.circular(Spacing.radiusPill),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.onPrimary.withValues(alpha: 0.22),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.phone_rounded,
                    size: Spacing.iconSm,
                    color: color.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.md),
            child: Divider(
              color: color.onPrimary.withValues(alpha: 0.15),
              height: 1,
              thickness: 1,
            ),
          ),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: DriverMapOrderStatColumn(
                    icon: Icons.restaurant_outlined,
                    label: locale.driverMealsCountLabel,
                    value: '${stop.mealsCount} ${locale.driverMealsUnit}',
                  ),
                ),
                VerticalDivider(
                  color: color.onPrimary.withValues(alpha: 0.15),
                  thickness: 1,
                  width: Spacing.md,
                ),
                Expanded(
                  flex: 3,
                  child: DriverMapOrderStatColumn(
                    icon: Icons.access_time_rounded,
                    label: locale.driverDeliveryTimeLabel,
                    value: stop.deliveryTimeSlot,
                  ),
                ),
                VerticalDivider(
                  color: color.onPrimary.withValues(alpha: 0.15),
                  thickness: 1,
                  width: Spacing.md,
                ),
                Expanded(
                  flex: 5,
                  child: DriverMapOrderStatColumn(
                    icon: Icons.location_on_outlined,
                    label: locale.driverAddressLabel,
                    value: stop.formattedAddress,
                    showArrow: true,
                    onTap: onAddressPressed,
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
