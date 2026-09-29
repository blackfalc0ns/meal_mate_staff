import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_support_ticket_status.dart';
import 'driver_support_tickets_kpi_card.dart';

class DriverSupportTicketsKpiRow extends StatelessWidget {
  const DriverSupportTicketsKpiRow({
    super.key,
    required this.selectedFilter,
    required this.allCount,
    required this.underReviewCount,
    required this.awaitingResponseCount,
    required this.resolvedCount,
    required this.onFilterChanged,
  });

  final DriverSupportTicketFilter selectedFilter;
  final int allCount;
  final int underReviewCount;
  final int awaitingResponseCount;
  final int resolvedCount;
  final ValueChanged<DriverSupportTicketFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final locale = context.localization;

    return Row(
      children: [
        Expanded(
          child: DriverSupportTicketsKpiCard(
            filter: DriverSupportTicketFilter.all,
            label: locale.driverSupportTicketsFilterAll,
            count: allCount,
            icon: Icons.receipt_long_rounded,
            isSelected: selectedFilter == DriverSupportTicketFilter.all,
            onTap: () => onFilterChanged(DriverSupportTicketFilter.all),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: DriverSupportTicketsKpiCard(
            filter: DriverSupportTicketFilter.underReview,
            label: locale.driverSupportTicketsStatusUnderReview,
            count: underReviewCount,
            icon: Icons.hourglass_empty_rounded,
            isSelected: selectedFilter == DriverSupportTicketFilter.underReview,
            onTap: () => onFilterChanged(DriverSupportTicketFilter.underReview),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: DriverSupportTicketsKpiCard(
            filter: DriverSupportTicketFilter.awaitingResponse,
            label: locale.driverSupportTicketsStatusAwaitingResponse,
            count: awaitingResponseCount,
            icon: Icons.access_time_rounded,
            isSelected: selectedFilter == DriverSupportTicketFilter.awaitingResponse,
            onTap: () => onFilterChanged(DriverSupportTicketFilter.awaitingResponse),
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: DriverSupportTicketsKpiCard(
            filter: DriverSupportTicketFilter.resolved,
            label: locale.driverSupportTicketsStatusResolved,
            count: resolvedCount,
            icon: Icons.check_circle_outline_rounded,
            isSelected: selectedFilter == DriverSupportTicketFilter.resolved,
            onTap: () => onFilterChanged(DriverSupportTicketFilter.resolved),
          ),
        ),
      ],
    );
  }
}
