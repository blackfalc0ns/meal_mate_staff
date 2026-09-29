import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';

class DriverSupportTicketOrderInfoCard extends StatelessWidget {
  const DriverSupportTicketOrderInfoCard({
    super.key,
    required this.orderNumber,
    required this.orderTime,
    required this.deliveryAddress,
  });

  final String orderNumber;
  final String orderTime;
  final String deliveryAddress;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return Container(
      padding: const EdgeInsets.all(Spacing.cardPadding),
      decoration: BoxDecoration(
        color: color.surface,
        borderRadius: BorderRadius.circular(Spacing.cardRadius),
        border: Border.all(
          color: color.outlineVariant.withValues(alpha: 0.5),
          width: Spacing.border,
        ),
        boxShadow: [
          BoxShadow(
            color: color.shadow.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: Spacing.iconMd + 2,
                height: Spacing.iconMd + 2,
                decoration: BoxDecoration(
                  color: color.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: Spacing.iconSm,
                  color: color.primary,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Text(
                locale.driverSupportTicketOrderInfoTitle,
                style: getBoldStyle(
                  fontSize: FontSize.size14,
                  color: color.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.md,
            ),
            decoration: BoxDecoration(
              color: color.surfaceContainerHighest.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.tag_rounded,
                              size: Spacing.iconSm - 2,
                              color: color.onSurfaceVariant,
                            ),
                            const SizedBox(width: Spacing.xs / 2),
                            Flexible(
                              child: Text(
                                locale.driverSupportTicketOrderNumberLabel,
                                style: getRegularStyle(
                                  fontSize: FontSize.size10,
                                  color: color.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          orderNumber,
                          style: getBoldStyle(
                            fontSize: FontSize.size12,
                            color: color.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  VerticalDivider(
                    color: color.outline.withValues(alpha: 0.3),
                    thickness: Spacing.hairline,
                    width: Spacing.sm,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: Spacing.iconSm - 2,
                              color: color.onSurfaceVariant,
                            ),
                            const SizedBox(width: Spacing.xs / 2),
                            Flexible(
                              child: Text(
                                locale.driverSupportTicketOrderTimeLabel,
                                style: getRegularStyle(
                                  fontSize: FontSize.size10,
                                  color: color.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          orderTime,
                          style: getMediumStyle(
                            fontSize: FontSize.size10,
                            color: color.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  VerticalDivider(
                    color: color.outline.withValues(alpha: 0.3),
                    thickness: Spacing.hairline,
                    width: Spacing.sm,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: Spacing.iconSm - 2,
                              color: color.onSurfaceVariant,
                            ),
                            const SizedBox(width: Spacing.xs / 2),
                            Flexible(
                              child: Text(
                                locale.driverSupportTicketDeliveryAddressLabel,
                                style: getRegularStyle(
                                  fontSize: FontSize.size10,
                                  color: color.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          deliveryAddress,
                          style: getSemiBoldStyle(
                            fontSize: FontSize.size11,
                            color: color.onSurface,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
