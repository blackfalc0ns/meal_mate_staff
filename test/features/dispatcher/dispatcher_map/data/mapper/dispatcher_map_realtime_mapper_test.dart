import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/mapper/dispatcher_map_realtime_mapper.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_box_assigned_event_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_driver_location_event_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_driver_status_event_dto.dart';

void main() {
  group('DispatcherMapRealtimeMapper', () {
    test('maps DispatcherDriverLocationEventDto with speed and timestamp', () {
      const dto = DispatcherDriverLocationEventDto(
        driverId: 'drv-1',
        latitude: 29.35,
        longitude: 47.95,
        speed: 55.0,
        timestamp: '2026-09-23T18:00:00.000Z',
      );
      final domain = dto.toDomain();
      expect(domain.driverId, 'drv-1');
      expect(domain.latitude, 29.35);
      expect(domain.longitude, 47.95);
      expect(domain.speed, 55.0);
      expect(domain.timestamp.toIso8601String(), '2026-09-23T18:00:00.000Z');
    });

    test('maps DispatcherDriverStatusEventDto with activeBoxesCount', () {
      const dto = DispatcherDriverStatusEventDto(
        driverId: 'drv-1',
        status: 'Available',
        statusText: 'متاح',
        activeBoxesCount: 4,
        timestamp: '2026-09-23T18:00:00.000Z',
      );
      final domain = dto.toDomain();
      expect(domain.driverId, 'drv-1');
      expect(domain.activeBoxesCount, 4);
    });

    test('maps DispatcherBoxAssignedEventDto with boxCode', () {
      const dto = DispatcherBoxAssignedEventDto(
        boxId: '3c19356d-f432-47d5-89f5-7e82845c8531',
        boxCode: 'BX-10256',
        driverId: 'drv-1',
        timestamp: '2026-09-23T18:00:00.000Z',
      );
      final domain = dto.toDomain();
      expect(domain.boxId, '3c19356d-f432-47d5-89f5-7e82845c8531');
      expect(domain.boxCode, 'BX-10256');
      expect(domain.driverId, 'drv-1');
    });
  });
}
