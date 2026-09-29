import 'package:flutter/material.dart';

import '../../../../../config/theme/spacing.dart';
import '../../domain/entities/driver_support_ticket_entity.dart';
import 'driver_support_ticket_card.dart';
import 'driver_support_tickets_empty_state.dart';

class DriverSupportTicketsList extends StatelessWidget {
  const DriverSupportTicketsList({
    super.key,
    required this.tickets,
    this.onTicketTap,
    this.shrinkWrap = false,
    this.physics,
  }) : asSliver = false;

  const DriverSupportTicketsList.sliver({
    super.key,
    required this.tickets,
    this.onTicketTap,
  })  : shrinkWrap = false,
        physics = null,
        asSliver = true;

  final List<DriverSupportTicketEntity> tickets;
  final ValueChanged<DriverSupportTicketEntity>? onTicketTap;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final bool asSliver;

  @override
  Widget build(BuildContext context) {
    if (asSliver) {
      if (tickets.isEmpty) {
        return const SliverToBoxAdapter(
          child: DriverSupportTicketsEmptyState(),
        );
      }

      return SliverList.separated(
        itemCount: tickets.length,
        separatorBuilder: (_, _) => const SizedBox(height: Spacing.md),
        itemBuilder: (context, index) {
          final ticket = tickets[index];
          return DriverSupportTicketCard(
            ticket: ticket,
            onTap: () => onTicketTap?.call(ticket),
          );
        },
      );
    }

    if (tickets.isEmpty) {
      return const DriverSupportTicketsEmptyState();
    }

    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: const EdgeInsets.only(top: Spacing.xs, bottom: Spacing.md),
      itemCount: tickets.length,
      separatorBuilder: (_, _) => const SizedBox(height: Spacing.md),
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return DriverSupportTicketCard(
          ticket: ticket,
          onTap: () => onTicketTap?.call(ticket),
        );
      },
    );
  }
}
