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
        padding: const EdgeInsets.all(Spacing.md),
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_rounded,
                      size: Spacing.iconSm + 4,
                      color: color.primary,
                    ),
                    const SizedBox(width: Spacing.xs),
                    Text(
                      ticket.boxNumber,
                      style: getBoldStyle(
                        fontSize: FontSize.size13,
                        color: color.primary,
                      ),
                    ),
                  ],
                ),
                DriverSupportTicketStatusBadge(status: ticket.status),
              ],
            ),
            const SizedBox(height: Spacing.xs + 2),
            Text(
              ticket.title,
              style: getBoldStyle(
                fontSize: FontSize.size13,
                color: color.onSurface,
              ),
            ),
            const SizedBox(height: Spacing.xs / 2),
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  size: Spacing.iconXs,
                  color: color.onSurfaceVariant,
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  ticket.location,
                  style: getRegularStyle(
                    fontSize: FontSize.size11,
                    color: color.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.xs + 2),
            Divider(
              color: color.outlineVariant.withValues(alpha: 0.5),
              height: 1,
              thickness: Spacing.hairline,
            ),
            const SizedBox(height: Spacing.xs + 2),
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: Spacing.iconXs,
                        color: color.onSurfaceVariant,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Expanded(
                        child: Text(
                          ticket.updatedAt,
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
                ),
                const SizedBox(width: Spacing.sm),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      locale.driverSupportTicketsViewDetails,
                      style: getSemiBoldStyle(
                        fontSize: FontSize.size11,
                        color: color.primary,
                      ),
                    ),
                    const SizedBox(width: Spacing.xs),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: Spacing.iconXs - 2,
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
