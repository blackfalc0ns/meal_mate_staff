import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/services/token_service.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/data/models/realtime/driver_availability_updated_event_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/data/realtime/dispatcher_drivers_status_signalr_client.dart';

class FakeTokenService extends Fake implements TokenService {
  String? token = 'valid-token';

  @override
  Future<String?> getToken() async => token;
}

void main() {
  late FakeTokenService tokenService;
  late DispatcherDriversStatusSignalRClient client;

  setUp(() {
    tokenService = FakeTokenService();
    client = DispatcherDriversStatusSignalRClient(tokenService);
  });

  tearDown(() async {
    await client.dispose();
  });

  group('SignalR URL normalization', () {
    test('buildHubUrl normalizes to /hubs/dispatcher-hub', () {
      expect(
        DispatcherDriversStatusSignalRClient.buildHubUrl(
          base: 'http://maelmate.runasp.net',
        ),
        'http://maelmate.runasp.net/hubs/dispatcher-hub',
      );
      expect(
        DispatcherDriversStatusSignalRClient.buildHubUrl(
          base: 'http://maelmate.runasp.net/',
        ),
        'http://maelmate.runasp.net/hubs/dispatcher-hub',
      );
    });
  });

  group('DriverAvailabilityUpdatedEventDto parsing', () {
    test('parses camelCase payload correctly', () {
      final json = {
        'driverId': 'driver-123',
        'isAvailable': true,
        'operationalStatus': 'Available',
        'hasActiveAssignments': false,
        'updatedAtUtc': '2026-09-27T12:00:00Z',
      };
      final dto = DriverAvailabilityUpdatedEventDto.fromJson(json);
      expect(dto.driverId, 'driver-123');
      expect(dto.isAvailable, isTrue);
      expect(dto.operationalStatus, 'Available');
      expect(dto.hasActiveAssignments, isFalse);
      expect(dto.updatedAtUtc, '2026-09-27T12:00:00Z');
    });

    test('parses PascalCase payload defensively', () {
      final json = {
        'DriverId': 'driver-123',
        'IsAvailable': false,
        'OperationalStatus': 'Unavailable',
        'HasActiveAssignments': true,
        'UpdatedAtUtc': '2026-09-27T12:00:00Z',
      };
      final dto = DriverAvailabilityUpdatedEventDto.fromJson(json);
      expect(dto.driverId, 'driver-123');
      expect(dto.isAvailable, isFalse);
      expect(dto.operationalStatus, 'Unavailable');
      expect(dto.hasActiveAssignments, isTrue);
    });

    test('handles sparse or missing fields', () {
      final dto = DriverAvailabilityUpdatedEventDto.fromJson({});
      expect(dto.driverId, '');
      expect(dto.isAvailable, isFalse);
      expect(dto.operationalStatus, isNull);
    });
  });

  group('Owner tracking', () {
    test('tracks and releases active owners', () async {
      tokenService.token = null; // Prevent real network connection attempt
      await client.acquire('owner-1');
      expect(client.activeOwners, contains('owner-1'));

      await client.acquire('owner-2');
      expect(client.activeOwners.length, 2);

      await client.release('owner-1');
      expect(client.activeOwners.contains('owner-1'), isFalse);
      expect(client.activeOwners.contains('owner-2'), isTrue);

      await client.release('owner-2');
      expect(client.activeOwners.isEmpty, isTrue);
    });
  });
}
