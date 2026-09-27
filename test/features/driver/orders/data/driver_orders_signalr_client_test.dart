import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/services/token_service.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/realtime/driver_orders_signalr_client.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_orders_realtime_event.dart';
import 'package:signalr_netcore/signalr_client.dart';

class _FakeTokenService implements TokenService {
  String? token = 'valid-driver-jwt';

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
  late DriverOrdersSignalRClient client;

  setUp(() {
    tokenService = _FakeTokenService();
    fakeHub = _FakeHubConnection();
    client = DriverOrdersSignalRClient(
      tokenService,
      hubUrl: 'http://test.com/hubs/driver',
      hubConnection: fakeHub,
    );
  });

  tearDown(() async {
    await client.dispose();
  });

  group('DriverOrdersSignalRClient URL & Lifecycle', () {
    test('buildHubUrl constructs correct url with /hubs/driver', () {
      final url = DriverOrdersSignalRClient.buildHubUrl(
        base: 'http://maelmate.runasp.net',
      );
      expect(url, 'http://maelmate.runasp.net/hubs/driver');
    });

    test('start() registers 5 handlers and calls start once', () async {
      await client.start();
      await client.start(); // second call should be ignored

      expect(fakeHub.startCalls, 1);
      expect(fakeHub.handlers.containsKey('box-delivered'), true);
      expect(fakeHub.handlers.containsKey('delivery-failed'), true);
      expect(fakeHub.handlers.containsKey('driver-arrived-at-customer'), true);
      expect(fakeHub.handlers.containsKey('driver-requested-reassignment'), true);
      expect(fakeHub.handlers.containsKey('trip-in-transit'), true);
    });

    test('deduplicates events by eventId', () async {
      await client.start();

      final receivedEvents = <DriverOrdersRealtimeEvent>[];
      final subscription = client.events.listen(receivedEvents.add);

      final payload = {
        'eventId': 'event-unique-1',
        'tripId': 'trip-1',
        'boxId': 'box-1',
        'tripStopId': 'stop-1',
        'statusText': 'تم التسليم',
        'occurredAtUtc': '2026-09-27T12:00:00Z',
      };

      // Emit twice with same eventId
      fakeHub.handlers['box-delivered']?.call([payload]);
      fakeHub.handlers['box-delivered']?.call([payload]);

      await pumpEventQueue();

      expect(receivedEvents.length, 1);
      expect(receivedEvents.first.eventId, 'event-unique-1');

      await subscription.cancel();
    });

    test('ignores malformed payload without terminating stream', () async {
      await client.start();

      final receivedEvents = <DriverOrdersRealtimeEvent>[];
      final subscription = client.events.listen(receivedEvents.add);

      // Malformed args: null, empty, or not a map
      fakeHub.handlers['box-delivered']?.call(null);
      fakeHub.handlers['box-delivered']?.call([]);
      fakeHub.handlers['box-delivered']?.call(['not-a-map']);

      // Valid event
      fakeHub.handlers['box-delivered']?.call([
        {
          'eventId': 'event-valid-1',
          'tripId': 'trip-1',
          'boxId': 'box-1',
          'tripStopId': 'stop-1',
          'occurredAtUtc': '2026-09-27T12:05:00Z',
        }
      ]);

      await pumpEventQueue();

      expect(receivedEvents.length, 1);
      expect(receivedEvents.first.eventId, 'event-valid-1');

      await subscription.cancel();
    });

    test('stop() unregisters handlers and stops hub', () async {
      await client.start();
      expect(fakeHub.handlers.isNotEmpty, true);

      await client.stop();
      expect(fakeHub.stopCalls, 1);
      expect(fakeHub.handlers.isEmpty, true);
    });
  });
}
