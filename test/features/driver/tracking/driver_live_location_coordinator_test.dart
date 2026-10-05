import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meal_mate_delivery/features/driver/orders/data/realtime/driver_orders_realtime_client.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_orders_realtime_event.dart';
import 'package:meal_mate_delivery/features/driver/tracking/data/datasources/driver_location_remote_datasource.dart';
import 'package:meal_mate_delivery/features/driver/tracking/data/services/driver_location_service.dart';
import 'package:meal_mate_delivery/features/driver/tracking/domain/entities/driver_live_location_sample.dart';
import 'package:meal_mate_delivery/features/driver/tracking/presentation/manager/driver_live_location_coordinator.dart';

class _FakeLocationService implements DriverLocationService {
  bool permissionGranted = true;
  Position? currentPosition = Position(
    latitude: 29.3375,
    longitude: 48.0281,
    timestamp: DateTime.parse('2026-10-05T08:00:00Z'),
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
  }) =>
      _positionController.stream;

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

class _FakeRealtimeClient implements DriverOrdersRealtimeClient {
  final _eventController = StreamController<DriverOrdersRealtimeEvent>.broadcast();
  bool isConnectedValue = false;
  bool shouldFailUpdate = false;
  int updateLocationCallCount = 0;
  Completer<void>? updateLocationCompleter;

  @override
  Stream<DriverOrdersRealtimeEvent> get events => _eventController.stream;

  @override
  bool get isConnected => isConnectedValue;

  @override
  Future<void> start() async {
    isConnectedValue = true;
  }

  @override
  Future<void> stop() async {
    isConnectedValue = false;
  }

  @override
  Future<Map<String, dynamic>?> updateLocation({
    required double latitude,
    required double longitude,
    double? heading,
    double? speedKmh,
  }) async {
    updateLocationCallCount++;
    if (updateLocationCompleter != null) {
      await updateLocationCompleter!.future;
    }
    if (shouldFailUpdate) {
      throw Exception('SignalR error');
    }
    return {'status': 'success'};
  }

  @override
  Future<void> dispose() async {
    await _eventController.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFallbackDataSource implements DriverLocationRemoteDataSource {
  int sendCallCount = 0;
  bool shouldFail = false;

  @override
  Future<Map<String, dynamic>?> sendLocation({
    required double latitude,
    required double longitude,
    double? heading,
    double? speedKmh,
  }) async {
    sendCallCount++;
    if (shouldFail) {
      throw DioException(
        requestOptions: RequestOptions(path: '/api/v1/driver/location'),
        type: DioExceptionType.connectionError,
      );
    }
    return {'status': 'success'};
  }
}

void main() {
  late _FakeLocationService locationService;
  late _FakeRealtimeClient realtimeClient;
  late _FakeFallbackDataSource fallbackDataSource;
  late DriverLiveLocationCoordinator coordinator;

  setUp(() {
    locationService = _FakeLocationService();
    realtimeClient = _FakeRealtimeClient();
    fallbackDataSource = _FakeFallbackDataSource();

    coordinator = DriverLiveLocationCoordinator(
      locationService: locationService,
      realtimeClient: realtimeClient,
      fallbackDataSource: fallbackDataSource,
      streamingInterval: const Duration(seconds: 4),
    );
  });

  tearDown(() {
    coordinator.dispose();
    locationService.dispose();
    realtimeClient.dispose();
  });

  group('DriverLiveLocationCoordinator monitoring interface', () {
    test('emits samples on positions stream when GPS positions arrive', () async {
      await coordinator.setActiveBoxesCount(1);

      final samples = <DriverLiveLocationSample>[];
      final sub = coordinator.positions.listen(samples.add);

      final newPos = Position(
        latitude: 29.35,
        longitude: 48.05,
        timestamp: DateTime.parse('2026-10-05T08:01:00Z'),
        accuracy: 5.0,
        altitude: 10.0,
        altitudeAccuracy: 1.0,
        heading: 180.0,
        headingAccuracy: 1.0,
        speed: 15.0,
        speedAccuracy: 1.0,
      );

      locationService.emitPosition(newPos);
      await pumpEventQueue();

      expect(samples.length, 1);
      expect(samples.first.latitude, 29.35);
      expect(samples.first.longitude, 48.05);
      expect(samples.first.heading, 180.0);
      expect(coordinator.latestLocation?.latitude, 29.35);

      await sub.cancel();
    });

    test('sendCurrentLocationNow succeeds via SignalR and updates lastSuccessfullySentLocation', () async {
      await coordinator.setActiveBoxesCount(1);
      realtimeClient.isConnectedValue = true;

      final success = await coordinator.sendCurrentLocationNow();

      expect(success, isTrue);
      expect(realtimeClient.updateLocationCallCount, greaterThanOrEqualTo(1));
      expect(coordinator.lastSuccessfullySentLocation, isNotNull);
      expect(coordinator.lastSuccessfullySentLocation?.latitude, 29.3375);
    });

    test('sendCurrentLocationNow falls back to REST when SignalR fails', () async {
      await coordinator.setActiveBoxesCount(1);
      realtimeClient.isConnectedValue = true;
      realtimeClient.shouldFailUpdate = true;
      fallbackDataSource.shouldFail = false;

      final success = await coordinator.sendCurrentLocationNow();

      expect(success, isTrue);
      expect(fallbackDataSource.sendCallCount, greaterThanOrEqualTo(1));
      expect(coordinator.lastSuccessfullySentLocation, isNotNull);
    });

    test('sendCurrentLocationNow coalesces concurrent calls into single in-flight send', () async {
      await coordinator.setActiveBoxesCount(1);
      realtimeClient.isConnectedValue = true;
      final completer = Completer<void>();
      realtimeClient.updateLocationCompleter = completer;

      final future1 = coordinator.sendCurrentLocationNow();
      final future2 = coordinator.sendCurrentLocationNow();

      completer.complete();
      final results = await Future.wait([future1, future2]);

      expect(results[0], isTrue);
      expect(results[1], isTrue);
    });
  });
}
