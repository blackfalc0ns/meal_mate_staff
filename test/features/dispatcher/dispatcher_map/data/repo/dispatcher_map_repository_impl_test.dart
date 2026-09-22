import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/data_source/dispatcher_map_remote_data_source.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_driver_location_event_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/realtime/dispatcher_map_realtime_event_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/models/response/dispatcher_live_monitoring_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/repo/dispatcher_map_repository_impl.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_live_monitoring_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_connection_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_realtime_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/usecase/get_dispatcher_live_monitoring_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/usecase/observe_dispatcher_map_connection_status_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/usecase/observe_dispatcher_map_updates_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/usecase/start_dispatcher_map_updates_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/usecase/stop_dispatcher_map_updates_usecase.dart';

class _FakeRemoteDataSource implements DispatcherMapRemoteDataSource {
  final eventController =
      StreamController<DispatcherMapRealtimeEventDto>.broadcast();
  final connectionController =
      StreamController<DispatcherMapConnectionStatus>.broadcast();

  bool failSnapshot = false;
  int startCalls = 0;
  int stopCalls = 0;
  int disposeCalls = 0;

  @override
  Stream<DispatcherMapRealtimeEventDto> get realtimeEvents =>
      eventController.stream;

  @override
  Stream<DispatcherMapConnectionStatus> get connectionStatuses =>
      connectionController.stream;

  @override
  Future<DispatcherLiveMonitoringResponseDto> getLiveMonitoring({
    String? restaurantId,
    String? status,
  }) async {
    if (failSnapshot) {
      throw DioException(
        requestOptions: RequestOptions(path: '/live-monitoring'),
        type: DioExceptionType.connectionError,
      );
    }
    return const DispatcherLiveMonitoringResponseDto(
      kpis: DispatcherMapKpiResponseDto(activeDriversCount: 12),
      drivers: [
        DispatcherMapDriverResponseDto(id: 'd1', name: 'Sami', boxId: 'BOX-1'),
      ],
    );
  }

  @override
  Future<void> startRealtime() async {
    startCalls++;
  }

  @override
  Future<void> stopRealtime() async {
    stopCalls++;
  }

  @override
  Future<void> disposeRealtime() async {
    disposeCalls++;
  }
}

void main() {
  late _FakeRemoteDataSource remoteDataSource;
  late DispatcherMapRepositoryImpl repository;

  setUp(() {
    remoteDataSource = _FakeRemoteDataSource();
    repository = DispatcherMapRepositoryImpl(remoteDataSource);
  });

  tearDown(() {
    remoteDataSource.eventController.close();
    remoteDataSource.connectionController.close();
  });

  group('DispatcherMapRepositoryImpl', () {
    test('getLiveMonitoring returns success when remote call succeeds', () async {
      final result = await repository.getLiveMonitoring();
      expect(result, isA<ApiSuccessResult<DispatcherLiveMonitoringEntity>>());
      final entity = (result as ApiSuccessResult<DispatcherLiveMonitoringEntity>).data;
      expect(entity.kpi.activeDriversCount, 12);
      expect(entity.drivers, hasLength(1));
      expect(entity.drivers.first.id, 'd1');
    });

    test('getLiveMonitoring returns failure when remote call throws DioException', () async {
      remoteDataSource.failSnapshot = true;
      final result = await repository.getLiveMonitoring();
      expect(result, isA<ApiErrorResult<DispatcherLiveMonitoringEntity>>());
    });

    test('realtimeEvents maps incoming DTOs to domain events', () async {
      final events = <DispatcherMapRealtimeEvent>[];
      final sub = repository.realtimeEvents.listen(events.add);

      remoteDataSource.eventController.add(
        const LocationUpdatedRealtimeDto(
          DispatcherDriverLocationEventDto(
            driverId: 'drv-1',
            latitude: 29.3,
            longitude: 47.9,
          ),
        ),
      );

      await pumpEventQueue();

      expect(events, hasLength(1));
      expect(events.first, isA<DriverLocationUpdated>());
      final locEvent = events.first as DriverLocationUpdated;
      expect(locEvent.driverId, 'drv-1');
      expect(locEvent.latitude, 29.3);

      await sub.cancel();
    });

    test('startRealtimeUpdates and stopRealtimeUpdates delegate to remote data source', () async {
      await repository.startRealtimeUpdates();
      expect(remoteDataSource.startCalls, 1);

      await repository.stopRealtimeUpdates();
      expect(remoteDataSource.stopCalls, 1);
    });
  });

  group('UseCases', () {
    test('all use cases delegate correctly to repository', () async {
      final getMonitoringUseCase = GetDispatcherLiveMonitoringUseCase(repository);
      final observeUpdatesUseCase = ObserveDispatcherMapUpdatesUseCase(repository);
      final observeStatusUseCase = ObserveDispatcherMapConnectionStatusUseCase(repository);
      final startUpdatesUseCase = StartDispatcherMapUpdatesUseCase(repository);
      final stopUpdatesUseCase = StopDispatcherMapUpdatesUseCase(repository);

      final snapshotResult = await getMonitoringUseCase();
      expect(snapshotResult, isA<ApiSuccessResult<DispatcherLiveMonitoringEntity>>());

      expect(observeUpdatesUseCase(), isA<Stream<DispatcherMapRealtimeEvent>>());
      expect(observeStatusUseCase(), isA<Stream<DispatcherMapConnectionStatus>>());

      await startUpdatesUseCase();
      expect(remoteDataSource.startCalls, 1);

      await stopUpdatesUseCase();
      expect(remoteDataSource.stopCalls, 1);
    });
  });
}
