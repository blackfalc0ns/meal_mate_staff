import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:meal_mate_delivery/config/theme/font_manager.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
import 'package:meal_mate_delivery/config/theme/styles_manager.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
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

  Color _resolveStatusColor(BuildContext context, DriverDeliveryStatus status) {
    final color = context.colorScheme;
    switch (status) {
      case DriverDeliveryStatus.delivered:
        return color.onSurfaceVariant;
      case DriverDeliveryStatus.inProgress:
        return color.tertiary;
      default:
        return color.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final statusText = _resolveStatusText(context, stop.status);
    final statusColor = _resolveStatusColor(context, stop.status);

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
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_outline_rounded,
                          size: Spacing.iconXs,
                          color: color.onPrimary.withValues(alpha: 0.75),
                        ),
                        const SizedBox(width: Spacing.xs),
                        Text(
                          locale.driverMapCustomerPrefix,
                          style: getRegularStyle(
                            fontSize: FontSize.size10,
                            color: color.onPrimary.withValues(alpha: 0.75),
                          ),
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
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                        color: statusColor.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(Spacing.radiusPill),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: statusColor,
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
              const SizedBox(width: Spacing.sm),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.onPrimary.withValues(alpha: 0.20),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: SvgPicture.asset(
                    AppAssets.driverKpiBox,
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(
                      color.onPrimary,
                      BlendMode.srcIn,
                    ),
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
          Row(
            children: [
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
              const SizedBox(width: Spacing.xs),
              Expanded(
                flex: 3,
                child: DriverMapOrderStatColumn(
                  icon: Icons.calendar_today_outlined,
                  label: locale.driverDeliveryTimeLabel,
                  value: stop.deliveryTimeSlot,
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                flex: 3,
                child: DriverMapOrderStatColumn(
                  icon: Icons.restaurant_outlined,
                  label: locale.driverMealsCountLabel,
                  value: '${stop.mealsCount} ${locale.driverMealsUnit}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
