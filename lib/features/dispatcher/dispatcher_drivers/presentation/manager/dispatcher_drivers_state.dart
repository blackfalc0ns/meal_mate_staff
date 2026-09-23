import '../../../../../config/routing/arguments/dispatcher_drivers_route_arguments.dart';
import '../../../../../core/network/failures.dart';
import '../../domain/entities/dispatcher_driver_entity.dart';
import '../../domain/entities/dispatcher_driver_sort.dart';
import '../../domain/entities/dispatcher_drivers_mode.dart';
import '../../domain/entities/dispatcher_drivers_query_entity.dart';
import '../../domain/entities/dispatcher_drivers_roster_entity.dart';
import '../../domain/entities/driver_assignment_result_entity.dart';

class DispatcherDriversState {
  const DispatcherDriversState({
    required this.args,
    required this.query,
    this.roster,
    this.selectedSort = DispatcherDriverSort.nearestDistance,
    this.isInitialLoading = false,
    this.isReplacementLoading = false,
    this.assigningDriverId,
    this.initialFailure,
    this.nonFatalFailure,
    this.assignmentFailure,
    this.assignmentResult,
    this.selectedDriverForBrowse,
    this.noticeId = 0,
    this.hasLoadedOnce = false,
    this.lastSelectedAreaKey,
    this.lastSelectedAreaName,
  });

  final DispatcherDriversRouteArgs args;
  final DispatcherDriversQueryEntity query;
  final DispatcherDriversRosterEntity? roster;
  final DispatcherDriverSort selectedSort;
  final bool isInitialLoading;
  final bool isReplacementLoading;
  final String? assigningDriverId;
  final Failure? initialFailure;
  final Failure? nonFatalFailure;
  final Failure? assignmentFailure;
  final DriverAssignmentResultEntity? assignmentResult;
  final DispatcherDriverEntity? selectedDriverForBrowse;
  final int noticeId;
  final bool hasLoadedOnce;
  final String? lastSelectedAreaKey;
  final String? lastSelectedAreaName;

  bool get isLoading => isInitialLoading || isReplacementLoading;
  bool get isAssigning => assigningDriverId != null;
  bool get canAssign =>
      args.mode == DispatcherDriversMode.assignment && !isAssigning;
  bool get isEmpty =>
      hasLoadedOnce && roster != null && roster!.drivers.isEmpty;
  DispatcherDriverSort get sort => selectedSort;

  List<DispatcherDriverEntity> get sortedDrivers {
    if (roster == null) return const [];
    final list = List<DispatcherDriverEntity>.from(roster!.drivers);
    switch (selectedSort) {
      case DispatcherDriverSort.nearestDistance:
        list.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
      case DispatcherDriverSort.highestRating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
      case DispatcherDriverSort.leastActiveLoad:
        list.sort((a, b) => a.activeOrdersCount.compareTo(b.activeOrdersCount));
    }
    return list;
  }

  DispatcherDriversState copyWith({
    DispatcherDriversRouteArgs? args,
    DispatcherDriversQueryEntity? query,
    DispatcherDriversRosterEntity? roster,
    DispatcherDriverSort? selectedSort,
    bool? isInitialLoading,
    bool? isReplacementLoading,
    String? assigningDriverId,
    bool clearAssigningDriverId = false,
    Failure? initialFailure,
    bool clearInitialFailure = false,
    Failure? nonFatalFailure,
    bool clearNonFatalFailure = false,
    Failure? assignmentFailure,
    bool clearAssignmentFailure = false,
    DriverAssignmentResultEntity? assignmentResult,
    bool clearAssignmentResult = false,
    DispatcherDriverEntity? selectedDriverForBrowse,
    bool clearSelectedDriverForBrowse = false,
    int? noticeId,
    bool? hasLoadedOnce,
    String? lastSelectedAreaKey,
    String? lastSelectedAreaName,
  }) {
    return DispatcherDriversState(
      args: args ?? this.args,
      query: query ?? this.query,
      roster: roster ?? this.roster,
      selectedSort: selectedSort ?? this.selectedSort,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isReplacementLoading: isReplacementLoading ?? this.isReplacementLoading,
      assigningDriverId: clearAssigningDriverId
          ? null
          : (assigningDriverId ?? this.assigningDriverId),
      initialFailure: clearInitialFailure
          ? null
          : (initialFailure ?? this.initialFailure),
      nonFatalFailure: clearNonFatalFailure
          ? null
          : (nonFatalFailure ?? this.nonFatalFailure),
      assignmentFailure: clearAssignmentFailure
          ? null
          : (assignmentFailure ?? this.assignmentFailure),
      assignmentResult: clearAssignmentResult
          ? null
          : (assignmentResult ?? this.assignmentResult),
      selectedDriverForBrowse: clearSelectedDriverForBrowse
          ? null
          : (selectedDriverForBrowse ?? this.selectedDriverForBrowse),
      noticeId: noticeId ?? this.noticeId,
      hasLoadedOnce: hasLoadedOnce ?? this.hasLoadedOnce,
      lastSelectedAreaKey: lastSelectedAreaKey ?? this.lastSelectedAreaKey,
      lastSelectedAreaName: lastSelectedAreaName ?? this.lastSelectedAreaName,
    );
  }
}
