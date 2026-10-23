import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/errors/error_widgets/api_error_widget.dart';
import '../../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../../core/widget/shimmer_widget.dart';
import '../../domain/entities/driver_support_ticket_entity.dart';
import '../../domain/entities/driver_support_ticket_status.dart';
import '../../domain/fake_data/driver_support_tickets_fake_data.dart';
import '../manager/driver_support_tickets_event.dart';
import '../manager/driver_support_tickets_state.dart';
import '../manager/driver_support_tickets_view_model.dart';
import '../widgets/driver_support_tickets_header.dart';
import '../widgets/driver_support_tickets_kpi_row.dart';
import '../widgets/driver_support_tickets_list.dart';
import '../widgets/driver_support_tickets_list_shimmer.dart';
import '../widgets/driver_support_tickets_report_button.dart';
import '../widgets/driver_support_tickets_search_field.dart';

class DriverSupportTicketsScreen extends StatefulWidget {
  const DriverSupportTicketsScreen({
    super.key,
    this.viewModel,
    this.initialTickets,
    this.onTicketTap,
    this.onReportTap,
  });

  final DriverSupportTicketsViewModel? viewModel;
  final List<DriverSupportTicketEntity>? initialTickets;
  final ValueChanged<DriverSupportTicketEntity>? onTicketTap;
  final VoidCallback? onReportTap;

  @override
  State<DriverSupportTicketsScreen> createState() =>
      _DriverSupportTicketsScreenState();
}

class _DriverSupportTicketsScreenState
    extends State<DriverSupportTicketsScreen> {
  DriverSupportTicketsViewModel? _viewModel;
  bool _ownsViewModel = false;

  late final ScrollController _scrollController;
  late final TextEditingController _searchController;

  // Fallback state when ViewModel is not available (e.g. tests without DI)
  late final List<DriverSupportTicketEntity> _fallbackTickets;
  DriverSupportTicketFilter _fallbackFilter = DriverSupportTicketFilter.all;
  String _fallbackSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController()..addListener(_onScroll);

    if (widget.viewModel != null) {
      _viewModel = widget.viewModel;
      _ownsViewModel = false;
      _viewModel?.doIntent(const LoadDriverSupportTicketsEvent());
    } else if (widget.initialTickets == null &&
        getIt.isRegistered<DriverSupportTicketsViewModel>()) {
      _viewModel = getIt<DriverSupportTicketsViewModel>();
      _ownsViewModel = true;
      _viewModel?.doIntent(const LoadDriverSupportTicketsEvent());
    } else {
      _fallbackTickets =
          widget.initialTickets ?? DriverSupportTicketsFakeData.tickets;
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    if (_ownsViewModel) {
      unawaited(_viewModel?.close());
    }
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (maxScroll - currentScroll <= 200) {
      _viewModel?.doIntent(const LoadMoreDriverSupportTicketsEvent());
    }
  }

  void _onSearchChanged(String query) {
    if (_viewModel != null) {
      _viewModel!.doIntent(SearchDriverSupportTicketsEvent(query));
    } else {
      setState(() {
        _fallbackSearchQuery = query.trim().toLowerCase();
      });
    }
  }

  void _onFilterChanged(DriverSupportTicketFilter filter) {
    if (_viewModel != null) {
      _viewModel!.doIntent(ChangeDriverSupportTicketFilterEvent(filter));
    } else {
      if (_fallbackFilter != filter) {
        setState(() {
          _fallbackFilter = filter;
        });
      }
    }
  }

  List<DriverSupportTicketEntity> _getFilteredFallbackTickets() {
    return _fallbackTickets.where((ticket) {
      if (_fallbackFilter != DriverSupportTicketFilter.all) {
        final matchesStatus = switch (_fallbackFilter) {
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

      if (_fallbackSearchQuery.isNotEmpty) {
        final boxMatches = ticket.boxNumber.toLowerCase().contains(
          _fallbackSearchQuery,
        );
        final titleMatches = ticket.title.toLowerCase().contains(
          _fallbackSearchQuery,
        );
        final locationMatches = ticket.location.toLowerCase().contains(
          _fallbackSearchQuery,
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
    if (_viewModel != null) {
      return BlocBuilder<DriverSupportTicketsViewModel, DriverSupportTicketsState>(
        bloc: _viewModel,
        builder: (context, state) {
          if (state.isLoading && state.tickets.isEmpty) {
            return const Scaffold(
              appBar: DriverSupportTicketsHeader(),
              body: DriverSupportTicketsListShimmer(),
            );
          }

          if (state.initialFailure != null && state.tickets.isEmpty) {
            return Scaffold(
              appBar: const DriverSupportTicketsHeader(),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.screenH),
                  child: ApiErrorWidget.fromTypedFailure(
                    failure: state.initialFailure!,
                    onRetry: () => _viewModel?.doIntent(
                      const RetryDriverSupportTicketsEvent(),
                    ),
                  ),
                ),
              ),
            );
          }

          return _buildContent(
            context: context,
            tickets: state.tickets,
            selectedFilter: state.selectedFilter,
            allCount: state.allCount,
            underReviewCount: state.underReviewCount,
            awaitingResponseCount: state.awaitingResponseCount,
            resolvedCount: state.resolvedCount,
            isLoadingMore: state.isLoadingMore,
            inlineFailure: state.refreshFailure ?? state.paginationFailure,
            onRefresh: () async {
              final completer = Completer<void>();
              _viewModel?.doIntent(
                RefreshDriverSupportTicketsEvent(onCompleted: completer.complete),
              );
              await completer.future;
            },
          );
        },
      );
    }

    final filteredTickets = _getFilteredFallbackTickets();
    return _buildContent(
      context: context,
      tickets: filteredTickets,
      selectedFilter: _fallbackFilter,
      allCount: _fallbackTickets.length,
      underReviewCount: _fallbackTickets
          .where((t) => t.status == DriverSupportTicketStatus.underReview)
          .length,
      awaitingResponseCount: _fallbackTickets
          .where((t) => t.status == DriverSupportTicketStatus.awaitingResponse)
          .length,
      resolvedCount: _fallbackTickets
          .where((t) => t.status == DriverSupportTicketStatus.resolved)
          .length,
      isLoadingMore: false,
      inlineFailure: null,
      onRefresh: null,
    );
  }

  Widget _buildContent({
    required BuildContext context,
    required List<DriverSupportTicketEntity> tickets,
    required DriverSupportTicketFilter selectedFilter,
    required int allCount,
    required int underReviewCount,
    required int awaitingResponseCount,
    required int resolvedCount,
    required bool isLoadingMore,
    required dynamic inlineFailure,
    required Future<void> Function()? onRefresh,
  }) {
    Widget scrollView = CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.screenH),
          sliver: DriverSupportTicketsList.sliver(
            tickets: tickets,
            onTicketTap: widget.onTicketTap ??
                (ticket) {
                  final targetArg =
                      ticket.id.isNotEmpty ? ticket.id : ticket;
                  unawaited(
                    Navigator.of(context)
                        .pushNamed(
                          AppRoutes.driverSupportTicketDetails,
                          arguments: targetArg,
                        )
                        .then((_) {
                      if (mounted && _viewModel != null) {
                        _viewModel?.doIntent(
                          const RefreshDriverSupportTicketsEvent(),
                        );
                      }
                    }),
                  );
                },
          ),
        ),
        if (isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Spacing.screenH,
                vertical: Spacing.sm,
              ),
              child: ShimmerWidget(
                height: 72,
                borderRadius: Spacing.cardRadius,
              ),
            ),
          ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.screenH),
          sliver: SliverToBoxAdapter(
            child: Column(
              children: [
                const SizedBox(height: Spacing.md),
                DriverSupportTicketsReportButton(
                  onPressed: widget.onReportTap ??
                      () {
                        unawaited(
                          Navigator.of(context)
                              .pushNamed(AppRoutes.driverReportIssue)
                              .then((_) {
                            if (mounted && _viewModel != null) {
                              _viewModel?.doIntent(
                                const RefreshDriverSupportTicketsEvent(),
                              );
                            }
                          }),
                        );
                      },
                ),
                const SizedBox(
                  height: Spacing.bottomNavHeight + Spacing.md,
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (onRefresh != null) {
      scrollView = RefreshIndicator(
        onRefresh: onRefresh,
        child: scrollView,
      );
    }

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
                    selectedFilter: selectedFilter,
                    allCount: allCount,
                    underReviewCount: underReviewCount,
                    awaitingResponseCount: awaitingResponseCount,
                    resolvedCount: resolvedCount,
                    onFilterChanged: _onFilterChanged,
                  ),
                  if (inlineFailure != null) ...[
                    const SizedBox(height: Spacing.xs),
                    InlineApiErrorWidget(
                      failure: inlineFailure,
                      onRetry: () => _viewModel?.doIntent(
                        const RetryDriverSupportTicketsEvent(),
                      ),
                    ),
                  ],
                  const SizedBox(height: Spacing.md),
                ],
              ),
            ),
            Expanded(child: scrollView),
          ],
        ),
      ),
    );
  }
}
