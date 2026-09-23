import '../../../../../core/network/failures.dart';
import '../../domain/entities/driver_performance_comparison_entity.dart';
import '../../domain/entities/driver_performance_overview_entity.dart';
import '../../domain/entities/driver_performance_period.dart';
import '../../domain/entities/driver_performance_query_entity.dart';
import '../../domain/entities/driver_performance_record_entity.dart';
import '../../domain/entities/driver_performance_sort_field.dart';
import '../../domain/entities/driver_performance_tab_type.dart';

class DriverPerformanceState {
  const DriverPerformanceState({
    this.selectedTab = DriverPerformanceTabType.overview,
    this.query = const DriverPerformanceQueryEntity(
      period: DriverPerformancePeriod.last7Days,
    ),
    this.overview,
    this.comparison,
    this.isOverviewInitialLoading = false,
    this.isComparisonInitialLoading = false,
    this.isRefreshing = false,
    this.overviewFailure,
    this.comparisonFailure,
    this.refreshFailure,
    this.sortField = DriverPerformanceSortField.rating,
    this.sortAscending = false,
    this.hasLoadedOverview = false,
    this.hasLoadedComparison = false,
  });

  final DriverPerformanceTabType selectedTab;
  final DriverPerformanceQueryEntity query;
  final DriverPerformanceOverviewEntity? overview;
  final DriverPerformanceComparisonEntity? comparison;
  final bool isOverviewInitialLoading;
  final bool isComparisonInitialLoading;
  final bool isRefreshing;
  final Failure? overviewFailure;
  final Failure? comparisonFailure;
  final Failure? refreshFailure;
  final DriverPerformanceSortField sortField;
  final bool sortAscending;
  final bool hasLoadedOverview;
  final bool hasLoadedComparison;

  DriverPerformancePeriod get selectedPeriod => query.period;

  List<DriverPerformanceRecordEntity> get sortedDriversTable {
    final list = overview?.driversTable;
    if (list == null || list.isEmpty) return const [];
    return list.sortedByField(sortField, ascending: sortAscending);
  }

  bool get isActiveTabLoading => switch (selectedTab) {
        DriverPerformanceTabType.overview => isOverviewInitialLoading,
        DriverPerformanceTabType.compareDrivers => isComparisonInitialLoading,
      };

  Failure? get activeTabFailure => switch (selectedTab) {
        DriverPerformanceTabType.overview => overviewFailure,
        DriverPerformanceTabType.compareDrivers => comparisonFailure,
      };

  DriverPerformanceState copyWith({
    DriverPerformanceTabType? selectedTab,
    DriverPerformanceQueryEntity? query,
    DriverPerformanceOverviewEntity? overview,
    DriverPerformanceComparisonEntity? comparison,
    bool? isOverviewInitialLoading,
    bool? isComparisonInitialLoading,
    bool? isRefreshing,
    Failure? overviewFailure,
    Failure? comparisonFailure,
    Failure? refreshFailure,
    DriverPerformanceSortField? sortField,
    bool? sortAscending,
    bool? hasLoadedOverview,
    bool? hasLoadedComparison,
    bool clearOverview = false,
    bool clearComparison = false,
    bool clearOverviewFailure = false,
    bool clearComparisonFailure = false,
    bool clearRefreshFailure = false,
  }) {
    return DriverPerformanceState(
      selectedTab: selectedTab ?? this.selectedTab,
      query: query ?? this.query,
      overview: clearOverview ? null : (overview ?? this.overview),
      comparison: clearComparison ? null : (comparison ?? this.comparison),
      isOverviewInitialLoading:
          isOverviewInitialLoading ?? this.isOverviewInitialLoading,
      isComparisonInitialLoading:
          isComparisonInitialLoading ?? this.isComparisonInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      overviewFailure: clearOverviewFailure
          ? null
          : (overviewFailure ?? this.overviewFailure),
      comparisonFailure: clearComparisonFailure
          ? null
          : (comparisonFailure ?? this.comparisonFailure),
      refreshFailure: clearRefreshFailure
          ? null
          : (refreshFailure ?? this.refreshFailure),
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      hasLoadedOverview: hasLoadedOverview ?? this.hasLoadedOverview,
      hasLoadedComparison: hasLoadedComparison ?? this.hasLoadedComparison,
    );
  }
}
