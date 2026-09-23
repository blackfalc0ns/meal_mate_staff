import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/data/mapper/driver_details_mapper.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/data/models/response/driver_active_boxes_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/data/models/response/driver_current_location_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/data/models/response/driver_details_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_details_status.dart';

void main() {
  group('DriverDetailsResponseDto & Mapper', () {
    final detailsJson = {
      'driver': {
        'driverId': '4a6f235e-c04d-45db-9c3f-c39775c96da9',
        'driverCode': 'DR-1025',
        'fullName': 'أحمد السعيد',
        'phoneNumber': '+965501234567',
        'avatarUrl': 'https://example.com/avatar.jpg',
        'status': 'Available',
        'statusText': 'متاح',
        'statusDotColor': '#10B981',
        'lastUpdatedText': 'الآن',
      },
      'kpis': {
        'performanceRating': 4.8,
        'avgDelayMinutes': 12,
        'deliveredTodayCount': 28,
        'activeBoxesCount': 2,
      },
      'dailySummary': {
        'approxKm': 120,
        'avgDelayMinutes': 12,
        'failedDeliveryCount': 1,
        'deliveredCount': 28,
      },
    };

    test('maps valid details JSON to domain entity', () {
      final dto = DriverDetailsResponseDto.fromJson(detailsJson);
      final entity = dto.toEntity();

      expect(entity.driver.driverId, '4a6f235e-c04d-45db-9c3f-c39775c96da9');
      expect(entity.driver.driverCode, 'DR-1025');
      expect(entity.driver.fullName, 'أحمد السعيد');
      expect(entity.driver.phoneNumber, '+965501234567');
      expect(entity.driver.avatarUrl, 'https://example.com/avatar.jpg');
      expect(entity.driver.status, DriverDetailsStatus.available);
      expect(entity.driver.statusText, 'متاح');
      expect(entity.driver.statusDotColor, '#10B981');
      expect(entity.driver.lastUpdatedText, 'الآن');

      expect(entity.kpis.performanceRating, 4.8);
      expect(entity.kpis.avgDelayMinutes, 12);
      expect(entity.kpis.deliveredTodayCount, 28);
      expect(entity.kpis.activeBoxesCount, 2);

      expect(entity.dailySummary.approxKm, 120);
      expect(entity.dailySummary.avgDelayMinutes, 12);
      expect(entity.dailySummary.failedDeliveryCount, 1);
      expect(entity.dailySummary.deliveredCount, 28);
    });

    test('defensively handles null and missing nested objects', () {
      const dto = DriverDetailsResponseDto();
      final entity = dto.toEntity();

      expect(entity.driver.driverId, '');
      expect(entity.driver.driverCode, '');
      expect(entity.driver.fullName, '');
      expect(entity.driver.phoneNumber, isNull);
      expect(entity.driver.avatarUrl, isNull);
      expect(entity.driver.status, DriverDetailsStatus.unknown);
      expect(entity.driver.statusText, '');
      expect(entity.driver.statusDotColor, isNull);
      expect(entity.driver.lastUpdatedText, '');

      expect(entity.kpis.performanceRating, 0.0);
      expect(entity.kpis.avgDelayMinutes, 0);
      expect(entity.kpis.deliveredTodayCount, 0);
      expect(entity.kpis.activeBoxesCount, 0);

      expect(entity.dailySummary.approxKm, 0);
      expect(entity.dailySummary.avgDelayMinutes, 0);
      expect(entity.dailySummary.failedDeliveryCount, 0);
      expect(entity.dailySummary.deliveredCount, 0);
    });

    test('handles numeric types gracefully when int comes as double or vice-versa', () {
      final jsonWithAlteredNumbers = {
        'driver': null,
        'kpis': {
          'performanceRating': 4,
          'avgDelayMinutes': 12.0,
          'deliveredTodayCount': 28.0,
          'activeBoxesCount': 2.0,
        },
        'dailySummary': {
          'approxKm': 120.5,
          'avgDelayMinutes': 12.0,
          'failedDeliveryCount': 1.0,
          'deliveredCount': 28.0,
        },
      };

      final dto = DriverDetailsResponseDto.fromJson(jsonWithAlteredNumbers);
      final entity = dto.toEntity();

      expect(entity.kpis.performanceRating, 4.0);
      expect(entity.kpis.avgDelayMinutes, 12);
      expect(entity.kpis.deliveredTodayCount, 28);
      expect(entity.kpis.activeBoxesCount, 2);
      expect(entity.dailySummary.approxKm, 120);
    });
  });

  group('DriverActiveBoxesResponseDto & Mapper', () {
    final boxesJson = {
      'totalCount': 2,
      'boxes': [
        {
          'boxId': '3c19356d-f432-47d5-89f5-7e82845c8531',
          'boxCode': 'BX-10256',
          'customerName': 'محمد الفضلي',
          'deliveryAddress': 'السليمانية، الرياض',
          'status': 'OnDelivery',
          'statusText': 'خارج للتوصيل',
          'statusColor': '#6366F1',
          'scheduledTimeText': '12:30 م',
          'isDelivering': true,
        },
        {
          'boxId': '7b81923e-e234-45ab-9c12-781920394851',
          'boxCode': 'BX-10257',
          'customerName': 'نورة الدوسري',
          'deliveryAddress': 'العليا، الرياض',
          'status': 'Received',
          'statusText': 'تم الاستلام',
          'statusColor': '#10B981',
          'scheduledTimeText': '01:00 م',
          'isDelivering': false,
        }
      ],
    };

    test('maps active boxes JSON to domain list', () {
      final dto = DriverActiveBoxesResponseDto.fromJson(boxesJson);
      final entities = dto.toEntityList();

      expect(entities, hasLength(2));
      expect(entities[0].boxId, '3c19356d-f432-47d5-89f5-7e82845c8531');
      expect(entities[0].boxCode, 'BX-10256');
      expect(entities[0].customerName, 'محمد الفضلي');
      expect(entities[0].deliveryAddress, 'السليمانية، الرياض');
      expect(entities[0].status, 'OnDelivery');
      expect(entities[0].statusText, 'خارج للتوصيل');
      expect(entities[0].statusColor, '#6366F1');
      expect(entities[0].scheduledTimeText, '12:30 م');
      expect(entities[0].isDelivering, isTrue);

      expect(entities[1].boxId, '7b81923e-e234-45ab-9c12-781920394851');
      expect(entities[1].boxCode, 'BX-10257');
      expect(entities[1].isDelivering, isFalse);
    });

    test('defensively handles null boxes and null box elements', () {
      const dto = DriverActiveBoxesResponseDto(boxes: null);
      expect(dto.toEntityList(), isEmpty);

      const dtoWithNulls = DriverActiveBoxesResponseDto(
        boxes: [null, DriverActiveBoxDto()],
      );
      final entities = dtoWithNulls.toEntityList();
      expect(entities, hasLength(1));
      expect(entities[0].boxId, '');
      expect(entities[0].boxCode, '');
      expect(entities[0].customerName, '');
      expect(entities[0].deliveryAddress, '');
      expect(entities[0].status, '');
      expect(entities[0].statusText, '');
      expect(entities[0].statusColor, isNull);
      expect(entities[0].scheduledTimeText, '');
      expect(entities[0].isDelivering, isFalse);
    });
  });

  group('DriverCurrentLocationResponseDto & Polyline Parsing', () {
    final locationJson = {
      'latitude': 29.3375,
      'longitude': 47.9784,
      'heading': 180.0,
      'speed': 45.0,
      'destinationLatitude': 29.3400,
      'destinationLongitude': 47.9800,
      'statusBadgeText': 'مباشر',
      'timeAgoText': 'الآن',
      'streetName': 'شارع جمال عبد الناصر',
      'areaName': 'الشويخ',
      'routePolyline': '29.3375,47.9784;29.3400,47.9800',
      'recordedAt': '2026-09-23T18:00:00Z',
    };

    test('maps valid location JSON and parses polyline', () {
      final dto = DriverCurrentLocationResponseDto.fromJson(locationJson);
      final entity = dto.toEntity();

      expect(entity.latitude, 29.3375);
      expect(entity.longitude, 47.9784);
      expect(entity.heading, 180.0);
      expect(entity.speed, 45.0);
      expect(entity.destinationLatitude, 29.3400);
      expect(entity.destinationLongitude, 47.9800);
      expect(entity.statusBadgeText, 'مباشر');
      expect(entity.timeAgoText, 'الآن');
      expect(entity.streetName, 'شارع جمال عبد الناصر');
      expect(entity.areaName, 'الشويخ');
      expect(entity.isOffline, isFalse);
      expect(entity.routePoints, hasLength(2));
      expect(entity.routePoints.first.latitude, 29.3375);
      expect(entity.routePoints.first.longitude, 47.9784);
      expect(entity.routePoints.last.latitude, 29.3400);
      expect(entity.routePoints.last.longitude, 47.9800);
    });

    test('handles offline/null coordinates without crashing', () {
      const dto = DriverCurrentLocationResponseDto();
      final entity = dto.toEntity();

      expect(entity.latitude, isNull);
      expect(entity.longitude, isNull);
      expect(entity.isOffline, isTrue);
      expect(entity.routePoints, isEmpty);
      expect(entity.statusBadgeText, '');
      expect(entity.timeAgoText, '');
      expect(entity.streetName, '');
      expect(entity.areaName, '');
    });

    test('parses polyline correctly and ignores invalid points', () {
      expect(parseRoutePolyline(null), isEmpty);
      expect(parseRoutePolyline(''), isEmpty);
      expect(parseRoutePolyline('invalid'), isEmpty);
      expect(parseRoutePolyline('29.3375,47.9784'), isEmpty); // < 2 points
      expect(
        parseRoutePolyline('29.3375,47.9784;invalid;29.3400,47.9800'),
        hasLength(2),
      );
      expect(
        parseRoutePolyline('29.3375,47.9784;190.0,47.9800;29.3400,47.9800'),
        hasLength(2),
      ); // 190.0 invalid latitude
      expect(
        parseRoutePolyline('29.3375,47.9784;29.3400,200.0'),
        isEmpty,
      ); // second point invalid longitude -> leaves only 1 valid point -> < 2 points
    });
  });
}
