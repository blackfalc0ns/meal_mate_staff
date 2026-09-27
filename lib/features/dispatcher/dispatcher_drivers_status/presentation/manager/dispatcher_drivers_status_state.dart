import '../../../../../core/network/failures.dart';
import '../../domain/entities/dispatcher_driver_status_item_entity.dart';
import '../../domain/entities/dispatcher_driver_status_type.dart';
import '../../domain/entities/dispatcher_drivers_status_query_entity.dart';
import '../../domain/entities/dispatcher_drivers_status_summary_entity.dart';

class DispatcherDriversStatusState {
  const DispatcherDriversStatusState({
    this.query = const DispatcherDriversStatusQueryEntity(),
    this.summary,
    this.initialFailure,
    this.actionFailure,
    this.isInitialLoading = true,
    this.isRefreshing = false,
    this.isPageLoading = false,
    this.togglingDriverIds = const {},
  });

  final DispatcherDriversStatusQueryEntity query;
  final DispatcherDriversStatusSummaryEntity? summary;
  final Failure? initialFailure;
  final Failure? actionFailure;
  final bool isInitialLoading;
  final bool isRefreshing;
  final bool isPageLoading;
  final Set<String> togglingDriverIds;

  bool get isLoading => isInitialLoading || isRefreshing || isPageLoading;
  bool get hasError => initialFailure != null && summary == null;
  Failure? get failure => initialFailure ?? actionFailure;
  DispatcherDriverStatusType? get selectedFilter => query.status;
  String get searchQuery => query.search ?? '';
  List<DispatcherDriverStatusItemEntity> get filteredDrivers =>
      summary?.items ?? const [];

  DispatcherDriversStatusState copyWith({
    DispatcherDriversStatusQueryEntity? query,
    DispatcherDriversStatusSummaryEntity? summary,
    Failure? initialFailure,
    bool clearInitialFailure = false,
    Failure? actionFailure,
    bool clearActionFailure = false,
    bool? isInitialLoading,
    bool? isRefreshing,
    bool? isPageLoading,
    Set<String>? togglingDriverIds,
    // Backward compatibility arguments
    String? searchQuery,
    DispatcherDriverStatusType? selectedFilter,
    bool clearFilter = false,
    Failure? failure,
  }) {
    var updatedQuery = query ?? this.query;
    if (searchQuery != null) {
      updatedQuery = updatedQuery.copyWith(
        search: searchQuery,
        clearSearch: searchQuery.trim().isEmpty,
      );
    }
    if (clearFilter) {
      updatedQuery = updatedQuery.copyWith(clearStatus: true);
    } else if (selectedFilter != null) {
      updatedQuery = updatedQuery.copyWith(status: selectedFilter);
    }

    return DispatcherDriversStatusState(
      query: updatedQuery,
      summary: summary ?? this.summary,
      initialFailure: clearInitialFailure
          ? null
          : (initialFailure ?? failure ?? this.initialFailure),
      actionFailure: clearActionFailure
          ? null
          : (actionFailure ?? this.actionFailure),
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isPageLoading: isPageLoading ?? this.isPageLoading,
      togglingDriverIds: togglingDriverIds ?? this.togglingDriverIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriversStatusState &&
          runtimeType == other.runtimeType &&
          query == other.query &&
          summary == other.summary &&
          initialFailure == other.initialFailure &&
          actionFailure == other.actionFailure &&
          isInitialLoading == other.isInitialLoading &&
          isRefreshing == other.isRefreshing &&
          isPageLoading == other.isPageLoading &&
          togglingDriverIds == other.togglingDriverIds;

  @override
  int get hashCode => Object.hash(
    query,
    summary,
    initialFailure,
    actionFailure,
    isInitialLoading,
    isRefreshing,
    isPageLoading,
    togglingDriverIds,
  );
}
