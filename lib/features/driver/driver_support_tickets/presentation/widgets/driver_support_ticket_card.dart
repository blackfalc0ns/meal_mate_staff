import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_support_ticket_entity.dart';
import 'driver_support_ticket_status_badge.dart';

class DriverSupportTicketCard extends StatelessWidget {
  const DriverSupportTicketCard({super.key, required this.ticket, this.onTap});

  final DriverSupportTicketEntity ticket;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(Spacing.cardRadius),
      child: Ink(
        padding: const EdgeInsets.all(Spacing.cardPadding),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          borderRadius: BorderRadius.circular(Spacing.cardRadius),
          border: Border.all(
            color: const Color(0xFFE8E5EF),
            width: Spacing.border,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_rounded,
                      size: Spacing.iconMd,
                      color: color.primary,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      ticket.boxNumber,
                      style: getBoldStyle(
                        fontSize: FontSize.size14,
                        color: color.primary,
                      ),
                    ),
                  ],
                ),
                DriverSupportTicketStatusBadge(status: ticket.status),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              ticket.title,
              style: getBoldStyle(
                fontSize: FontSize.size14,
                color: color.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.xs),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: Spacing.iconSm,
                  color: color.onSurfaceVariant,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  ticket.location,
                  style: getRegularStyle(
                    fontSize: FontSize.size12,
                    color: color.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Divider(
              color: color.outlineVariant,
              height: Spacing.sm,
              thickness: Spacing.hairline,
            ),
            const SizedBox(height: Spacing.xs),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: Spacing.iconSm,
                        color: color.onSurfaceVariant,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Expanded(
                        child: Text(
                          ticket.updatedAt,
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      locale.driverSupportTicketsViewDetails,
                      style: getSemiBoldStyle(
                        fontSize: FontSize.size12,
                        color: color.primary,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: Spacing.iconXs,
                      color: color.primary,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
