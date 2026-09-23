import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_box_assigned_event_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_driver_issue_event_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_driver_location_event_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/models/realtime/dispatcher_driver_status_event_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/data/models/response/dispatcher_live_monitoring_response_dto.dart';

void main() {
  group('DispatcherLiveMonitoringResponseDto', () {
    test('parses full json payload defensively', () {
      final json = {
        'kpis': {
          'activeDriversCount': 25,
          'inDeliveryCount': 15,
          'pausedCount': 6,
          'issuesCount': 4,
        },
        'drivers': [
          {
            'id': 'drv-1',
            'driverCode': 'D001',
            'name': 'Ahmed Ali',
            'phoneNumber': '+96590001111',
            'plateNumber': 'KWT 1234',
            'avatarUrl': 'https://example.com/avatar.jpg',
            'boxId': 'BOX-101',
            'tripId': 'TRIP-999',
            'latitude': 29.3759,
            'longitude': 47.9774,
            'heading': 180.5,
            'speed': 45.0,
            'lastLocationTimestamp': '2026-09-22T10:00:00.000Z',
            'status': 'InDelivery',
            'statusText': 'في التوصيل',
            'statusColor': '#22B96E',
            'hasIssue': false,
            'issueDescription': null,
            'lastStatusTimestamp': '2026-09-22T09:50:00.000Z',
            'locationZone': 'Hawally',
            'remainingDistanceKm': 4.2,
            'remainingDistanceText': '4.2 كم',
            'remainingDeliveryValue': 12.5,
          }
        ],
      };

      final dto = DispatcherLiveMonitoringResponseDto.fromJson(json);

      expect(dto.kpis, isNotNull);
      expect(dto.kpis?.activeDriversCount, 25);
      expect(dto.kpis?.inDeliveryCount, 15);
      expect(dto.kpis?.pausedCount, 6);
      expect(dto.kpis?.issuesCount, 4);

      expect(dto.drivers, hasLength(1));
      final driver = dto.drivers!.first;
      expect(driver.id, 'drv-1');
      expect(driver.driverCode, 'D001');
      expect(driver.name, 'Ahmed Ali');
      expect(driver.latitude, 29.3759);
      expect(driver.longitude, 47.9774);
      expect(driver.status, 'InDelivery');
      expect(driver.locationZone, 'Hawally');
      expect(driver.remainingDistanceKm, 4.2);
    });

    test('parses real backend API payload with driverId, driverName, attentionRequiredCount', () {
      final json = {
        'kpis': {
          'activeDriversCount': 6,
          'inDeliveryCount': 0,
          'pausedCount': 1,
          'attentionRequiredCount': 5,
        },
        'drivers': [
          {
            'driverId': '5db39f96-a20e-464a-93c6-b9478d1e58f5',
            'driverCode': 'L-98765',
            'driverName': 'أحمد السائق (مذاق البيت)',
            'phone': null,
            'plateNumber': 'KW-1001',
            'avatarUrl': 'https://cdn.mealmate.app/avatars/5db39f96.jpg',
            'boxCode': 'BX-194934',
            'latitude': null,
            'longitude': null,
            'heading': 210,
            'speedKmh': 0,
            'statusCategory': 'AttentionRequired',
            'statusText': 'مشكلة تتطلب انتباه',
            'statusColor': 'Red',
            'topIndicatorColor': 'Red',
            'locationZone': 'اليرموك',
            'remainingDistanceKm': null,
            'remainingDistanceText': '—',
            'hasIssue': true,
            'issueDescription': 'انقطاع إشارة التتبع منذ أكثر من 20 دقيقة',
            'updatedAtUtc': '2026-09-22T16:33:24.3992233Z',
          }
        ],
      };

      final dto = DispatcherLiveMonitoringResponseDto.fromJson(json);

      expect(dto.kpis, isNotNull);
      expect(dto.kpis?.activeDriversCount, 6);
      expect(dto.kpis?.inDeliveryCount, 0);
      expect(dto.kpis?.pausedCount, 1);
      expect(dto.kpis?.attentionRequiredCount, 5);

      expect(dto.drivers, hasLength(1));
      final driver = dto.drivers!.first;
      expect(driver.driverId, '5db39f96-a20e-464a-93c6-b9478d1e58f5');
      expect(driver.driverCode, 'L-98765');
      expect(driver.driverName, 'أحمد السائق (مذاق البيت)');
      expect(driver.boxCode, 'BX-194934');
      expect(driver.statusCategory, 'AttentionRequired');
      expect(driver.speedKmh, 0.0);
      expect(driver.hasIssue, isTrue);
      expect(driver.updatedAtUtc, '2026-09-22T16:33:24.3992233Z');
    });

    test('handles empty or null fields defensively without crashing', () {
      final json = <String, dynamic>{};
      final dto = DispatcherLiveMonitoringResponseDto.fromJson(json);

      expect(dto.kpis, isNull);
      expect(dto.drivers, isNull);
    });
  });

  group('Realtime Event DTOs', () {
    test('DispatcherDriverLocationEventDto parses payload', () {
      final json = {
        'driverId': 'drv-1',
        'latitude': 29.378,
        'longitude': 47.98,
        'heading': 90.0,
        'speed': 50.0,
        'timestamp': '2026-09-22T10:05:00.000Z',
        'locationZone': 'Salmiya',
        'remainingDistanceKm': 2.5,
        'remainingDistanceText': '2.5 km',
      };

      final dto = DispatcherDriverLocationEventDto.fromJson(json);

      expect(dto.driverId, 'drv-1');
      expect(dto.latitude, 29.378);
      expect(dto.longitude, 47.98);
      expect(dto.locationZone, 'Salmiya');
      expect(dto.remainingDistanceKm, 2.5);
    });

    test('DispatcherDriverStatusEventDto parses payload with kpis', () {
      final json = {
        'driverId': 'drv-1',
        'status': 'AttentionRequired',
        'statusText': 'مشكلة',
        'statusColor': '#FF0000',
        'hasIssue': true,
        'issueDescription': 'Tire puncture',
        'timestamp': '2026-09-22T10:06:00.000Z',
        'kpis': {
          'activeDriversCount': 25,
          'inDeliveryCount': 14,
          'pausedCount': 6,
          'issuesCount': 5,
        },
      };

      final dto = DispatcherDriverStatusEventDto.fromJson(json);

      expect(dto.driverId, 'drv-1');
      expect(dto.status, 'AttentionRequired');
      expect(dto.hasIssue, isTrue);
      expect(dto.issueDescription, 'Tire puncture');
      expect(dto.kpis?.issuesCount, 5);
    });

    test('DispatcherDriverIssueEventDto parses payload', () {
      final json = {
        'driverId': 'drv-1',
        'hasIssue': true,
        'issueDescription': 'Motorcycle engine problem',
        'timestamp': '2026-09-22T10:07:00.000Z',
      };

      final dto = DispatcherDriverIssueEventDto.fromJson(json);

      expect(dto.driverId, 'drv-1');
      expect(dto.hasIssue, isTrue);
      expect(dto.issueDescription, 'Motorcycle engine problem');
    });

    test('DispatcherBoxAssignedEventDto parses payload', () {
      final json = {
        'boxId': 'BOX-102',
        'driverId': 'drv-2',
        'tripId': 'TRIP-1000',
        'timestamp': '2026-09-22T10:08:00.000Z',
      };

      final dto = DispatcherBoxAssignedEventDto.fromJson(json);

      expect(dto.boxId, 'BOX-102');
      expect(dto.driverId, 'drv-2');
      expect(dto.tripId, 'TRIP-1000');
    });
  });
}
