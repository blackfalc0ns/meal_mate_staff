import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_live_monitoring_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_connection_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_driver_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_kpi_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_realtime_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/repo/dispatcher_map_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/usecase/get_dispatcher_live_monitoring_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/usecase/observe_dispatcher_map_connection_status_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/usecase/observe_dispatcher_map_updates_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/usecase/start_dispatcher_map_updates_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/usecase/stop_dispatcher_map_updates_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/presentation/manager/dispatcher_map_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/presentation/manager/dispatcher_map_view_model.dart';

class _MockMapRepository implements DispatcherMapRepository {
  final eventController = StreamController<DispatcherMapRealtimeEvent>.broadcast();
  final statusController = StreamController<DispatcherMapConnectionStatus>.broadcast();

  int getLiveCalls = 0;
  int connectCalls = 0;
  int disconnectCalls = 0;
  bool failSnapshot = false;

  DispatcherLiveMonitoringEntity snapshot = DispatcherLiveMonitoringEntity(
    kpi: const DispatcherMapKpiEntity(
      activeDriversCount: 10,
      inDeliveryCount: 5,
      pausedCount: 3,
      issuesCount: 2,
    ),
    drivers: [
      DispatcherMapDriverEntity(
        id: 'drv-1',
        name: 'Ahmed',
        boxId: 'B-1',
        latitude: 29.35,
        longitude: 47.95,
        status: DispatcherMapDriverStatus.inDelivery,
        lastLocationTimestamp: DateTime.utc(2026, 9, 22, 10, 0),
        lastStatusTimestamp: DateTime.utc(2026, 9, 22, 10, 0),
        locationZone: 'Zone A',
        remainingDistanceKm: 3.0,
      ),
      const DispatcherMapDriverEntity(
        id: 'drv-2',
        name: 'Omar',
        boxId: 'B-2',
        latitude: 29.38,
        longitude: 47.98,
        status: DispatcherMapDriverStatus.paused,
      ),
    ],
  );

  @override
  Future<ApiResult<DispatcherLiveMonitoringEntity>> getLiveMonitoring({
    String? restaurantId,
    String? status,
  }) async {
    getLiveCalls++;
    if (failSnapshot) {
      return ApiErrorResult(
        failure: ServerFailure.fromDioError(
          dioException: DioException(
            requestOptions: RequestOptions(path: '/live-monitoring'),
            type: DioExceptionType.connectionError,
          ),
        ),
      );
    }
    return ApiSuccessResult(data: snapshot);
  }

  @override
  Stream<DispatcherMapRealtimeEvent> get realtimeEvents => eventController.stream;

  @override
  Stream<DispatcherMapConnectionStatus> get connectionStatuses => statusController.stream;

  @override
  DispatcherMapConnectionStatus get currentConnectionStatus => DispatcherMapConnectionStatus.connected;

  @override
  Future<void> startRealtimeUpdates() async {
    connectCalls++;
  }

  @override
  Future<void> stopRealtimeUpdates() async {
    disconnectCalls++;
  }

  @override
  Future<void> disposeRealtime() async {
    disconnectCalls++;
  }
}

void main() {
  late _MockMapRepository repository;
  late DispatcherMapViewModel viewModel;

  setUp(() {
    repository = _MockMapRepository();
    viewModel = DispatcherMapViewModel(
      getLiveMonitoringUseCase: GetDispatcherLiveMonitoringUseCase(repository),
      observeUpdatesUseCase: ObserveDispatcherMapUpdatesUseCase(repository),
      observeConnectionStatusUseCase: ObserveDispatcherMapConnectionStatusUseCase(repository),
      startUpdatesUseCase: StartDispatcherMapUpdatesUseCase(repository),
      stopUpdatesUseCase: StopDispatcherMapUpdatesUseCase(repository),
    );
  });

  tearDown(() async {
    await viewModel.close();
    await repository.eventController.close();
    await repository.statusController.close();
  });

  group('Initial Load & Selection', () {
    test('successful initial load populates data and starts hub', () async {
      await viewModel.doIntent(const LoadDispatcherMapEvent());

      expect(viewModel.state.hasData, isTrue);
      expect(viewModel.state.isInitialLoading, isFalse);
      expect(viewModel.state.hasLoadedOnce, isTrue);
      expect(viewModel.state.drivers, hasLength(2));
      expect(viewModel.state.selectedDriverId, 'drv-1');
      expect(repository.connectCalls, 1);
    });

    test('failure on initial load emits failure without crashing', () async {
      repository.failSnapshot = true;
      await viewModel.doIntent(const LoadDispatcherMapEvent());

      expect(viewModel.state.hasData, isFalse);
      expect(viewModel.state.isInitialLoading, isFalse);
      expect(viewModel.state.failure, isNotNull);
    });

    test('selecting driver updates selectedDriverId', () async {
      await viewModel.doIntent(const LoadDispatcherMapEvent());
      expect(viewModel.state.selectedDriverId, 'drv-1');

      viewModel.doIntent(const SelectDriverDispatcherMapEvent('drv-2'));
      expect(viewModel.state.selectedDriverId, 'drv-2');
      expect(viewModel.state.selectedDriver?.name, 'Omar');
    });
  });

  group('Realtime Updates & Timestamp Ordering', () {
    setUp(() async {
      await viewModel.doIntent(const LoadDispatcherMapEvent());
    });

    test('location update updates coordinates and preserves non-null fields after flush', () async {
      final updateEvent = DriverLocationUpdated(
        driverId: 'drv-1',
        latitude: 29.40,
        longitude: 48.00,
        speed: 60.0,
        timestamp: DateTime.utc(2026, 9, 22, 10, 5),
        locationZone: null, // Should retain 'Zone A'
        remainingDistanceKm: 1.5,
      );

      viewModel.doIntent(RealtimeEventReceived(updateEvent));
      // Wait for 100ms throttle timer to flush
      await Future<void>.delayed(const Duration(milliseconds: 150));

      final driver = viewModel.state.drivers.firstWhere((d) => d.id == 'drv-1');
      expect(driver.latitude, 29.40);
      expect(driver.longitude, 48.00);
      expect(driver.speed, 60.0);
      expect(driver.locationZone, 'Zone A'); // Retained
      expect(driver.remainingDistanceKm, 1.5);
    });

    test('location update rejects older timestamp', () async {
      final olderEvent = DriverLocationUpdated(
        driverId: 'drv-1',
        latitude: 29.99,
        longitude: 48.99,
        timestamp: DateTime.utc(2026, 9, 22, 9, 0), // Older than 10:00
      );

      viewModel.doIntent(RealtimeEventReceived(olderEvent));
      await Future<void>.delayed(const Duration(milliseconds: 150));

      final driver = viewModel.state.drivers.firstWhere((d) => d.id == 'drv-1');
      expect(driver.latitude, 29.35); // Not updated!
    });

    test('location update rejects invalid coordinates', () async {
      final invalidEvent = DriverLocationUpdated(
        driverId: 'drv-1',
        latitude: 0.0,
        longitude: 0.0,
        timestamp: DateTime.utc(2026, 9, 22, 10, 5),
      );

      viewModel.doIntent(RealtimeEventReceived(invalidEvent));
      await Future<void>.delayed(const Duration(milliseconds: 150));

      final driver = viewModel.state.drivers.firstWhere((d) => d.id == 'drv-1');
      expect(driver.latitude, 29.35); // Not updated!
    });

    test('status update updates status, issue, and KPI', () async {
      final statusEvent = DriverStatusUpdated(
        driverId: 'drv-1',
        status: DispatcherMapDriverStatus.hasIssue,
        statusText: 'عطل بالمحرك',
        hasIssue: true,
        issueDescription: 'Engine fault',
        timestamp: DateTime.utc(2026, 9, 22, 10, 6),
        kpis: const DispatcherMapKpiEntity(
          activeDriversCount: 10,
          inDeliveryCount: 4,
          pausedCount: 3,
          issuesCount: 3,
        ),
      );

      viewModel.doIntent(RealtimeEventReceived(statusEvent));

      final driver = viewModel.state.drivers.firstWhere((d) => d.id == 'drv-1');
      expect(driver.status, DispatcherMapDriverStatus.hasIssue);
      expect(driver.hasIssue, isTrue);
      expect(driver.issueDescription, 'Engine fault');
      expect(viewModel.state.kpi?.issuesCount, 3);
    });

    test('issue update updates issue info and triggers reconciliation', () async {
      final initialCalls = repository.getLiveCalls;
      final issueEvent = DriverIssueUpdated(
        driverId: 'drv-1',
        hasIssue: true,
        issueDescription: 'Issue occurred',
        timestamp: DateTime.utc(2026, 9, 22, 10, 7),
      );

      viewModel.doIntent(RealtimeEventReceived(issueEvent));
      await pumpEventQueue();

      expect(repository.getLiveCalls, greaterThan(initialCalls));
    });

    test('box assigned event triggers reconciliation', () async {
      final initialCalls = repository.getLiveCalls;
      const boxEvent = DriverBoxAssigned(boxId: 'B-3', driverId: 'drv-2');

      viewModel.doIntent(const RealtimeEventReceived(boxEvent));
      await pumpEventQueue();

      expect(repository.getLiveCalls, greaterThan(initialCalls));
    });
  });

  group('Lifecycle and Reconnect', () {
    test('tab deactivation stops hub; activation reconciles and resumes hub', () async {
      await viewModel.doIntent(const LoadDispatcherMapEvent());
      expect(repository.connectCalls, 1);

      await viewModel.doIntent(const DispatcherMapTabDeactivatedEvent());
      expect(repository.disconnectCalls, 1);
      expect(viewModel.state.isSynchronized, isFalse);

      final callsBeforeResume = repository.getLiveCalls;
      await viewModel.doIntent(const DispatcherMapTabActivatedEvent());
      expect(repository.getLiveCalls, greaterThan(callsBeforeResume));
      expect(repository.connectCalls, 2);
    });

    test('reconnection triggers REST reconciliation', () async {
      await viewModel.doIntent(const LoadDispatcherMapEvent());

      // Simulate reconnecting state
      await viewModel.doIntent(
        const RealtimeConnectionStatusReceived(DispatcherMapConnectionStatus.reconnecting),
      );
      expect(viewModel.state.connectionStatus, DispatcherMapConnectionStatus.reconnecting);

      final callsBefore = repository.getLiveCalls;

      // Simulate reconnected state
      await viewModel.doIntent(
        const RealtimeConnectionStatusReceived(DispatcherMapConnectionStatus.connected),
      );
      await pumpEventQueue();

      expect(repository.getLiveCalls, greaterThan(callsBefore));
    });

    test('RetryDispatcherMapRealtimeEvent calls startUpdatesUseCase even when subscriptions exist', () async {
      await viewModel.doIntent(const LoadDispatcherMapEvent());
      expect(repository.connectCalls, 1);

      await viewModel.doIntent(const RetryDispatcherMapRealtimeEvent());
      expect(repository.connectCalls, 2);
    });
  });
}
