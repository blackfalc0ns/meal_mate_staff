import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/services/token_service.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/realtime/dispatcher_map_realtime_event_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/realtime/dispatcher_map_signalr_client.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_connection_status.dart';
import 'package:signalr_netcore/signalr_client.dart';

class _FakeTokenService implements TokenService {
  String? token = 'valid-jwt-token';

  @override
  Future<String?> getToken() async => token;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeHubConnection implements HubConnection {
  final Map<String, void Function(List<Object?>?)> handlers = {};
  void Function({Exception? error})? closeHandler;
  void Function({Exception? error})? reconnectingHandler;
  void Function({String? connectionId})? reconnectedHandler;

  int startCalls = 0;
  int stopCalls = 0;
  bool shouldThrowOnStart = false;
  Exception? startException;

  @override
  void on(String methodName, void Function(List<Object?>?) newMethod) {
    handlers[methodName] = newMethod;
  }

  @override
  void off(String methodName, {void Function(List<Object?>?)? method}) {
    handlers.remove(methodName);
  }

  @override
  void onclose(void Function({Exception? error}) callback) {
    closeHandler = callback;
  }

  @override
  void onreconnecting(void Function({Exception? error}) callback) {
    reconnectingHandler = callback;
  }

  @override
  void onreconnected(void Function({String? connectionId}) callback) {
    reconnectedHandler = callback;
  }

  @override
  Future<void> start() async {
    startCalls++;
    if (shouldThrowOnStart) {
      throw startException ?? Exception('Network connection failed');
    }
  }

  @override
  Future<void> stop() async {
    stopCalls++;
    closeHandler?.call();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeTokenService tokenService;
  late _FakeHubConnection fakeHub;
  late DispatcherMapSignalRClient client;

  setUp(() {
    tokenService = _FakeTokenService();
    fakeHub = _FakeHubConnection();
    client = DispatcherMapSignalRClient(
      tokenService,
      hubUrl: 'ws://example.com/hubs/dispatcher',
      hubConnection: fakeHub,
    );
  });

  tearDown(() async {
    await client.dispose();
  });

  group('Hub URL construction', () {
    test('buildHubUrl preserves http/https scheme and appends path', () {
      final httpUrl = DispatcherMapSignalRClient.buildHubUrl(
        base: 'http://api.example.com',
      );
      expect(httpUrl, 'http://api.example.com/hubs/dispatcher');

      final httpsUrl = DispatcherMapSignalRClient.buildHubUrl(
        base: 'https://api.example.com/api/v1',
      );
      expect(httpsUrl, 'https://api.example.com/api/v1/hubs/dispatcher');
    });
  });

  group('Authentication & Connection Flow', () {
    test('missing or empty token emits unauthorized and does not start hub', () async {
      tokenService.token = null;
      final statuses = <DispatcherMapConnectionStatus>[];
      final sub = client.connectionStatuses.listen(statuses.add);

      await client.connect();
      await pumpEventQueue();

      expect(statuses, contains(DispatcherMapConnectionStatus.unauthorized));
      expect(fakeHub.startCalls, 0);

      await sub.cancel();
    });

    test('successful connect transitions connecting -> connected and registers handlers', () async {
      final statuses = <DispatcherMapConnectionStatus>[];
      final sub = client.connectionStatuses.listen(statuses.add);

      await client.connect();
      await pumpEventQueue();

      expect(statuses, [
        DispatcherMapConnectionStatus.connecting,
        DispatcherMapConnectionStatus.connected,
      ]);
      expect(fakeHub.startCalls, 1);
      expect(fakeHub.handlers.containsKey('driver-location-updated'), isTrue);
      expect(fakeHub.handlers.containsKey('driver-status-updated'), isTrue);
      expect(fakeHub.handlers.containsKey('driver-issue-updated'), isTrue);
      expect(fakeHub.handlers.containsKey('box-assigned'), isTrue);

      await sub.cancel();
    });

    test('connect is idempotent and reuses in-flight connection', () async {
      final future1 = client.connect();
      final future2 = client.connect();
      await Future.wait([future1, future2]);

      expect(fakeHub.startCalls, 1);
    });

    test('401/403 failure emits unauthorized', () async {
      fakeHub.shouldThrowOnStart = true;
      fakeHub.startException = Exception('401 Unauthorized');

      final statuses = <DispatcherMapConnectionStatus>[];
      final sub = client.connectionStatuses.listen(statuses.add);

      await client.connect();
      await pumpEventQueue();

      expect(statuses, contains(DispatcherMapConnectionStatus.unauthorized));
      await sub.cancel();
    });

    test('network failure on start emits reconnecting', () async {
      fakeHub.shouldThrowOnStart = true;
      fakeHub.startException = Exception('Network connection timed out');

      final statuses = <DispatcherMapConnectionStatus>[];
      final sub = client.connectionStatuses.listen(statuses.add);

      await client.connect();
      await pumpEventQueue();

      expect(statuses, contains(DispatcherMapConnectionStatus.reconnecting));
      expect(client.currentStatus, DispatcherMapConnectionStatus.reconnecting);
      await sub.cancel();
    });

    test('disconnect stops hub and emits disconnected', () async {
      await client.connect();
      expect(client.currentStatus, DispatcherMapConnectionStatus.connected);

      await client.disconnect();
      expect(client.currentStatus, DispatcherMapConnectionStatus.disconnected);
      expect(fakeHub.stopCalls, 1);
    });
  });

  group('Event Dispatching', () {
    setUp(() async {
      await client.connect();
    });

    test('driver-location-updated parses and emits LocationUpdatedRealtimeDto', () async {
      final events = <DispatcherMapRealtimeEventDto>[];
      final sub = client.events.listen(events.add);

      fakeHub.handlers['driver-location-updated']?.call([
        {
          'driverId': 'drv-1',
          'latitude': 29.35,
          'longitude': 47.95,
          'speed': 45.0,
          'timestamp': '2026-09-22T10:00:00.000Z',
        }
      ]);

      await pumpEventQueue();

      expect(events, hasLength(1));
      expect(events.first, isA<LocationUpdatedRealtimeDto>());
      final dto = (events.first as LocationUpdatedRealtimeDto).dto;
      expect(dto.driverId, 'drv-1');
      expect(dto.latitude, 29.35);
      expect(dto.longitude, 47.95);

      await sub.cancel();
    });

    test('driver-status-updated parses and emits StatusUpdatedRealtimeDto', () async {
      final events = <DispatcherMapRealtimeEventDto>[];
      final sub = client.events.listen(events.add);

      fakeHub.handlers['driver-status-updated']?.call([
        {
          'driverId': 'drv-1',
          'status': 'InDelivery',
          'statusText': 'في الطريق',
          'timestamp': '2026-09-22T10:00:00.000Z',
        }
      ]);

      await pumpEventQueue();

      expect(events, hasLength(1));
      expect(events.first, isA<StatusUpdatedRealtimeDto>());
      final dto = (events.first as StatusUpdatedRealtimeDto).dto;
      expect(dto.driverId, 'drv-1');
      expect(dto.status, 'InDelivery');

      await sub.cancel();
    });

    test('driver-issue-updated parses and emits IssueUpdatedRealtimeDto', () async {
      final events = <DispatcherMapRealtimeEventDto>[];
      final sub = client.events.listen(events.add);

      fakeHub.handlers['driver-issue-updated']?.call([
        {
          'driverId': 'drv-1',
          'hasIssue': true,
          'issueDescription': 'Tire puncture',
          'timestamp': '2026-09-22T10:00:00.000Z',
        }
      ]);

      await pumpEventQueue();

      expect(events, hasLength(1));
      expect(events.first, isA<IssueUpdatedRealtimeDto>());

      await sub.cancel();
    });

    test('box-assigned parses and emits BoxAssignedRealtimeDto', () async {
      final events = <DispatcherMapRealtimeEventDto>[];
      final sub = client.events.listen(events.add);

      fakeHub.handlers['box-assigned']?.call([
        {
          'boxId': 'box-101',
          'driverId': 'drv-2',
          'assignedAt': '2026-09-22T10:00:00.000Z',
        }
      ]);

      await pumpEventQueue();

      expect(events, hasLength(1));
      expect(events.first, isA<BoxAssignedRealtimeDto>());

      await sub.cancel();
    });

    test('malformed event does not crash client or close stream', () async {
      final events = <DispatcherMapRealtimeEventDto>[];
      final sub = client.events.listen(events.add);

      // Malformed args
      fakeHub.handlers['driver-location-updated']?.call(null);
      fakeHub.handlers['driver-location-updated']?.call([]);
      fakeHub.handlers['driver-location-updated']?.call(['not-a-map']);

      await pumpEventQueue();
      expect(events, isEmpty);

      // Valid args still processed afterwards
      fakeHub.handlers['driver-location-updated']?.call([
        {
          'driverId': 'drv-1',
          'latitude': 29.35,
          'longitude': 47.95,
        }
      ]);
      await pumpEventQueue();

      expect(events, hasLength(1));
      await sub.cancel();
    });
  });

  group('Lifecycle callbacks', () {
    test('onreconnecting and onreconnected emit reconnecting and connected', () async {
      final statuses = <DispatcherMapConnectionStatus>[];
      final sub = client.connectionStatuses.listen(statuses.add);

      await client.connect();

      fakeHub.reconnectingHandler?.call();
      expect(client.currentStatus, DispatcherMapConnectionStatus.reconnecting);

      fakeHub.reconnectedHandler?.call();
      expect(client.currentStatus, DispatcherMapConnectionStatus.connected);

      fakeHub.closeHandler?.call();
      expect(client.currentStatus, DispatcherMapConnectionStatus.disconnected);

      await sub.cancel();
    });

    test('shared lease ownership reference counting (acquire/release)', () async {
      const driverId = '4a6f235e-c04d-45db-9c3f-c39775c96da9';
      await client.acquire('dispatcher-map');
      expect(fakeHub.startCalls, 1);
      expect(client.currentStatus, DispatcherMapConnectionStatus.connected);

      // Duplicate acquire is idempotent
      await client.acquire('dispatcher-map');
      expect(fakeHub.startCalls, 1);

      // Second owner acquires
      await client.acquire('driver-details:$driverId');
      expect(fakeHub.startCalls, 1);

      // Release first owner does not disconnect
      await client.release('driver-details:$driverId');
      expect(fakeHub.stopCalls, 0);
      expect(client.currentStatus, DispatcherMapConnectionStatus.connected);

      // Release last owner disconnects
      await client.release('dispatcher-map');
      expect(fakeHub.stopCalls, 1);
      expect(client.currentStatus, DispatcherMapConnectionStatus.disconnected);
    });

    test('event parsing supports backend wire names speedKmh, recordedAtUtc, activeBoxesCount, boxCode, assignedAtUtc', () async {
      final events = <DispatcherMapRealtimeEventDto>[];
      final sub = client.events.listen(events.add);

      await client.connect();

      fakeHub.handlers['driver-location-updated']?.call([
        {
          'driverId': 'drv-1',
          'latitude': 29.35,
          'longitude': 47.95,
          'speedKmh': 55.5,
          'recordedAtUtc': '2026-09-23T18:00:00.000Z',
        }
      ]);

      fakeHub.handlers['driver-status-updated']?.call([
        {
          'driverId': 'drv-1',
          'status': 'Available',
          'statusText': 'متاح',
          'activeBoxesCount': 3,
          'recordedAtUtc': '2026-09-23T18:00:00.000Z',
        }
      ]);

      fakeHub.handlers['box-assigned']?.call([
        {
          'boxId': '3c19356d-f432-47d5-89f5-7e82845c8531',
          'boxCode': 'BX-10256',
          'driverId': 'drv-1',
          'assignedAtUtc': '2026-09-23T18:00:00.000Z',
        }
      ]);

      await pumpEventQueue();

      expect(events, hasLength(3));
      final loc = (events[0] as LocationUpdatedRealtimeDto).dto;
      expect(loc.speed, 55.5);
      expect(loc.timestamp, '2026-09-23T18:00:00.000Z');

      final st = (events[1] as StatusUpdatedRealtimeDto).dto;
      expect(st.activeBoxesCount, 3);
      expect(st.timestamp, '2026-09-23T18:00:00.000Z');

      final box = (events[2] as BoxAssignedRealtimeDto).dto;
      expect(box.boxId, '3c19356d-f432-47d5-89f5-7e82845c8531');
      expect(box.boxCode, 'BX-10256');
      expect(box.timestamp, '2026-09-23T18:00:00.000Z');

      await sub.cancel();
    });
  });
}
