import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../domain/entities/driver_support_ticket_entity.dart';
import '../../domain/entities/driver_support_ticket_status.dart';
import '../../domain/fake_data/driver_support_tickets_fake_data.dart';
import '../widgets/driver_support_tickets_header.dart';
import '../widgets/driver_support_tickets_kpi_row.dart';
import '../widgets/driver_support_tickets_list.dart';
import '../widgets/driver_support_tickets_report_button.dart';
import '../widgets/driver_support_tickets_search_field.dart';

class DriverSupportTicketsScreen extends StatefulWidget {
  const DriverSupportTicketsScreen({
    super.key,
    this.initialTickets,
    this.onTicketTap,
    this.onReportTap,
  });

  final List<DriverSupportTicketEntity>? initialTickets;
  final ValueChanged<DriverSupportTicketEntity>? onTicketTap;
  final VoidCallback? onReportTap;

  @override
  State<DriverSupportTicketsScreen> createState() =>
      _DriverSupportTicketsScreenState();
}

class _DriverSupportTicketsScreenState
    extends State<DriverSupportTicketsScreen> {
  late final List<DriverSupportTicketEntity> _allTickets;
  late final TextEditingController _searchController;
  DriverSupportTicketFilter _selectedFilter = DriverSupportTicketFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _allTickets = widget.initialTickets ?? DriverSupportTicketsFakeData.tickets;
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterChanged(DriverSupportTicketFilter filter) {
    if (_selectedFilter != filter) {
      setState(() {
        _selectedFilter = filter;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.trim().toLowerCase();
    });
  }

  List<DriverSupportTicketEntity> _getFilteredTickets() {
    return _allTickets.where((ticket) {
      // 1. Status Filter
      if (_selectedFilter != DriverSupportTicketFilter.all) {
        final matchesStatus = switch (_selectedFilter) {
          DriverSupportTicketFilter.underReview =>
            ticket.status == DriverSupportTicketStatus.underReview,
          DriverSupportTicketFilter.awaitingResponse =>
            ticket.status == DriverSupportTicketStatus.awaitingResponse,
          DriverSupportTicketFilter.resolved =>
            ticket.status == DriverSupportTicketStatus.resolved,
          DriverSupportTicketFilter.all => true,
        };
        if (!matchesStatus) return false;
      }

      // 2. Query Search Filter
      if (_searchQuery.isNotEmpty) {
        final boxMatches = ticket.boxNumber.toLowerCase().contains(
          _searchQuery,
        );
        final titleMatches = ticket.title.toLowerCase().contains(_searchQuery);
        final locationMatches = ticket.location.toLowerCase().contains(
          _searchQuery,
        );
        if (!boxMatches && !titleMatches && !locationMatches) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTickets = _getFilteredTickets();

    return Scaffold(
      appBar: const DriverSupportTicketsHeader(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.screenH,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: Spacing.screenV),
                  DriverSupportTicketsSearchField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                  ),
                  const SizedBox(height: Spacing.md),
                  DriverSupportTicketsKpiRow(
                    selectedFilter: _selectedFilter,
                    allCount: _allTickets.length,
                    underReviewCount: _allTickets
                        .where(
                          (t) =>
                              t.status == DriverSupportTicketStatus.underReview,
                        )
                        .length,
                    awaitingResponseCount: _allTickets
                        .where(
                          (t) =>
                              t.status ==
                              DriverSupportTicketStatus.awaitingResponse,
                        )
                        .length,
                    resolvedCount: _allTickets
                        .where(
                          (t) => t.status == DriverSupportTicketStatus.resolved,
                        )
                        .length,
                    onFilterChanged: _onFilterChanged,
                  ),
                  const SizedBox(height: Spacing.md),
                ],
              ),
            ),
            Expanded(
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.screenH,
                    ),
                    sliver: DriverSupportTicketsList.sliver(
                      tickets: filteredTickets,
                      onTicketTap: widget.onTicketTap ??
                          (ticket) {
                            unawaited(
                              Navigator.of(context).pushNamed(
                                AppRoutes.driverSupportTicketDetails,
                                arguments: ticket,
                              ),
                            );
                          },
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Spacing.screenH,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: Spacing.md),
                          DriverSupportTicketsReportButton(
                            onPressed: widget.onReportTap ?? () {},
                          ),
                          const SizedBox(
                            height: Spacing.bottomNavHeight + Spacing.md,
                          ),
                        ],
                      ),
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
