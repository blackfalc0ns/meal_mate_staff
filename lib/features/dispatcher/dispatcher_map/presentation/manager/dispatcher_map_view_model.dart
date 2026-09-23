import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/api_results.dart';
import '../../domain/entities/dispatcher_live_monitoring_entity.dart';
import '../../domain/entities/dispatcher_map_connection_status.dart';
import '../../domain/entities/dispatcher_map_driver_entity.dart';
import '../../domain/entities/dispatcher_map_realtime_event.dart';
import '../../domain/usecase/get_dispatcher_live_monitoring_usecase.dart';
import '../../domain/usecase/observe_dispatcher_map_updates_usecase.dart';
import '../../domain/usecase/start_dispatcher_map_updates_usecase.dart';
import '../../domain/usecase/stop_dispatcher_map_updates_usecase.dart';
import '../../domain/usecase/observe_dispatcher_map_connection_status_usecase.dart';
import 'dispatcher_map_event.dart';
import 'dispatcher_map_state.dart';

class DispatcherMapViewModel extends Cubit<DispatcherMapState> {
  DispatcherMapViewModel({
    required this.getLiveMonitoringUseCase,
    required this.observeUpdatesUseCase,
    required this.observeConnectionStatusUseCase,
    required this.startUpdatesUseCase,
    required this.stopUpdatesUseCase,
  }) : super(const DispatcherMapState(isInitialLoading: true));

  final GetDispatcherLiveMonitoringUseCase getLiveMonitoringUseCase;
  final ObserveDispatcherMapUpdatesUseCase observeUpdatesUseCase;
  final ObserveDispatcherMapConnectionStatusUseCase
  observeConnectionStatusUseCase;
  final StartDispatcherMapUpdatesUseCase startUpdatesUseCase;
  final StopDispatcherMapUpdatesUseCase stopUpdatesUseCase;

  int _requestGeneration = 0;
  bool _isActive = true;
  bool _isReconciling = false;
  bool _reconcileAgain = false;

  final Map<String, DateTime> _lastLocationAtByDriver = {};
  final Map<String, DateTime> _lastStatusAtByDriver = {};
  final Map<String, DispatcherMapDriverEntity> _driversMap = {};

  // Rapid location update throttle (flush at most once per 100ms)
  final Map<String, DriverLocationUpdated> _pendingLocationUpdates = {};
  Timer? _locationFlushTimer;

  StreamSubscription<DispatcherMapRealtimeEvent>? _eventsSubscription;
  StreamSubscription<DispatcherMapConnectionStatus>? _statusSubscription;

  Future<void> doIntent(DispatcherMapEvent event) async {
    switch (event) {
      case LoadDispatcherMapEvent(:final restaurantId, :final status):
        await _loadInitial(restaurantId: restaurantId, status: status);
      case RefreshDispatcherMapEvent():
        await _refresh();
      case RetryDispatcherMapEvent():
        await _retry();
      case RetryDispatcherMapRealtimeEvent():
        _startRealtime(force: true);
      case SelectDriverDispatcherMapEvent(:final driverId):
        _selectDriver(driverId);
      case TabActiveStateChangedEvent(:final isActive):
        await _handleTabActiveChanged(isActive);
      case DispatcherMapTabActivatedEvent():
        await _handleTabActiveChanged(true);
      case DispatcherMapTabDeactivatedEvent():
        await _handleTabActiveChanged(false);
      case AppLifecycleStateChangedEvent(:final isResumed):
        await _handleAppLifecycleChanged(isResumed);
      case DispatcherMapAppResumedEvent():
        await _handleAppLifecycleChanged(true);
      case DispatcherMapAppPausedEvent():
        await _handleAppLifecycleChanged(false);
      case RealtimeEventReceived(:final event):
        _handleRealtimeEvent(event);
      case RealtimeConnectionStatusReceived(:final status):
        await _handleConnectionStatus(status);
    }
  }

  Future<void> _loadInitial({String? restaurantId, String? status}) async {
    final generation = ++_requestGeneration;
    emit(
      state.copyWith(
        isInitialLoading: state.snapshot == null,
        isRefreshLoading: state.snapshot != null,
        failure: null,
      ),
    );

    final result = await getLiveMonitoringUseCase(
      restaurantId: restaurantId,
      status: status,
    );

    if (isClosed || generation != _requestGeneration) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        _populateFromSnapshot(data);
        final selectedId = _resolveSelection(data, state.selectedDriverId);

        emit(
          state.copyWith(
            snapshot: data,
            selectedDriverId: selectedId,
            isInitialLoading: false,
            isRefreshLoading: false,
            failure: null,
            hasLoadedOnce: true,
            isSynchronized: true,
            lastSyncTime: DateTime.now(),
          ),
        );

        if (_isActive) {
          _startRealtime();
        }
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            isInitialLoading: false,
            isRefreshLoading: false,
            failure: failure,
          ),
        );
    }
  }

  Future<void> _refresh() async {
    final generation = ++_requestGeneration;
    emit(state.copyWith(isRefreshLoading: true, failure: null));

    final result = await getLiveMonitoringUseCase();
    if (isClosed || generation != _requestGeneration) return;

    switch (result) {
      case ApiSuccessResult(:final data):
        _populateFromSnapshot(data);
        final selectedId = _resolveSelection(data, state.selectedDriverId);

        emit(
          state.copyWith(
            snapshot: data,
            selectedDriverId: selectedId,
            isRefreshLoading: false,
            failure: null,
            isSynchronized: true,
            lastSyncTime: DateTime.now(),
          ),
        );
      case ApiErrorResult(:final failure):
        emit(state.copyWith(isRefreshLoading: false, failure: failure));
    }
  }

  Future<void> _retry() async {
    if (state.hasLoadedOnce) {
      await _refresh();
    } else {
      await _loadInitial();
    }
  }

  void _selectDriver(String driverId) {
    if (state.selectedDriverId == driverId) return;
    emit(state.copyWith(selectedDriverId: driverId));
  }

  String? _resolveSelection(
    DispatcherLiveMonitoringEntity snapshot,
    String? currentSelectedId,
  ) {
    if (snapshot.drivers.isEmpty) return null;
    if (currentSelectedId != null &&
        snapshot.drivers.any((d) => d.id == currentSelectedId)) {
      return currentSelectedId;
    }
    final firstValid = snapshot.drivers.where((d) => d.hasValidCoordinates);
    if (firstValid.isNotEmpty) return firstValid.first.id;
    return snapshot.drivers.first.id;
  }

  void _populateFromSnapshot(DispatcherLiveMonitoringEntity snapshot) {
    _driversMap.clear();
    for (final driver in snapshot.drivers) {
      _driversMap[driver.id] = driver;
      if (driver.lastLocationTimestamp != null) {
        _lastLocationAtByDriver[driver.id] = driver.lastLocationTimestamp!;
      }
      if (driver.lastStatusTimestamp != null) {
        _lastStatusAtByDriver[driver.id] = driver.lastStatusTimestamp!;
      }
    }
  }

  void _startRealtime({bool force = false}) {
    if (!force && _eventsSubscription != null && _statusSubscription != null) {
      return;
    }

    _eventsSubscription ??= observeUpdatesUseCase().listen((event) {
      doIntent(RealtimeEventReceived(event));
    });

    _statusSubscription ??= observeConnectionStatusUseCase().listen((status) {
      doIntent(RealtimeConnectionStatusReceived(status));
    });

    startUpdatesUseCase().ignore();
  }

  Future<void> _stopRealtime() async {
    await _eventsSubscription?.cancel();
    _eventsSubscription = null;
    await _statusSubscription?.cancel();
    _statusSubscription = null;

    _locationFlushTimer?.cancel();
    _flushPendingLocations();

    try {
      await stopUpdatesUseCase();
    } catch (_) {}
  }

  void _handleRealtimeEvent(DispatcherMapRealtimeEvent event) {
    switch (event) {
      case DriverLocationUpdated():
        _queueLocationUpdate(event);
      case DriverStatusUpdated():
        _applyStatusUpdate(event);
      case DriverIssueUpdated():
        _applyIssueUpdate(event);
      case DriverBoxAssigned():
        _applyBoxAssigned(event);
    }
  }

  void _queueLocationUpdate(DriverLocationUpdated event) {
    // Validate coordinates
    if (event.latitude < -90 ||
        event.latitude > 90 ||
        event.longitude < -180 ||
        event.longitude > 180 ||
        (event.latitude == 0.0 && event.longitude == 0.0)) {
      return;
    }

    // Timestamp check: strictly older timestamp is ignored
    final lastTime = _lastLocationAtByDriver[event.driverId];
    if (lastTime != null && event.timestamp.isBefore(lastTime)) {
      return;
    }
    _lastLocationAtByDriver[event.driverId] = event.timestamp;

    // Unknown driver: ignore event and schedule reconciliation
    if (!_driversMap.containsKey(event.driverId)) {
      _triggerCoalescedReconciliation();
      return;
    }

    // Rapid location update policy: maintain newest per driver, flush at most once per 100ms
    _pendingLocationUpdates[event.driverId] = event;

    if (_locationFlushTimer == null || !_locationFlushTimer!.isActive) {
      _locationFlushTimer = Timer(
        const Duration(milliseconds: 100),
        _flushPendingLocations,
      );
    }
  }

  void _flushPendingLocations() {
    if (_pendingLocationUpdates.isEmpty) return;

    for (final event in _pendingLocationUpdates.values) {
      final existing = _driversMap[event.driverId];
      if (existing == null) continue;

      final updated = existing.copyWith(
        latitude: event.latitude,
        longitude: event.longitude,
        heading: event.heading ?? existing.heading,
        speed: event.speed ?? existing.speed,
        lastLocationTimestamp: event.timestamp,
        locationZone: event.locationZone ?? existing.locationZone,
        remainingDistanceKm:
            event.remainingDistanceKm ?? existing.remainingDistanceKm,
        remainingDistanceText:
            event.remainingDistanceText ?? existing.remainingDistanceText,
      );

      _driversMap[event.driverId] = updated;
    }

    _pendingLocationUpdates.clear();

    final currentSnapshot = state.snapshot;
    if (currentSnapshot != null) {
      emit(
        state.copyWith(
          snapshot: DispatcherLiveMonitoringEntity(
            kpi: currentSnapshot.kpi,
            drivers: _driversMap.values.toList(),
          ),
        ),
      );
    }
  }

  void _applyStatusUpdate(DriverStatusUpdated event) {
    final lastTime = _lastStatusAtByDriver[event.driverId];
    if (lastTime != null && event.timestamp.isBefore(lastTime)) {
      return;
    }
    _lastStatusAtByDriver[event.driverId] = event.timestamp;

    final existing = _driversMap[event.driverId];
    if (existing == null) {
      _triggerCoalescedReconciliation();
      return;
    }

    final updated = existing.copyWith(
      status: event.status,
      statusText: event.statusText ?? existing.statusText,
      statusColor: event.statusColor ?? existing.statusColor,
      hasIssue: event.hasIssue ?? existing.hasIssue,
      issueDescription: event.issueDescription ?? existing.issueDescription,
      lastStatusTimestamp: event.timestamp,
    );

    _driversMap[event.driverId] = updated;

    final currentSnapshot = state.snapshot;
    if (currentSnapshot != null) {
      emit(
        state.copyWith(
          snapshot: DispatcherLiveMonitoringEntity(
            kpi: event.kpis ?? currentSnapshot.kpi,
            drivers: _driversMap.values.toList(),
          ),
        ),
      );
    }
  }

  void _applyIssueUpdate(DriverIssueUpdated event) {
    final existing = _driversMap[event.driverId];
    if (existing != null) {
      final updated = existing.copyWith(
        hasIssue: event.hasIssue,
        issueDescription: event.issueDescription ?? existing.issueDescription,
      );
      _driversMap[event.driverId] = updated;

      final currentSnapshot = state.snapshot;
      if (currentSnapshot != null) {
        emit(
          state.copyWith(
            snapshot: DispatcherLiveMonitoringEntity(
              kpi: currentSnapshot.kpi,
              drivers: _driversMap.values.toList(),
            ),
          ),
        );
      }
    }

    _triggerCoalescedReconciliation();
  }

  void _applyBoxAssigned(DriverBoxAssigned event) {
    _triggerCoalescedReconciliation();
  }

  Future<void> _handleConnectionStatus(
    DispatcherMapConnectionStatus status,
  ) async {
    final wasReconnecting =
        state.connectionStatus == DispatcherMapConnectionStatus.reconnecting;
    emit(state.copyWith(connectionStatus: status));

    if (wasReconnecting && status == DispatcherMapConnectionStatus.connected) {
      await _triggerCoalescedReconciliation();
    }
  }

  Future<void> _triggerCoalescedReconciliation() async {
    if (_isReconciling) {
      _reconcileAgain = true;
      return;
    }

    _isReconciling = true;
    emit(state.copyWith(isReconciling: true));

    try {
      final result = await getLiveMonitoringUseCase();
      if (result is ApiSuccessResult<DispatcherLiveMonitoringEntity>) {
        _reconcileSnapshot(result.data);
        final selectedId = _resolveSelection(
          result.data,
          state.selectedDriverId,
        );

        emit(
          state.copyWith(
            snapshot: result.data,
            selectedDriverId: selectedId,
            isReconciling: false,
            isSynchronized: true,
            lastSyncTime: DateTime.now(),
          ),
        );
      } else {
        emit(state.copyWith(isReconciling: false));
      }
    } catch (_) {
      emit(state.copyWith(isReconciling: false));
    } finally {
      _isReconciling = false;
      if (_reconcileAgain) {
        _reconcileAgain = false;
        await _triggerCoalescedReconciliation();
      }
    }
  }

  void _reconcileSnapshot(DispatcherLiveMonitoringEntity newSnapshot) {
    for (final driver in newSnapshot.drivers) {
      _driversMap[driver.id] = driver;
      if (driver.lastLocationTimestamp != null) {
        final current = _lastLocationAtByDriver[driver.id];
        if (current == null || driver.lastLocationTimestamp!.isAfter(current)) {
          _lastLocationAtByDriver[driver.id] = driver.lastLocationTimestamp!;
        }
      }
      if (driver.lastStatusTimestamp != null) {
        final current = _lastStatusAtByDriver[driver.id];
        if (current == null || driver.lastStatusTimestamp!.isAfter(current)) {
          _lastStatusAtByDriver[driver.id] = driver.lastStatusTimestamp!;
        }
      }
    }
  }

  Future<void> _handleTabActiveChanged(bool isActive) async {
    if (_isActive == isActive) return;
    _isActive = isActive;

    if (!isActive) {
      await _stopRealtime();
      emit(state.copyWith(isSynchronized: false));
    } else {
      if (!state.hasLoadedOnce) {
        await _loadInitial();
      } else {
        await _triggerCoalescedReconciliation();
        _startRealtime(force: true);
      }
    }
  }

  Future<void> _handleAppLifecycleChanged(bool isResumed) async {
    if (!isResumed) {
      await _stopRealtime();
      emit(state.copyWith(isSynchronized: false));
    } else if (_isActive) {
      await _triggerCoalescedReconciliation();
      _startRealtime(force: true);
    }
  }

  @override
  Future<void> close() async {
    await _stopRealtime();
    return super.close();
  }
}
