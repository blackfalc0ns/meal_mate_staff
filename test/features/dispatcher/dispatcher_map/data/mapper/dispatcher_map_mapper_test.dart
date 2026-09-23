import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/mapper/dispatcher_map_mapper.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_box_assigned_event_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_driver_issue_event_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_driver_location_event_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_driver_status_event_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/models/response/dispatcher_live_monitoring_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_driver_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_realtime_event.dart';

void main() {
  group('DispatcherMapMapper', () {
    test('maps DispatcherLiveMonitoringResponseDto to entity with fallbacks', () {
      final dto = DispatcherLiveMonitoringResponseDto(
        kpis: const DispatcherMapKpiResponseDto(
          activeDriversCount: 10,
          inDeliveryCount: 6,
          pausedCount: 2,
          issuesCount: 2,
        ),
        drivers: [
          const DispatcherMapDriverResponseDto(
            id: 'd1',
            driverCode: 'DRV-1',
            name: 'Kareem',
            phoneNumber: '123456',
            plateNumber: 'ABC 123',
            avatarUrl: 'https://avatar.url/1.png',
            boxId: 'BOX-1',
            tripId: 'TRIP-1',
            latitude: 29.3,
            longitude: 47.9,
            heading: 120.0,
            speed: 30.0,
            lastLocationTimestamp: '2026-09-22T10:00:00Z',
            status: 'InDelivery',
            statusText: 'في التوصيل',
            statusColor: '#22B96E',
            hasIssue: false,
            locationZone: 'Zone A',
            remainingDistanceKm: 3.5,
          ),
          const DispatcherMapDriverResponseDto(
            id: null,
            name: null,
            boxId: null,
            status: 'SomeUnknownStatus',
            latitude: null,
            longitude: null,
          ),
        ],
      );

      final entity = dto.toEntity();

      expect(entity.kpi.activeDriversCount, 10);
      expect(entity.kpi.inDeliveryCount, 6);
      expect(entity.kpi.pausedCount, 2);
      expect(entity.kpi.issuesCount, 2);

      expect(entity.drivers, hasLength(2));

      final first = entity.drivers[0];
      expect(first.id, 'd1');
      expect(first.name, 'Kareem');
      expect(first.status, DispatcherMapDriverStatus.inDelivery);
      expect(first.hasValidCoordinates, isTrue);

      final second = entity.drivers[1];
      expect(second.id, '');
      expect(second.name, '');
      expect(second.boxId, '');
      expect(second.status, DispatcherMapDriverStatus.unknown);
      expect(second.hasValidCoordinates, isFalse);
    });

    test('maps backend fields (driverId, driverName, boxCode, attentionRequiredCount) to entity', () {
      final dto = DispatcherLiveMonitoringResponseDto(
        kpis: const DispatcherMapKpiResponseDto(
          activeDriversCount: 6,
          inDeliveryCount: 0,
          pausedCount: 1,
          attentionRequiredCount: 5,
        ),
        drivers: [
          const DispatcherMapDriverResponseDto(
            driverId: '5db39f96-a20e-464a-93c6-b9478d1e58f5',
            driverCode: 'L-98765',
            driverName: 'أحمد السائق (مذاق البيت)',
            boxCode: 'BX-194934',
            statusCategory: 'AttentionRequired',
            statusText: 'مشكلة تتطلب انتباه',
            hasIssue: true,
            issueDescription: 'انقطاع إشارة التتبع منذ أكثر من 20 دقيقة',
            speedKmh: 0,
            locationZone: 'اليرموك',
          ),
        ],
      );

      final entity = dto.toEntity();

      expect(entity.kpi.activeDriversCount, 6);
      expect(entity.kpi.issuesCount, 5);

      expect(entity.drivers, hasLength(1));
      final driver = entity.drivers.first;
      expect(driver.id, '5db39f96-a20e-464a-93c6-b9478d1e58f5');
      expect(driver.driverCode, 'L-98765');
      expect(driver.name, 'أحمد السائق (مذاق البيت)');
      expect(driver.boxId, 'BX-194934');
      expect(driver.status, DispatcherMapDriverStatus.hasIssue);
      expect(driver.speed, 0.0);
      expect(driver.hasIssue, isTrue);
      expect(driver.issueDescription, 'انقطاع إشارة التتبع منذ أكثر من 20 دقيقة');
    });

    test('maps canonical status strings correctly', () {
      expect('InDelivery'.toDriverStatus(), DispatcherMapDriverStatus.inDelivery);
      expect('indelivery'.toDriverStatus(), DispatcherMapDriverStatus.inDelivery);
      expect('Loading'.toDriverStatus(), DispatcherMapDriverStatus.onTheWayToLoad);
      expect('Paused'.toDriverStatus(), DispatcherMapDriverStatus.paused);
      expect('AttentionRequired'.toDriverStatus(), DispatcherMapDriverStatus.hasIssue);
      expect('Random'.toDriverStatus(), DispatcherMapDriverStatus.unknown);
      expect(null.toDriverStatus(), DispatcherMapDriverStatus.unknown);
    });

    test('maps realtime location event dto', () {
      const dto = DispatcherDriverLocationEventDto(
        driverId: 'd1',
        latitude: 29.35,
        longitude: 47.95,
        heading: 45.0,
        speed: 25.0,
        timestamp: '2026-09-22T10:10:00Z',
        locationZone: 'Zone B',
        remainingDistanceKm: 1.2,
      );

      final event = dto.toDomain();
      expect(event, isA<DispatcherMapLocationUpdatedEvent>());
      expect(event.driverId, 'd1');
      expect(event.latitude, 29.35);
      expect(event.locationZone, 'Zone B');
    });

    test('maps realtime status event dto', () {
      const dto = DispatcherDriverStatusEventDto(
        driverId: 'd1',
        status: 'Paused',
        statusText: 'متوقف',
        hasIssue: false,
        timestamp: '2026-09-22T10:12:00Z',
        kpis: DispatcherMapKpiResponseDto(activeDriversCount: 11),
      );

      final event = dto.toDomain();
      expect(event, isA<DispatcherMapStatusUpdatedEvent>());
      expect(event.driverId, 'd1');
      expect(event.status, DispatcherMapDriverStatus.paused);
      expect(event.kpis?.activeDriversCount, 11);
    });

    test('maps realtime issue event dto', () {
      const dto = DispatcherDriverIssueEventDto(
        driverId: 'd1',
        hasIssue: true,
        issueDescription: 'Issue',
        timestamp: '2026-09-22T10:14:00Z',
      );

      final event = dto.toDomain();
      expect(event, isA<DispatcherMapIssueUpdatedEvent>());
      expect(event.hasIssue, isTrue);
    });

    test('maps realtime box assigned event dto', () {
      const dto = DispatcherBoxAssignedEventDto(
        boxId: 'b1',
        driverId: 'd1',
        tripId: 't1',
        timestamp: '2026-09-22T10:16:00Z',
      );

      final event = dto.toDomain();
      expect(event, isA<DispatcherMapBoxAssignedEvent>());
      expect(event.boxId, 'b1');
    });
  });
}
