import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../config/routing/app_routes.dart';
import '../../../../../config/theme/spacing.dart';
import '../../../../../core/di/di.dart';
import '../../../../../core/errors/error_widgets/api_error_widget.dart';
import '../../../../../core/errors/error_widgets/empty_state_widget.dart';
import '../../../../../core/errors/error_widgets/inline_api_error_widget.dart';
import '../../../../../core/extensions/extensions.dart';
import '../../domain/entities/driver_performance_period.dart';
import '../../domain/entities/driver_performance_tab_type.dart';
import '../manager/driver_performance_event.dart';
import '../manager/driver_performance_state.dart';
import '../manager/driver_performance_view_model.dart';
import '../widgets/driver_performance_comparison_content.dart';
import '../widgets/driver_performance_comparison_shimmer.dart';
import '../widgets/driver_performance_distribution_card.dart';
import '../widgets/driver_performance_header.dart';
import '../widgets/driver_performance_kpi_list.dart';
import '../widgets/driver_performance_overview_shimmer.dart';
import '../widgets/driver_performance_period_sheet.dart';
import '../widgets/driver_performance_segmented_tabs.dart';
import '../widgets/driver_performance_table_card.dart';
import '../widgets/driver_performance_top_rated_card.dart';

class DispatcherDriverPerformanceScreen extends StatefulWidget {
  const DispatcherDriverPerformanceScreen({
    super.key,
    this.viewModel,
    this.onOpenDriverDetails,
  });

  final DriverPerformanceViewModel? viewModel;
  final ValueChanged<String>? onOpenDriverDetails;

  @override
  State<DispatcherDriverPerformanceScreen> createState() =>
      _DispatcherDriverPerformanceScreenState();
}

class _DispatcherDriverPerformanceScreenState
    extends State<DispatcherDriverPerformanceScreen> {
  late final DriverPerformanceViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel ?? getIt<DriverPerformanceViewModel>();
    _viewModel.add(const LoadDriverPerformanceOverviewEvent());
  }

  @override
  void dispose() {
    if (widget.viewModel == null) {
      unawaited(_viewModel.close());
    }
    super.dispose();
  }

  void _onTabChanged(DriverPerformanceTabType tab) {
    _viewModel.add(SelectDriverPerformanceTabEvent(tab));
  }

  void _openPeriodSheet(BuildContext context, DriverPerformanceState state) {
    unawaited(
      DriverPerformancePeriodSheet.show(
        context,
        selectedPeriod: state.selectedPeriod,
        initialCustomFrom: state.query.fromDate,
        initialCustomTo: state.query.toDate,
        onPeriodSelected: (period) {
          _viewModel.add(SelectDriverPerformancePeriodEvent(period));
        },
        onCustomRangeSelected: (from, to) {
          _viewModel.add(
            SelectDriverPerformanceCustomRangeEvent(fromDate: from, toDate: to),
          );
        },
      ),
    );
  }

  String? _resolveDateFilterLabel(
    BuildContext context,
    DriverPerformanceState state,
  ) {
    if (state.selectedTab == DriverPerformanceTabType.overview) {
      if (state.overview?.periodText != null &&
          state.overview!.periodText.isNotEmpty &&
          !state.isOverviewInitialLoading) {
        return state.overview!.periodText;
      }
    } else {
      if (state.comparison?.periodText != null &&
          state.comparison!.periodText.isNotEmpty &&
          !state.isComparisonInitialLoading) {
        return state.comparison!.periodText;
      }
    }
    return _periodDisplayName(context, state.query.period);
  }

  String _periodDisplayName(
    BuildContext context,
    DriverPerformancePeriod period,
  ) {
    final locale = context.localization;
    return switch (period) {
      DriverPerformancePeriod.today => locale.driverPerformanceToday,
      DriverPerformancePeriod.yesterday => locale.driverPerformanceYesterday,
      DriverPerformancePeriod.last7Days => locale.driverPerformanceLast7Days,
      DriverPerformancePeriod.last30Days => locale.driverPerformanceLast30Days,
      DriverPerformancePeriod.thisMonth => locale.driverPerformanceThisMonth,
      DriverPerformancePeriod.custom => locale.driverPerformanceCustom,
      DriverPerformancePeriod.unknown => '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DriverPerformanceViewModel, DriverPerformanceState>(
      bloc: _viewModel,
      builder: (context, state) {
        return Scaffold(
          appBar: DriverPerformanceHeader(
            dateFilterLabel: _resolveDateFilterLabel(context, state),
            onDateFilterTap: () => _openPeriodSheet(context, state),
          ),
          body: SafeArea(child: _buildBody(context, state)),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, DriverPerformanceState state) {
    // 1. Initial loading for active tab: full screen shimmer
    if (state.isActiveTabLoading) {
      return state.selectedTab == DriverPerformanceTabType.overview
          ? const DriverPerformanceOverviewShimmer()
          : const DriverPerformanceComparisonShimmer();
    }

    // 2. Active tab failure with no usable data: full screen error
    final hasActiveData = state.selectedTab == DriverPerformanceTabType.overview
        ? state.overview != null
        : state.comparison != null;

    if (state.activeTabFailure != null && !hasActiveData) {
      return ApiErrorWidget.fromTypedFailure(
        failure: state.activeTabFailure!,
        onRetry: () => _viewModel.add(const RetryDriverPerformanceEvent()),
      );
    }

    // 3. Successful empty data for active tab
    final isTabEmpty = state.selectedTab == DriverPerformanceTabType.overview
        ? (state.overview != null && state.overview!.isEmpty)
        : (state.comparison != null && state.comparison!.isEmpty);

    if (isTabEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.base,
              vertical: Spacing.sm,
            ),
            child: DriverPerformanceSegmentedTabs(
              selectedTab: state.selectedTab,
              onTabChanged: _onTabChanged,
            ),
          ),
          Expanded(
            child: EmptyStateWidget(
              onAction: () =>
                  _viewModel.add(const RefreshDriverPerformanceEvent()),
            ),
          ),
        ],
      );
    }

    // 4. Usable content view
    return RefreshIndicator(
      onRefresh: () async {
        _viewModel.add(const RefreshDriverPerformanceEvent());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.screenH,
          vertical: Spacing.screenV,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DriverPerformanceSegmentedTabs(
              selectedTab: state.selectedTab,
              onTabChanged: _onTabChanged,
            ),
            const SizedBox(height: Spacing.md),
            if (state.refreshFailure != null) ...[
              InlineApiErrorWidget(
                failure: state.refreshFailure!,
                onRetry: () =>
                    _viewModel.add(const RefreshDriverPerformanceEvent()),
              ),
              const SizedBox(height: Spacing.md),
            ],
            if (state.selectedTab == DriverPerformanceTabType.overview)
              ..._buildOverviewCards(context, state)
            else
              ..._buildComparisonCards(context, state),
            const SizedBox(height: Spacing.xl),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildOverviewCards(
    BuildContext context,
    DriverPerformanceState state,
  ) {
    final overview = state.overview;
    if (overview == null) return const [];

    return [
      DriverPerformanceKpiList(items: overview.kpis.toKpiList()),
      const SizedBox(height: Spacing.md),
      DriverPerformanceTableCard(
        drivers: state.sortedDriversTable,
        sortField: state.sortField,
        sortAscending: state.sortAscending,
        onSort: (field) =>
            _viewModel.add(SortDriverPerformanceTableEvent(field)),
        onSelectDriverId: (driverId) {
          if (widget.onOpenDriverDetails != null) {
            widget.onOpenDriverDetails!(driverId);
          } else {
            unawaited(
              context.pushNamed(
                AppRoutes.dispatcherDriverDetails,
                arguments: driverId,
              ),
            );
          }
        },
      ),
      const SizedBox(height: Spacing.md),
      DriverPerformanceDistributionCard(
        items: overview.distribution.segments,
        totalBoxes: overview.kpis.totalBoxes,
      ),
      const SizedBox(height: Spacing.md),
      DriverPerformanceTopRatedCard(entries: overview.topDrivers),
    ];
  }

  List<Widget> _buildComparisonCards(
    BuildContext context,
    DriverPerformanceState state,
  ) {
    final comparison = state.comparison;
    if (comparison == null) return const [];

    return [DriverPerformanceComparisonContent(comparison: comparison)];
  }
}
