import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/constants/assets.dart';
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

  void _handleCall(BuildContext context) {
    if (onCallCustomer != null) {
      onCallCustomer!();
      return;
    }
    unawaited(context.pushNamed(AppRoutes.driverActiveCall));
  }

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                ),
                child: Icon(
                  Icons.person_rounded,
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
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _handleCall(context),
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.primaryContainer.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(Spacing.radiusMd),
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(
                      AppAssets.driverActionCall,
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        color.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
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
                color: color.outlineVariant.withValues(alpha: 0.5),
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
                color: color.outlineVariant.withValues(alpha: 0.5),
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
          const SizedBox(height: Spacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm + 2,
            ),
            decoration: BoxDecoration(
              color: color.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: color.primary,
                    borderRadius: BorderRadius.circular(Spacing.radiusXs),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.subject_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locale.driverStartRouteCustomerNotesTitle,
                        style: getSemiBoldStyle(
                          fontSize: FontSize.size11,
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
