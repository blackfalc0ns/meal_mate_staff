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

    final langCode = Localizations.localeOf(context).languageCode;
    final effectiveTicket = ticket ?? profile?.latestSupportTicket;
    final formattedDate = effectiveTicket?.createdAtUtc != null
        ? _formatTicketDate(effectiveTicket!.createdAtUtc!, langCode)
        : null;

    final isResolved = effectiveTicket != null &&
        (effectiveTicket.status.toLowerCase() == 'resolved' ||
            effectiveTicket.statusText == locale.driverTicketStatusResolved);
    final statusSubtitle = isResolved ? locale.driverTicketResolvedSubtitle : null;

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
                          color: color.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(Spacing.radiusSm),
                        ),
                        child: Icon(
                          Icons.confirmation_number_outlined,
                          size: 19,
                          color: color.primary,
                        ),
                      ),
                      const SizedBox(width: Spacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              effectiveTicket.ticketNumber.isNotEmpty
                                  ? (effectiveTicket.ticketNumber.startsWith('#')
                                      ? effectiveTicket.ticketNumber
                                      : '#${effectiveTicket.ticketNumber}')
                                  : (effectiveTicket.ticketId.startsWith('#')
                                      ? effectiveTicket.ticketId
                                      : '#${effectiveTicket.ticketId}'),
                              style: getBoldStyle(
                                fontSize: FontSize.size12,
                                color: color.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              effectiveTicket.subject,
                              style: getRegularStyle(
                                fontSize: FontSize.size10,
                                color: color.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: Spacing.xs),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
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
                                  fontSize: FontSize.size11,
                                  color: color.tertiary,
                                ),
                              ),
                            ],
                          ),
                          if (statusSubtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              statusSubtitle,
                              style: getRegularStyle(
                                fontSize: FontSize.size9,
                                color: color.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(width: Spacing.sm),
                      if (formattedDate != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formattedDate,
                              style: getBoldStyle(
                                fontSize: FontSize.size10,
                                color: color.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              locale.driverTicketDateLabel,
                              style: getRegularStyle(
                                fontSize: FontSize.size9,
                                color: color.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(width: Spacing.xs),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: color.onSurfaceVariant,
                      ),
                    ],
                  ),
                  if (effectiveTicket.body.isNotEmpty &&
                      effectiveTicket.body != effectiveTicket.subject) ...[
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

  String _formatTicketDate(DateTime date, String langCode) {
    const monthsAr = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    const monthsEn = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final monthName = langCode == 'ar'
        ? monthsAr[date.month - 1]
        : monthsEn[date.month - 1];
    return '${date.day} $monthName ${date.year}';
  }
}
