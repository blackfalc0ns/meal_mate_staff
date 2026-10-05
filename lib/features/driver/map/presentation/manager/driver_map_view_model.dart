import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import '../../../tracking/domain/entities/driver_live_location_sample.dart';
import '../../../tracking/presentation/manager/driver_live_location_coordinator.dart';
import '../../domain/entities/driver_map_route_entity.dart';
import '../../domain/usecase/get_driver_map_route_usecase.dart';
import 'driver_map_event.dart';
import 'driver_map_state.dart';

@injectable
class DriverMapViewModel extends Cubit<DriverMapState> {
  DriverMapViewModel({
    required GetDriverMapRouteUseCase getDriverMapRouteUseCase,
    required DriverLiveLocationCoordinator liveLocationCoordinator,
    Duration pollingInterval = const Duration(seconds: 30),
    Duration bootstrapWaitLimit = const Duration(seconds: 5),
  })  : _getDriverMapRouteUseCase = getDriverMapRouteUseCase,
        _liveLocationCoordinator = liveLocationCoordinator,
        _pollingInterval = pollingInterval,
        _bootstrapWaitLimit = bootstrapWaitLimit,
        super(const DriverMapState());

  final GetDriverMapRouteUseCase _getDriverMapRouteUseCase;
  final DriverLiveLocationCoordinator _liveLocationCoordinator;
  final Duration _pollingInterval;
  final Duration _bootstrapWaitLimit;

  Timer? _pollTimer;
  StreamSubscription<DriverLiveLocationSample>? _positionsSubscription;
  int _requestGeneration = 0;

  Future<void> doIntent(DriverMapEvent event) {
    switch (event) {
      case DriverMapActivated():
        return _onActivated();
      case DriverMapDeactivated():
        return _onDeactivated();
      case DriverMapAppResumed():
        return _onAppResumed();
      case DriverMapAppPaused():
        return _onAppPaused();
      case DriverMapRefreshRequested():
        return _onRefreshRequested();
      case DriverMapRetryRequested():
        return _onRetryRequested();
      case DriverMapStopSelected(:final stopId):
        return _onStopSelected(stopId);
    }
  }

  Future<void> _onActivated() async {
    if (state.isActive) return;

    _subscribeToPositions();

    emit(
      state.copyWith(
        isActive: true,
        isLoading: state.route == null,
        clearFailure: true,
        liveLocation: _liveLocationCoordinator.latestLocation,
      ),
    );

    // Bootstrap wait for initial GPS fix/send, capped by bootstrapWaitLimit
    try {
      await _liveLocationCoordinator
          .sendCurrentLocationNow()
          .timeout(_bootstrapWaitLimit, onTimeout: () => false);
    } catch (_) {
      // Ignored: continue to route fetch even if initial location send fails
    }

    if (isClosed || !state.isActive) return;

    await _fetchRoute(focusedStopId: null);
    _startPolling();
  }

  Future<void> _onDeactivated() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    _requestGeneration++;
    await _positionsSubscription?.cancel();
    _positionsSubscription = null;

    emit(state.copyWith(isActive: false));
  }

  Future<void> _onAppPaused() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    _requestGeneration++;

    emit(state.copyWith(isForeground: false));
  }

  Future<void> _onAppResumed() async {
    emit(state.copyWith(isForeground: true));

    if (state.isActive) {
      // Treat as fresh return: clear previous visibleNavigation to prevent stale display
      emit(state.copyWith(clearVisibleNavigation: true, isRefreshing: true));
      await _fetchRoute(focusedStopId: state.selectedStopId);
      _startPolling();
    }
  }

  Future<void> _onRefreshRequested() async {
    if (state.isLoading || state.isRefreshing) return;
    emit(state.copyWith(isRefreshing: true));
    await _fetchRoute(focusedStopId: state.selectedStopId);
  }

  Future<void> _onRetryRequested() async {
    if (state.isLoading) return;
    emit(
      state.copyWith(
        isLoading: state.route == null,
        isRefreshing: state.route != null,
        clearFailure: true,
      ),
    );
    await _fetchRoute(focusedStopId: state.selectedStopId);
  }

  Future<void> _onStopSelected(String stopId) async {
    if (stopId == state.selectedStopId) return;

    _requestGeneration++;
    emit(
      state.copyWith(
        selectedStopId: stopId,
        clearVisibleNavigation: true,
        isRefreshing: true,
        clearFailure: true,
      ),
    );

    await _fetchRoute(focusedStopId: stopId);
  }

  Future<void> _fetchRoute({
    String? focusedStopId,
    bool isFallback = false,
  }) async {
    final generation = ++_requestGeneration;

    final result = await _getDriverMapRouteUseCase(
      focusedStopId: focusedStopId,
    );

    if (isClosed || !state.isActive || !state.isForeground || generation != _requestGeneration) {
      return;
    }

    switch (result) {
      case ApiSuccessResult<DriverMapRouteEntity>(:final data):
        final effectiveStopId = focusedStopId ??
            (data.focusedStop.id.isNotEmpty ? data.focusedStop.id : null) ??
            (data.stops.isNotEmpty ? data.stops.first.id : null);

        final navigation = data.navigation;
        final isValidDestination = navigation != null &&
            navigation.destinationStopId != null &&
            navigation.destinationStopId == effectiveStopId;

        emit(
          state.copyWith(
            route: data,
            selectedStopId: effectiveStopId,
            visibleNavigation: isValidDestination ? navigation : null,
            clearVisibleNavigation: !isValidDestination,
            isLoading: false,
            isRefreshing: false,
            isEmpty: false,
            clearFailure: true,
          ),
        );

      case ApiErrorResult<DriverMapRouteEntity>(:final failure):
        if (failure is ServerFailure && failure.code == 'DriverTrip.NotFound') {
          emit(
            state.copyWith(
              clearRoute: true,
              clearVisibleNavigation: true,
              clearSelectedStopId: true,
              clearFailure: true,
              isEmpty: true,
              isLoading: false,
              isRefreshing: false,
            ),
          );
        } else if (failure is ServerFailure &&
            failure.code == 'DriverMap.StopNotFound' &&
            !isFallback) {
          emit(
            state.copyWith(
              clearVisibleNavigation: true,
              isRefreshing: true,
            ),
          );
          await _fetchRoute(focusedStopId: null, isFallback: true);
        } else {
          emit(
            state.copyWith(
              failure: failure,
              clearVisibleNavigation: true,
              isLoading: false,
              isRefreshing: false,
            ),
          );
        }
    }
  }

  void _subscribeToPositions() {
    _positionsSubscription?.cancel();
    _positionsSubscription = _liveLocationCoordinator.positions.listen((sample) {
      if (isClosed || !state.isActive) return;
      emit(state.copyWith(liveLocation: sample));
    });
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollingInterval, (_) {
      if (isClosed ||
          !state.isActive ||
          !state.isForeground ||
          state.isLoading ||
          state.isRefreshing) {
        return;
      }
      _fetchRoute(focusedStopId: state.selectedStopId);
    });
  }

  @override
  Future<void> close() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    _requestGeneration++;
    await _positionsSubscription?.cancel();
    _positionsSubscription = null;
    return super.close();
  }
}
