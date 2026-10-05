// ignore_for_file: prefer_initializing_formals
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../../../orders/data/realtime/driver_orders_realtime_client.dart';
import '../../../orders/domain/entities/driver_orders_realtime_event.dart';
import '../../../tracking/presentation/manager/driver_live_location_coordinator.dart';
import '../../domain/usecase/get_driver_home_usecase.dart';
import 'driver_home_event.dart';
import 'driver_home_state.dart';

@injectable
class DriverHomeViewModel extends Cubit<DriverHomeState> {
  DriverHomeViewModel({
    required GetDriverHomeUseCase getDriverHomeUseCase,
    DriverOrdersRealtimeClient? realtimeClient,
    DriverLiveLocationCoordinator? locationCoordinator,
  }) : _getDriverHomeUseCase = getDriverHomeUseCase,
       _realtimeClient = realtimeClient,
       _locationCoordinator = locationCoordinator,
       super(
         DriverHomeState(
           isRealtimeConnected: realtimeClient?.isConnected ?? false,
         ),
       ) {
    _initRealtimeListeners();
  }

  final GetDriverHomeUseCase _getDriverHomeUseCase;
  final DriverOrdersRealtimeClient? _realtimeClient;
  final DriverLiveLocationCoordinator? _locationCoordinator;

  StreamSubscription<DriverOrdersRealtimeEvent>? _eventsSubscription;
  StreamSubscription<bool>? _connectionStatusSubscription;

  bool _inFlight = false;
  bool _hasPendingReload = false;
  bool _wasConnected = false;
  Future<void> doIntent(DriverHomeEvent event) {
    switch (event) {
      case DriverHomeLoadStarted():
        return _onLoadStarted();
      case DriverHomeRefreshRequested():
        return _onRefreshRequested();
      case DriverHomeRetryRequested():
        return _onRetryRequested();
      case DriverHomeLifecycleResumed():
        return _onLifecycleResumed();
      case DriverHomeStatusUpdatedReceived():
        return _onStatusUpdatedReceived();
      case DriverHomeSignalRReconnected():
        return _onSignalRReconnected();
    }
  }

  void _initRealtimeListeners() {
    if (_realtimeClient == null) return;

    _wasConnected = _realtimeClient.isConnected;
    if (!_wasConnected) {
      unawaited(_realtimeClient.start());
    }

    _eventsSubscription = _realtimeClient.events.listen((event) {
      if (event is DriverStatusUpdatedEvent) {
        unawaited(doIntent(const DriverHomeStatusUpdatedReceived()));
      }
    });

    _connectionStatusSubscription = _realtimeClient.connectionStatus.listen((
      connected,
    ) {
      final was = _wasConnected;
      _wasConnected = connected;
      emit(state.copyWith(isRealtimeConnected: connected));

      // On a false-to-true SignalR connection transition, dispatch reconnect reload
      if (!was && connected) {
        unawaited(doIntent(const DriverHomeSignalRReconnected()));
      }
    });
  }

  Future<void> _onLoadStarted() => _fetchHome(isRefresh: false);

  Future<void> _onRefreshRequested() => _fetchHome(isRefresh: true);

  Future<void> _onRetryRequested() => _fetchHome(isRefresh: state.hasData);

  Future<void> _onLifecycleResumed() {
    if (_realtimeClient != null && !_realtimeClient.isConnected) {
      unawaited(_realtimeClient.start());
    }
    return _fetchHome(isRefresh: state.hasData);
  }

  Future<void> _onStatusUpdatedReceived() =>
      _fetchHome(isRefresh: state.hasData);

  Future<void> _onSignalRReconnected() => _fetchHome(isRefresh: state.hasData);

  Future<void> _fetchHome({required bool isRefresh}) async {
    // Coalesce concurrent requests: mark pending and avoid dispatching parallel requests
    if (_inFlight) {
      _hasPendingReload = true;
      return;
    }
    _inFlight = true;

    try {
      if (state.hasData || isRefresh) {
        emit(
          state.copyWith(
            isRefreshing: true,
            clearFailure: true,
            clearErrorMessage: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            isLoading: true,
            clearFailure: true,
            clearErrorMessage: true,
          ),
        );
      }

      final result = await _getDriverHomeUseCase();

      switch (result) {
        case ApiSuccessResult(:final data):
          emit(
            state.copyWith(
              isLoading: false,
              isRefreshing: false,
              home: data,
              clearFailure: true,
              clearErrorMessage: true,
            ),
          );
          // Restore tracking for deliveries already assigned before app startup.
          // Home exposes the current task, not the total active box count.
          final coordinator = _locationCoordinator;
          if (coordinator != null) {
            await coordinator.setActiveBoxesCount(
              data.hasActiveDelivery
                  ? math.max(1, coordinator.activeBoxCount)
                  : 0,
            );
          }
        case ApiErrorResult(:final failure):
          emit(
            state.copyWith(
              isLoading: false,
              isRefreshing: false,
              failure: failure,
              errorMessage: failure.errorMessage,
              // Existing home data is retained when refresh fails
            ),
          );
      }
    } finally {
      _inFlight = false;
      if (_hasPendingReload) {
        _hasPendingReload = false;
        // Execute at most one follow-up load after current request completes
        unawaited(_fetchHome(isRefresh: state.hasData));
      }
    }
  }

  @override
  Future<void> close() async {
    await _eventsSubscription?.cancel();
    await _connectionStatusSubscription?.cancel();
    return super.close();
  }
}
