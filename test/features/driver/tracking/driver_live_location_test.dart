import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/models/realtime/driver_orders_realtime_event_dto.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/realtime/driver_orders_realtime_client.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_orders_realtime_event.dart';
import 'package:meal_mate_delivery/features/driver/tracking/data/datasources/driver_location_remote_datasource.dart';
import 'package:meal_mate_delivery/features/driver/tracking/data/services/driver_location_service.dart';
import 'package:meal_mate_delivery/features/driver/tracking/presentation/manager/driver_live_location_coordinator.dart';

class FakeDriverLocationService implements DriverLocationService {
  bool permissionGranted = true;
  Position? currentPosition = Position(
    latitude: 29.3375,
    longitude: 48.0281,
    timestamp: DateTime.now(),
    accuracy: 5.0,
    altitude: 10.0,
    altitudeAccuracy: 1.0,
    heading: 90.0,
    headingAccuracy: 1.0,
    speed: 10.0,
    speedAccuracy: 1.0,
  );

  final _positionController = StreamController<Position>.broadcast();

  @override
  Future<bool> checkAndRequestPermission() async => permissionGranted;

  @override
  Future<LocationPermission> checkPermission() async =>
      permissionGranted ? LocationPermission.always : LocationPermission.denied;

  @override
  Future<Position?> getCurrentPosition() async => currentPosition;

  @override
  Stream<Position> getPositionStream({
    int intervalSeconds = 3,
    int distanceFilterMeters = 3,
  }) => _positionController.stream;

  @override
  Future<bool> isLocationServiceEnabled() async => true;

  @override
  Future<LocationPermission> requestPermission() async =>
      permissionGranted ? LocationPermission.always : LocationPermission.denied;

  void emitPosition(Position pos) {
    _positionController.add(pos);
  }

  void dispose() {
    _positionController.close();
  }
}

class FakeDriverOrdersRealtimeClient implements DriverOrdersRealtimeClient {
  final _eventController = StreamController<DriverOrdersRealtimeEvent>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();

  bool connected = true;
  List<Map<String, dynamic>> sentLocations = [];

  @override
  Stream<DriverOrdersRealtimeEvent> get events => _eventController.stream;

  @override
  Stream<bool> get connectionStatus => _connectionController.stream;

  @override
  bool get isConnected => connected;

  @override
  Future<void> start() async {
    connected = true;
    _connectionController.add(true);
  }

  @override
  Future<void> stop() async {
    connected = false;
    _connectionController.add(false);
  }

  @override
  Future<void> dispose() async {
    await _eventController.close();
    await _connectionController.close();
  }

  @override
  Future<Map<String, dynamic>?> updateLocation({
    required double latitude,
    required double longitude,
    double? heading,
    double? speedKmh,
  }) async {
    sentLocations.add({
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'speedKmh': speedKmh,
    });
    return {'success': true, 'trackingPointId': 'tp-${sentLocations.length}'};
  }

  void emitEvent(DriverOrdersRealtimeEvent event) {
    _eventController.add(event);
  }
}

class FakeDriverLocationRemoteDataSource implements DriverLocationRemoteDataSource {
  List<Map<String, dynamic>> fallbackLocations = [];

  @override
  Future<Map<String, dynamic>?> sendLocation({
    required double latitude,
    required double longitude,
    double? heading,
    double? speedKmh,
  }) async {
    fallbackLocations.add({
      'latitude': latitude,
      'longitude': longitude,
      'heading': heading,
      'speedKmh': speedKmh,
    });
    return {'success': true};
  }
}

void main() {
  group('Driver Live Location - Event Parsing Tests', () {
    test('parses box-assigned payload correctly', () {
      final payload = {
        'eventId': 'ev-1',
        'boxId': 'box-123',
        'boxCode': 'B-99',
        'tripId': 'trip-456',
        'occurredAtUtc': '2026-10-02T10:00:00Z',
      };

      final event = DriverOrdersRealtimeEventDto.fromPayload('box-assigned', payload);
      expect(event, isA<DriverBoxAssignedEvent>());
      final assigned = event as DriverBoxAssignedEvent;
      expect(assigned.boxId, 'box-123');
      expect(assigned.boxCode, 'B-99');
      expect(assigned.tripId, 'trip-456');
      expect(assigned.isReassigned, isFalse);
    });

    test('parses box-reassigned payload with isReassigned true', () {
      final payload = {
        'eventId': 'ev-2',
        'boxId': 'box-124',
        'tripId': 'trip-456',
        'occurredAtUtc': '2026-10-02T10:05:00Z',
      };

      final event = DriverOrdersRealtimeEventDto.fromPayload('box-reassigned', payload);
      expect(event, isA<DriverBoxAssignedEvent>());
      expect((event as DriverBoxAssignedEvent).isReassigned, isTrue);
    });

    test('parses delivery-completed payload with remaining count', () {
      final payload = {
        'eventId': 'ev-3',
        'boxId': 'box-123',
        'tripId': 'trip-456',
        'remainingBoxesCount': 0,
        'occurredAtUtc': '2026-10-02T10:15:00Z',
      };

      final event = DriverOrdersRealtimeEventDto.fromPayload('delivery-completed', payload);
      expect(event, isA<DriverDeliveryCompletedEvent>());
      expect((event as DriverDeliveryCompletedEvent).remainingBoxesCount, 0);
    });

    test('parses dispatcher.tracking_not_required payload', () {
      final payload = {
        'eventId': 'ev-4',
        'reason': 'dispatcher.tracking_not_required',
        'occurredAtUtc': '2026-10-02T10:20:00Z',
      };

      final event = DriverOrdersRealtimeEventDto.fromPayload(
        'dispatcher.tracking_not_required',
        payload,
      );
      expect(event, isA<DriverTrackingNotRequiredEvent>());
    });

    test('parses dispatcher-message, kitchen-ready, and connection-established', () {
      final msgEvent = DriverOrdersRealtimeEventDto.fromPayload('dispatcher-message', {
        'message': 'يرجى الإسراع بالتسليم',
        'title': 'تنبيه',
      });
      expect(msgEvent, isA<DriverDispatcherMessageEvent>());
      expect((msgEvent as DriverDispatcherMessageEvent).message, 'يرجى الإسراع بالتسليم');

      final kitchenEvent = DriverOrdersRealtimeEventDto.fromPayload('kitchen-ready', {
        'boxId': 'box-123',
        'mealName': 'وجبة صحية',
      });
      expect(kitchenEvent, isA<DriverKitchenReadyEvent>());

      final connEvent = DriverOrdersRealtimeEventDto.fromPayload('connection-established', {
        'connectionId': 'conn-xyz',
      });
      expect(connEvent, isA<DriverConnectionEstablishedEvent>());
    });
  });

  group('Driver Location Coordinate Validation Tests', () {
    test('rejects (0.0, 0.0) coordinates', () {
      expect(DriverLocationServiceImpl.isValidCoordinate(0.0, 0.0), isFalse);
    });

    test('rejects non-finite coordinates', () {
      expect(DriverLocationServiceImpl.isValidCoordinate(double.nan, 48.0), isFalse);
      expect(DriverLocationServiceImpl.isValidCoordinate(29.0, double.infinity), isFalse);
    });

    test('rejects out of bounds coordinates', () {
      expect(DriverLocationServiceImpl.isValidCoordinate(95.0, 48.0), isFalse);
      expect(DriverLocationServiceImpl.isValidCoordinate(29.0, 190.0), isFalse);
    });

    test('accepts valid coordinates', () {
      expect(DriverLocationServiceImpl.isValidCoordinate(29.3375, 48.0281), isTrue);
    });
  });

  group('Driver Live Location Coordinator Lifecycle Tests', () {
    late FakeDriverLocationService fakeLocationService;
    late FakeDriverOrdersRealtimeClient fakeRealtimeClient;
    late FakeDriverLocationRemoteDataSource fakeFallback;
    late DriverLiveLocationCoordinator coordinator;

    setUp(() {
      fakeLocationService = FakeDriverLocationService();
      fakeRealtimeClient = FakeDriverOrdersRealtimeClient();
      fakeFallback = FakeDriverLocationRemoteDataSource();
      coordinator = DriverLiveLocationCoordinator(
        locationService: fakeLocationService,
        realtimeClient: fakeRealtimeClient,
        fallbackDataSource: fakeFallback,
        streamingInterval: const Duration(milliseconds: 50),
      );
    });

    tearDown(() {
      coordinator.dispose();
      fakeLocationService.dispose();
      fakeRealtimeClient.dispose();
    });

    test('does not start streaming when active boxes is zero', () async {
      await coordinator.startTracking();
      expect(coordinator.isStreaming, isFalse);
    });

    test('starts streaming when active boxes count > 0', () async {
      await coordinator.setActiveBoxesCount(1);
      expect(coordinator.isStreaming, isTrue);
      expect(coordinator.activeBoxCount, 1);
    });

    test('stops streaming when active boxes becomes zero', () async {
      await coordinator.setActiveBoxesCount(2);
      expect(coordinator.isStreaming, isTrue);

      await coordinator.setActiveBoxesCount(0);
      expect(coordinator.isStreaming, isFalse);
      expect(coordinator.activeBoxCount, 0);
    });

    test('starts streaming automatically when DriverBoxAssignedEvent is emitted', () async {
      expect(coordinator.isStreaming, isFalse);

      fakeRealtimeClient.emitEvent(
        DriverBoxAssignedEvent(
          eventId: 'box-ev-1',
          occurredAtUtc: DateTime.now().toUtc(),
          boxId: 'box-abc',
        ),
      );

      await pumpEventQueue();

      expect(coordinator.isStreaming, isTrue);
      expect(coordinator.activeBoxCount, 1);
    });

    test('stops streaming when DriverDeliveryCompletedEvent reports remaining 0', () async {
      await coordinator.setActiveBoxesCount(1);
      expect(coordinator.isStreaming, isTrue);

      fakeRealtimeClient.emitEvent(
        DriverDeliveryCompletedEvent(
          eventId: 'del-ev-1',
          occurredAtUtc: DateTime.now().toUtc(),
          boxId: 'box-abc',
          remainingBoxesCount: 0,
        ),
      );

      await pumpEventQueue();

      expect(coordinator.isStreaming, isFalse);
      expect(coordinator.activeBoxCount, 0);
    });

    test('stops streaming immediately on DriverTrackingNotRequiredEvent (Golden Rule)', () async {
      await coordinator.setActiveBoxesCount(3);
      expect(coordinator.isStreaming, isTrue);

      fakeRealtimeClient.emitEvent(
        DriverTrackingNotRequiredEvent(
          eventId: 'stop-ev-1',
          occurredAtUtc: DateTime.now().toUtc(),
          reason: 'dispatcher.tracking_not_required',
        ),
      );

      await pumpEventQueue();

      expect(coordinator.isStreaming, isFalse);
      expect(coordinator.activeBoxCount, 0);
    });
  });
}
