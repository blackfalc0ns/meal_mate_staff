import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/dispatcher_driver_status_item_entity.dart';
import '../../domain/entities/dispatcher_driver_status_type.dart';
import '../../domain/entities/dispatcher_drivers_status_kpis_entity.dart';
import '../../domain/entities/dispatcher_drivers_status_query_entity.dart';
import '../../domain/entities/dispatcher_drivers_status_sort.dart';
import '../../domain/entities/update_driver_availability_request_entity.dart';
import '../../domain/entities/update_driver_availability_result_entity.dart';
import '../../domain/usecase/get_drivers_status_usecase.dart';
import '../../domain/usecase/observe_driver_availability_updates_usecase.dart';
import '../../domain/usecase/start_dispatcher_drivers_status_updates_usecase.dart';
import '../../domain/usecase/stop_dispatcher_drivers_status_updates_usecase.dart';
import '../../domain/usecase/toggle_driver_availability_usecase.dart';
import 'dispatcher_drivers_status_event.dart';
import 'dispatcher_drivers_status_state.dart';

@injectable
class DispatcherDriversStatusViewModel
    extends Cubit<DispatcherDriversStatusState> {
  DispatcherDriversStatusViewModel({
    required this.getDriversStatusUseCase,
    required this.toggleDriverAvailabilityUseCase,
    this.observeDriverAvailabilityUpdatesUseCase,
    this.startUpdatesUseCase,
    this.stopUpdatesUseCase,
  }) : super(const DispatcherDriversStatusState());

  final GetDriversStatusUseCase getDriversStatusUseCase;
  final ToggleDriverAvailabilityUseCase toggleDriverAvailabilityUseCase;
  final ObserveDriverAvailabilityUpdatesUseCase?
  observeDriverAvailabilityUpdatesUseCase;
  final StartDispatcherDriversStatusUpdatesUseCase? startUpdatesUseCase;
  final StopDispatcherDriversStatusUpdatesUseCase? stopUpdatesUseCase;

  static const String _realtimeOwnerId = 'dispatcher-drivers-status';
  int _requestGeneration = 0;
  Timer? _searchDebounce;
  Timer? _refreshDebounce;
  StreamSubscription<UpdateDriverAvailabilityResultEntity>?
  _realtimeSubscription;
  bool _realtimeAcquired = false;

  void _initRealtime() {
    if (_realtimeAcquired) return;
    _realtimeAcquired = true;
    unawaited(startUpdatesUseCase?.call(_realtimeOwnerId));
    _realtimeSubscription = observeDriverAvailabilityUpdatesUseCase
        ?.call()
        .listen((update) {
          unawaited(doIntent(DriverAvailabilityUpdatedRealtimeEvent(update)));
        });
  }

  Future<void> doIntent(DispatcherDriversStatusEvent event) async {
    switch (event) {
      case LoadDispatcherDriversStatusEvent():
        _initRealtime();
        await _fetchQuery(state.query);

      case RefreshDispatcherDriversStatusEvent():
        await _fetchQuery(state.query, isRefreshing: true);

      case SearchDriversStatusEvent(:final query):
        _onSearchChanged(query);

      case FilterDriversStatusEvent(:final statusFilter):
        _onFilterChanged(statusFilter);

      case SortDriversStatusEvent(:final sort):
        _onSortChanged(sort);

      case ChangeDriversStatusPageEvent(:final pageNumber):
        _onPageChanged(pageNumber);

      case ToggleDriverStatusEvent(
        :final driverId,
        :final isAvailable,
        :final reason,
      ):
        await _toggleDriver(driverId, isAvailable, reason: reason);

      case DriverAvailabilityUpdatedRealtimeEvent(:final update):
        _onRealtimeUpdateReceived(update);

      case ClearActionFailureEvent():
        emit(state.copyWith(clearActionFailure: true));
    }
  }

  void _onSearchChanged(String query) {
    final trimmed = query.trim();
    final updatedQuery = state.query.copyWith(
      search: trimmed,
      clearSearch: trimmed.isEmpty,
      pageNumber: 1,
    );
    emit(state.copyWith(query: updatedQuery));

    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () {
      unawaited(_fetchQuery(state.query));
    });
  }

  void _onFilterChanged(DispatcherDriverStatusType? status) {
    _searchDebounce?.cancel();
    final updatedQuery = state.query.copyWith(
      status: status,
      clearStatus: status == null,
      pageNumber: 1,
    );
    unawaited(_fetchQuery(updatedQuery));
  }

  void _onSortChanged(DispatcherDriversStatusSort sort) {
    _searchDebounce?.cancel();
    final updatedQuery = state.query.copyWith(sortBy: sort, pageNumber: 1);
    unawaited(_fetchQuery(updatedQuery));
  }

  void _onPageChanged(int pageNumber) {
    if (pageNumber == state.query.pageNumber) return;
    final updatedQuery = state.query.copyWith(pageNumber: pageNumber);
    unawaited(_fetchQuery(updatedQuery, isPageLoading: true));
  }

  Future<void> _fetchQuery(
    DispatcherDriversStatusQueryEntity targetQuery, {
    bool isRefreshing = false,
    bool isPageLoading = false,
  }) async {
    final currentGen = ++_requestGeneration;

    final isInitial = state.summary == null && !isRefreshing && !isPageLoading;

    emit(
      state.copyWith(
        query: targetQuery,
        isInitialLoading: isInitial,
        isRefreshing: isRefreshing,
        isPageLoading: isPageLoading,
        clearInitialFailure: isInitial,
        clearActionFailure: true,
      ),
    );

    final result = await getDriversStatusUseCase(targetQuery);

    if (currentGen != _requestGeneration) {
      // Stale response rejection
      return;
    }

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            summary: data,
            isInitialLoading: false,
            isRefreshing: false,
            isPageLoading: false,
            clearInitialFailure: true,
            clearActionFailure: true,
          ),
        );

      case ApiErrorResult(:final failure):
        if (state.summary == null) {
          emit(
            state.copyWith(
              initialFailure: failure,
              isInitialLoading: false,
              isRefreshing: false,
              isPageLoading: false,
            ),
          );
        } else {
          emit(
            state.copyWith(
              actionFailure: failure,
              isInitialLoading: false,
              isRefreshing: false,
              isPageLoading: false,
            ),
          );
        }
    }
  }

  Future<void> _toggleDriver(
    String driverId,
    bool requestedAvailability, {
    String? reason,
  }) async {
    if (state.togglingDriverIds.contains(driverId)) return;

    final currentSummary = state.summary;
    if (currentSummary == null) return;

    final targetDriverIndex = currentSummary.items.indexWhere(
      (d) => d.driverId == driverId,
    );
    if (targetDriverIndex == -1) return;

    final previousDriver = currentSummary.items[targetDriverIndex];
    final previousCounts = currentSummary.counts;

    // Optimistic status respecting delivery priority
    final optimisticStatus =
        previousDriver.operationalStatus ==
            DispatcherDriverStatusType.inDelivery
        ? DispatcherDriverStatusType.inDelivery
        : requestedAvailability
        ? DispatcherDriverStatusType.available
        : DispatcherDriverStatusType.unavailable;

    final updatedItems = List<DispatcherDriverStatusItemEntity>.from(
      currentSummary.items,
    );
    updatedItems[targetDriverIndex] = previousDriver.copyWith(
      isAvailable: requestedAvailability,
      operationalStatus: optimisticStatus,
    );

    // Optimistic counts
    var availableCount = previousCounts.available;
    var unavailableCount = previousCounts.unavailable;

    if (previousDriver.operationalStatus ==
            DispatcherDriverStatusType.available &&
        optimisticStatus == DispatcherDriverStatusType.unavailable) {
      availableCount = (availableCount - 1).clamp(0, 99999);
      unavailableCount += 1;
    } else if (previousDriver.operationalStatus ==
            DispatcherDriverStatusType.unavailable &&
        optimisticStatus == DispatcherDriverStatusType.available) {
      unavailableCount = (unavailableCount - 1).clamp(0, 99999);
      availableCount += 1;
    }

    final optimisticCounts = DispatcherDriversStatusKpisEntity(
      total: previousCounts.total,
      available: availableCount,
      inDelivery: previousCounts.inDelivery,
      unavailable: unavailableCount,
    );

    emit(
      state.copyWith(
        summary: currentSummary.copyWith(
          items: updatedItems,
          counts: optimisticCounts,
        ),
        togglingDriverIds: {...state.togglingDriverIds, driverId},
        clearActionFailure: true,
      ),
    );

    final result = await toggleDriverAvailabilityUseCase(
      request: UpdateDriverAvailabilityRequestEntity(
        driverId: driverId,
        isAvailable: requestedAvailability,
        reason: reason,
      ),
    );

    final updatedToggling = Set<String>.from(state.togglingDriverIds)
      ..remove(driverId);

    switch (result) {
      case ApiSuccessResult(:final data):
        final reconciledItems = List<DispatcherDriverStatusItemEntity>.from(
          state.summary!.items,
        );
        final index = reconciledItems.indexWhere((d) => d.driverId == driverId);
        if (index != -1) {
          reconciledItems[index] = reconciledItems[index].copyWith(
            isAvailable: data.isAvailable,
            operationalStatus: data.operationalStatus,
          );
        }
        emit(
          state.copyWith(
            summary: state.summary!.copyWith(items: reconciledItems),
            togglingDriverIds: updatedToggling,
          ),
        );

      case ApiErrorResult(:final failure):
        // Rollback exact snapshot on failure
        final revertedItems = List<DispatcherDriverStatusItemEntity>.from(
          state.summary!.items,
        );
        final index = revertedItems.indexWhere((d) => d.driverId == driverId);
        if (index != -1) {
          revertedItems[index] = previousDriver;
        }

        emit(
          state.copyWith(
            summary: state.summary!.copyWith(
              items: revertedItems,
              counts: previousCounts,
            ),
            actionFailure: failure,
            togglingDriverIds: updatedToggling,
          ),
        );
    }
  }

  void _onRealtimeUpdateReceived(UpdateDriverAvailabilityResultEntity update) {
    final currentSummary = state.summary;
    if (currentSummary == null) return;

    final targetDriverIndex = currentSummary.items.indexWhere(
      (d) => d.driverId == update.driverId,
    );

    if (targetDriverIndex != -1) {
      final existingDriver = currentSummary.items[targetDriverIndex];
      final updatedDriver = existingDriver.copyWith(
        isAvailable: update.isAvailable,
        operationalStatus: update.operationalStatus,
      );

      final updatedItems = List<DispatcherDriverStatusItemEntity>.from(
        currentSummary.items,
      );
      updatedItems[targetDriverIndex] = updatedDriver;

      // Adjust counts authoritatively
      var available = currentSummary.counts.available;
      var unavailable = currentSummary.counts.unavailable;

      if (existingDriver.operationalStatus ==
              DispatcherDriverStatusType.available &&
          update.operationalStatus == DispatcherDriverStatusType.unavailable) {
        available = (available - 1).clamp(0, 99999);
        unavailable += 1;
      } else if (existingDriver.operationalStatus ==
              DispatcherDriverStatusType.unavailable &&
          update.operationalStatus == DispatcherDriverStatusType.available) {
        unavailable = (unavailable - 1).clamp(0, 99999);
        available += 1;
      }

      final updatedCounts = DispatcherDriversStatusKpisEntity(
        total: currentSummary.counts.total,
        available: available,
        inDelivery: currentSummary.counts.inDelivery,
        unavailable: unavailable,
      );

      final updatedToggling = Set<String>.from(state.togglingDriverIds)
        ..remove(update.driverId);

      emit(
        state.copyWith(
          summary: currentSummary.copyWith(
            items: updatedItems,
            counts: updatedCounts,
          ),
          togglingDriverIds: updatedToggling,
        ),
      );
    } else {
      // Driver not in current page, debounced refresh for global counts
      _refreshDebounce?.cancel();
      _refreshDebounce = Timer(const Duration(milliseconds: 300), () {
        unawaited(_fetchQuery(state.query, isRefreshing: true));
      });
    }
  }

  @override
  Future<void> close() async {
    _searchDebounce?.cancel();
    _refreshDebounce?.cancel();
    await _realtimeSubscription?.cancel();
    if (_realtimeAcquired) {
      await stopUpdatesUseCase?.call(_realtimeOwnerId);
    }
    return super.close();
  }
}
