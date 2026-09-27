import '../../../../../core/network/failures.dart';
import '../../domain/entities/dispatcher_driver_status_item_entity.dart';
import '../../domain/entities/dispatcher_driver_status_type.dart';
import '../../domain/entities/dispatcher_drivers_status_summary_entity.dart';

class DispatcherDriversStatusState {
  const DispatcherDriversStatusState({
    this.isInitialLoading = true,
    this.isRefreshing = false,
    this.summary,
    this.searchQuery = '',
    this.selectedFilter,
    this.failure,
    this.togglingDriverIds = const {},
  });

  final bool isInitialLoading;
  final bool isRefreshing;
  final DispatcherDriversStatusSummaryEntity? summary;
  final String searchQuery;
  final DispatcherDriverStatusType? selectedFilter;
  final Failure? failure;
  final Set<String> togglingDriverIds;

  bool get isLoading => isInitialLoading || isRefreshing;
  bool get hasError => failure != null && summary == null;

  List<DispatcherDriverStatusItemEntity> get filteredDrivers {
    if (summary == null) return const [];
    return summary!.drivers.where((driver) {
      if (selectedFilter != null && driver.status != selectedFilter) {
        return false;
      }
      if (searchQuery.trim().isEmpty) return true;
      final q = searchQuery.trim().toLowerCase();
      final nameMatches = driver.name.toLowerCase().contains(q);
      final codeMatches = driver.code.toLowerCase().contains(q);
      final plateMatches = driver.plateNumber.toLowerCase().contains(q);
      return nameMatches || codeMatches || plateMatches;
    }).toList();
  }

  DispatcherDriversStatusState copyWith({
    bool? isInitialLoading,
    bool? isRefreshing,
    DispatcherDriversStatusSummaryEntity? summary,
    String? searchQuery,
    DispatcherDriverStatusType? selectedFilter,
    bool clearFilter = false,
    Failure? failure,
    Set<String>? togglingDriverIds,
  }) {
    return DispatcherDriversStatusState(
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      summary: summary ?? this.summary,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedFilter: clearFilter ? null : (selectedFilter ?? this.selectedFilter),
      failure: failure,
      togglingDriverIds: togglingDriverIds ?? this.togglingDriverIds,
    );
  }
}
