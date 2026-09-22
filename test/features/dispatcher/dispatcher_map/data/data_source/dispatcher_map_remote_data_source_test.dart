import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_services.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/data_source/dispatcher_map_remote_data_source_impl.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_driver_location_event_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/realtime/dispatcher_map_realtime_client.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/realtime/dispatcher_map_realtime_event_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/models/response/dispatcher_live_monitoring_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_connection_status.dart';

class _FakeApiServices implements ApiServices {
  String? lastRestaurantId;
  String? lastStatus;
  DispatcherLiveMonitoringResponseDto response =
      const DispatcherLiveMonitoringResponseDto();

  @override
  Future<DispatcherLiveMonitoringResponseDto> getDispatcherLiveMonitoring({
    String? restaurantId,
    String? status,
  }) async {
    lastRestaurantId = restaurantId;
    lastStatus = status;
    return response;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeRealtimeClient implements DispatcherMapRealtimeClient {
  final eventController =
      StreamController<DispatcherMapRealtimeEventDto>.broadcast();
  final connectionController =
      StreamController<DispatcherMapConnectionStatus>.broadcast();

  bool isConnected = false;
  int connectCalls = 0;
  int disconnectCalls = 0;

  @override
  Stream<DispatcherMapRealtimeEventDto> get events => eventController.stream;

  @override
  Stream<DispatcherMapConnectionStatus> get connectionStatuses =>
      connectionController.stream;

  @override
  Future<void> connect() async {
    connectCalls++;
    isConnected = true;
    connectionController.add(DispatcherMapConnectionStatus.connected);
  }

  @override
  Future<void> disconnect() async {
    disconnectCalls++;
    isConnected = false;
    connectionController.add(DispatcherMapConnectionStatus.disconnected);
  }

  @override
  Future<void> dispose() async {
    await disconnect();
    await eventController.close();
    await connectionController.close();
  }
}

void main() {
  late _FakeApiServices apiServices;
  late _FakeRealtimeClient realtimeClient;
  late DispatcherMapRemoteDataSourceImpl dataSource;

  setUp(() {
    apiServices = _FakeApiServices();
    realtimeClient = _FakeRealtimeClient();
    dataSource = DispatcherMapRemoteDataSourceImpl(apiServices, realtimeClient);
  });

  tearDown(() async {
    await realtimeClient.dispose();
  });

  test('getLiveMonitoring forwards arguments to ApiServices', () async {
    final result = await dataSource.getLiveMonitoring(
      restaurantId: 'rest-1',
      status: 'InDelivery',
    );

    expect(apiServices.lastRestaurantId, 'rest-1');
    expect(apiServices.lastStatus, 'InDelivery');
    expect(result, isA<DispatcherLiveMonitoringResponseDto>());
  });

  test('startRealtime and stopRealtime delegate to realtime client', () async {
    expect(realtimeClient.connectCalls, 0);
    await dataSource.startRealtime();
    expect(realtimeClient.connectCalls, 1);

    expect(realtimeClient.disconnectCalls, 0);
    await dataSource.stopRealtime();
    expect(realtimeClient.disconnectCalls, 1);
  });

  test('realtimeEvents and connectionStatuses streams forward correctly', () async {
    final events = <DispatcherMapRealtimeEventDto>[];
    final sub = dataSource.realtimeEvents.listen(events.add);

    final eventDto = const LocationUpdatedRealtimeDto(
      DispatcherDriverLocationEventDto(driverId: 'drv-1'),
    );
    realtimeClient.eventController.add(eventDto);
    await pumpEventQueue();

    expect(events, hasLength(1));
    expect(events.first, eventDto);

    await sub.cancel();
  });
}
