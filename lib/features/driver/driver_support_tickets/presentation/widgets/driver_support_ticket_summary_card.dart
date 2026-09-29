import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_support_ticket_entity.dart';
import 'driver_support_ticket_status_badge.dart';

class DriverSupportTicketSummaryCard extends StatelessWidget {
  const DriverSupportTicketSummaryCard({super.key, required this.ticket});

  final DriverSupportTicketEntity ticket;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final boxIconPath = ticket.boxIcon;
    final createdAtText = ticket.createdAt ?? ticket.updatedAt;

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
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 7,
              child: Row(
                children: [
                  if (boxIconPath != null)
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color.errorContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(Spacing.radiusMd),
                      ),
                      alignment: Alignment.center,
                      child: Image.asset(
                        boxIconPath,
                        width: Spacing.iconLg,
                        height: Spacing.iconLg,
                        fit: BoxFit.contain,
                      ),
                    ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DriverSupportTicketStatusBadge(status: ticket.status),
                        const SizedBox(height: Spacing.xs),
                        Text(
                          ticket.boxNumber,
                          style: getBoldStyle(
                            fontSize: FontSize.size15,
                            color: color.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: Spacing.xs / 2),
                        Text(
                          ticket.title,
                          style: getMediumStyle(
                            fontSize: FontSize.size11,
                            color: color.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            VerticalDivider(
              color: color.outline.withValues(alpha: 0.4),
              width: Spacing.lg,
              thickness: Spacing.hairline,
            ),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: Spacing.iconSm,
                        color: color.onSurfaceVariant,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Expanded(
                        child: Text(
                          ticket.location,
                          style: getSemiBoldStyle(
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
                      Icon(
                        Icons.access_time_rounded,
                        size: Spacing.iconSm,
                        color: color.onSurfaceVariant,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(
                        locale.driverSupportTicketCreatedAt,
                        style: getRegularStyle(
                          fontSize: FontSize.size10,
                          color: color.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xs / 2),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: Spacing.lg),
                    child: Text(
                      createdAtText,
                      style: getRegularStyle(
                        fontSize: FontSize.size9,
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
      ),
    );
  }
}
