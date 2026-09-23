import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/driver_performance_period.dart';
import '../../domain/entities/driver_performance_query_entity.dart';
import '../../domain/entities/driver_performance_sort_field.dart';
import '../../domain/entities/driver_performance_tab_type.dart';
import '../../domain/usecase/get_driver_performance_comparison_usecase.dart';
import '../../domain/usecase/get_driver_performance_overview_usecase.dart';
import 'driver_performance_event.dart';
import 'driver_performance_state.dart';

@injectable
class DriverPerformanceViewModel extends Cubit<DriverPerformanceState> {
  DriverPerformanceViewModel({
    required this.getOverviewUseCase,
    required this.getComparisonUseCase,
  }) : super(const DriverPerformanceState());

  final GetDriverPerformanceOverviewUseCase getOverviewUseCase;
  final GetDriverPerformanceComparisonUseCase getComparisonUseCase;

  int _overviewGeneration = 0;
  int _comparisonGeneration = 0;

  void add(DriverPerformanceEvent event) => doIntent(event);

  void doIntent(DriverPerformanceEvent event) {
    switch (event) {
      case LoadDriverPerformanceOverviewEvent():
        _loadOverview();
      case SelectDriverPerformanceTabEvent(:final tab):
        _selectTab(tab);
      case SelectDriverPerformancePeriodEvent(:final period):
        _selectPeriod(period);
      case SelectDriverPerformanceCustomRangeEvent(:final fromDate, :final toDate):
        _selectCustomRange(fromDate, toDate);
      case RefreshDriverPerformanceEvent():
        _refresh();
      case RetryDriverPerformanceEvent():
        _retry();
      case SortDriverPerformanceTableEvent(:final field):
        _sortTable(field);
    }
  }

  void _selectTab(DriverPerformanceTabType tab) {
    if (state.selectedTab == tab) return;

    emit(state.copyWith(selectedTab: tab));

    if (tab == DriverPerformanceTabType.compareDrivers &&
        !state.hasLoadedComparison &&
        !state.isComparisonInitialLoading) {
      _loadComparison();
    } else if (tab == DriverPerformanceTabType.overview &&
        !state.hasLoadedOverview &&
        !state.isOverviewInitialLoading) {
      _loadOverview();
    }
  }

  void _selectPeriod(DriverPerformancePeriod period) {
    if (state.selectedPeriod == period &&
        period != DriverPerformancePeriod.custom &&
        (state.overview != null || state.comparison != null)) {
      return;
    }

    final newQuery = DriverPerformanceQueryEntity(period: period);
    _applyNewPeriodQuery(newQuery);
  }

  void _selectCustomRange(DateTime fromDate, DateTime toDate) {
    final newQuery = DriverPerformanceQueryEntity(
      period: DriverPerformancePeriod.custom,
      fromDate: fromDate,
      toDate: toDate,
    );
    _applyNewPeriodQuery(newQuery);
  }

  void _applyNewPeriodQuery(DriverPerformanceQueryEntity newQuery) {
    // Clear old-period data and failures so stale data from a previous period is not shown
    emit(
      state.copyWith(
        query: newQuery,
        clearOverview: true,
        clearComparison: true,
        clearOverviewFailure: true,
        clearComparisonFailure: true,
        clearRefreshFailure: true,
        hasLoadedOverview: false,
        hasLoadedComparison: false,
      ),
    );

    // Trigger load for the currently active tab
    if (state.selectedTab == DriverPerformanceTabType.overview) {
      _loadOverview();
    } else {
      _loadComparison();
    }
  }

  Future<void> _loadOverview() async {
    final currentGen = ++_overviewGeneration;

    emit(
      state.copyWith(
        isOverviewInitialLoading: true,
        clearOverviewFailure: true,
      ),
    );

    final result = await getOverviewUseCase(state.query);
    if (isClosed || currentGen != _overviewGeneration) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            overview: data,
            isOverviewInitialLoading: false,
            clearOverviewFailure: true,
            hasLoadedOverview: true,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            overviewFailure: failure,
            isOverviewInitialLoading: false,
            hasLoadedOverview: false,
          ),
        );
    }
  }

  Future<void> _loadComparison() async {
    final currentGen = ++_comparisonGeneration;

    emit(
      state.copyWith(
        isComparisonInitialLoading: true,
        clearComparisonFailure: true,
      ),
    );

    final result = await getComparisonUseCase(state.query);
    if (isClosed || currentGen != _comparisonGeneration) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            comparison: data,
            isComparisonInitialLoading: false,
            clearComparisonFailure: true,
            hasLoadedComparison: true,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            comparisonFailure: failure,
            isComparisonInitialLoading: false,
            hasLoadedComparison: false,
          ),
        );
    }
  }

  Future<void> _refresh() async {
    if (state.isRefreshing) return;

    emit(
      state.copyWith(
        isRefreshing: true,
        clearRefreshFailure: true,
      ),
    );

    if (state.selectedTab == DriverPerformanceTabType.overview) {
      final currentGen = ++_overviewGeneration;
      final result = await getOverviewUseCase(state.query);
      if (isClosed || currentGen != _overviewGeneration) return;

      switch (result) {
        case ApiSuccessResult(:final data):
          emit(
            state.copyWith(
              overview: data,
              isRefreshing: false,
              clearRefreshFailure: true,
              clearOverviewFailure: true,
              hasLoadedOverview: true,
            ),
          );
        case ApiErrorResult(:final failure):
          emit(
            state.copyWith(
              isRefreshing: false,
              refreshFailure: failure,
            ),
          );
      }
    } else {
      final currentGen = ++_comparisonGeneration;
      final result = await getComparisonUseCase(state.query);
      if (isClosed || currentGen != _comparisonGeneration) return;

      switch (result) {
        case ApiSuccessResult(:final data):
          emit(
            state.copyWith(
              comparison: data,
              isRefreshing: false,
              clearRefreshFailure: true,
              clearComparisonFailure: true,
              hasLoadedComparison: true,
            ),
          );
        case ApiErrorResult(:final failure):
          emit(
            state.copyWith(
              isRefreshing: false,
              refreshFailure: failure,
            ),
          );
      }
    }
  }

  void _retry() {
    if (state.selectedTab == DriverPerformanceTabType.overview) {
      _loadOverview();
    } else {
      _loadComparison();
    }
  }

  void _sortTable(DriverPerformanceSortField field) {
    if (state.sortField == field) {
      emit(state.copyWith(sortAscending: !state.sortAscending));
    } else {
      emit(state.copyWith(sortField: field, sortAscending: false));
    }
  }
}
