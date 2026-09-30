import 'package:flutter/material.dart';

import '../../../../../config/theme/font_manager.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../config/theme/styles_manager.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_profile_entity.dart';
import '../../domain/entities/driver_profile_ticket_entity.dart';

class DriverProfileTicketCard extends StatelessWidget {
  const DriverProfileTicketCard({
    super.key,
    this.ticket,
    this.profile,
    this.onTap,
    this.onViewAllTap,
  });

  final DriverProfileTicketEntity? ticket;
  final DriverProfileEntity? profile;
  final VoidCallback? onTap;
  final VoidCallback? onViewAllTap;

  static const double _iconBoxSize = 36.0;
  static const double _statusDotSize = 6.0;

  @override
  Widget build(BuildContext context) {
    final color = context.colorScheme;
    final locale = context.localization;

    final effectiveTicket = ticket ?? profile?.latestSupportTicket;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                locale.driverRecentTicketTitle,
                style: getBoldStyle(
                  fontSize: FontSize.size13,
                  color: color.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            InkWell(
              onTap: onViewAllTap,
              borderRadius: BorderRadius.circular(Spacing.radiusPill),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: color.primaryContainer,
                  borderRadius: BorderRadius.circular(Spacing.radiusPill),
                ),
                child: Text(
                  locale.driverViewAll,
                  style: getMediumStyle(
                    fontSize: FontSize.size11,
                    color: color.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.xs + 2),
        if (effectiveTicket == null)
          Container(
            key: const Key('driver_profile_ticket_empty'),
            decoration: BoxDecoration(
              color: color.surface,
              borderRadius: BorderRadius.circular(Spacing.cardRadius),
              border: Border.all(
                color: color.outlineVariant,
                width: Spacing.border,
              ),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.md,
            ),
            child: Center(
              child: Text(
                locale.driverTicketEmpty,
                style: getRegularStyle(
                  fontSize: FontSize.size12,
                  color: color.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(Spacing.cardRadius),
            child: Container(
              decoration: BoxDecoration(
                color: color.surface,
                borderRadius: BorderRadius.circular(Spacing.cardRadius),
                border: Border.all(
                  color: color.outlineVariant,
                  width: Spacing.border,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.base,
                vertical: Spacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: _iconBoxSize,
                        height: _iconBoxSize,
                        decoration: BoxDecoration(
                          color: color.primary,
                          borderRadius: BorderRadius.circular(Spacing.radiusSm),
                        ),
                        child: Icon(
                          Icons.headset_mic_outlined,
                          size: 18,
                          color: color.onPrimary,
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              effectiveTicket.ticketNumber.isNotEmpty
                                  ? effectiveTicket.ticketNumber
                                  : effectiveTicket.ticketId,
                              style: getBoldStyle(
                                fontSize: FontSize.size11,
                                color: color.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              effectiveTicket.subject,
                              style: getRegularStyle(
                                fontSize: FontSize.size11,
                                color: color.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.sm,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: color.tertiaryContainer,
                              borderRadius:
                                  BorderRadius.circular(Spacing.radiusPill),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: _statusDotSize,
                                  height: _statusDotSize,
                                  decoration: BoxDecoration(
                                    color: color.tertiary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: Spacing.xs),
                                Text(
                                  effectiveTicket.statusText,
                                  style: getMediumStyle(
                                    fontSize: FontSize.size10,
                                    color: color.tertiary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (effectiveTicket.createdAtUtc != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${effectiveTicket.createdAtUtc!.year}-${effectiveTicket.createdAtUtc!.month.toString().padLeft(2, '0')}-${effectiveTicket.createdAtUtc!.day.toString().padLeft(2, '0')}',
                              style: getRegularStyle(
                                fontSize: FontSize.size9,
                                color: color.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(width: Spacing.xs),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: color.onSurfaceVariant,
                      ),
                    ],
                  ),
                  if (effectiveTicket.body.isNotEmpty) ...[
                    const SizedBox(height: Spacing.xs),
                    Text(
                      effectiveTicket.body,
                      style: getRegularStyle(
                        fontSize: FontSize.size10,
                        color: color.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (effectiveTicket.priorityText != null ||
                      effectiveTicket.priority != null) ...[
                    const SizedBox(height: Spacing.xs),
                    Row(
                      children: [
                        Text(
                          '${locale.driverTicketPriority}: ',
                          style: getRegularStyle(
                            fontSize: FontSize.size10,
                            color: color.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          effectiveTicket.priorityText ??
                              effectiveTicket.priority!,
                          style: getMediumStyle(
                            fontSize: FontSize.size10,
                            color: color.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}
