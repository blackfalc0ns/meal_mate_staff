import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/map/data/mapper/driver_map_mapper.dart';
import 'package:meal_mate_delivery/features/driver/map/data/models/response/driver_map_route_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_route_status.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_unavailable_reason.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_delivery_status.dart';

void main() {
  Map<String, dynamic> readFixture(String name) {
    final file = File('test/features/driver/map/fixtures/$name');
    return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
  }

  group('DriverMap DTO and Mapper Tests', () {
    test('maps route_ready_fixture correctly', () {
      final json = readFixture('route_ready_fixture.json');
      final dto = DriverMapRouteResponseDto.fromJson(json);
      final entity = dto.toEntity();

      expect(entity.tripId, '3f6b1c2e-1111-4a2b-9c3d-000000000001');
      expect(entity.tripCode, 'TRP-1256');
      expect(entity.totalStopsCount, 2);
      expect(entity.completedStopsCount, 0);
      expect(entity.stops.length, 2);

      // Order of stops preserved
      expect(entity.stops[0].id, '9a7c1d2e-3333-4a2b-9c3d-000000000003');
      expect(entity.stops[0].sequenceBadge, '1/2');
      expect(entity.stops[0].status, DriverDeliveryStatus.inProgress);
      expect(entity.stops[0].statusText, 'خارج التوصيل');
      expect(entity.stops[0].statusColor, 'green');
      expect(entity.stops[0].isCurrent, isTrue);
      expect(entity.stops[0].customerPhone, ''); // Always empty
      expect(entity.stops[0].addressShort, 'السالمية');
      expect(entity.stops[0].area, 'السالمية');

      expect(entity.stops[1].id, '4b2e5f6a-4444-4a2b-9c3d-000000000004');
      expect(entity.stops[1].sequenceBadge, '2/2');
      expect(entity.stops[1].status, DriverDeliveryStatus.pending);
      expect(entity.stops[1].statusText, 'في الطريق للعميل');
      expect(entity.stops[1].statusColor, 'orange');
      expect(entity.stops[1].isCurrent, isFalse);
      expect(entity.stops[1].customerPhone, ''); // Ignored even if backend sends it
      expect(entity.stops[1].addressShort, 'الروضة');
      expect(entity.stops[1].area, 'الروضة');

      // Focused stop
      expect(entity.focusedStop.id, '9a7c1d2e-3333-4a2b-9c3d-000000000003');
      expect(entity.focusedStop.isCurrent, isTrue);

      // Navigation
      final nav = entity.navigation;
      expect(nav, isNotNull);
      expect(nav!.destinationStopId, '9a7c1d2e-3333-4a2b-9c3d-000000000003');
      expect(nav.routeStatus, DriverMapRouteStatus.ready);
      expect(nav.unavailableReason, isNull);
      expect(nav.encodedPolyline, '_p~iF~ps|U_ulLnnqC');
      expect(nav.polylineEncoding, 'google_polyline5');
      expect(nav.distanceMeters, 5200);
      expect(nav.durationSeconds, 480);
      expect(nav.canNavigate, isTrue);
      expect(
        nav.googleMapsUrl,
        'https://www.google.com/maps/dir/?api=1&destination=29.338%2C48.023&travelmode=driving&dir_action=navigate',
      );

      // Origin
      expect(nav.origin, isNotNull);
      expect(nav.origin!.latitude, 29.3375);
      expect(nav.origin!.longitude, 48.028);
      expect(nav.origin!.label, 'موقعك الحالي');
      expect(nav.origin!.source, 'tracking');
      expect(nav.origin!.isStale, isFalse);
      expect(nav.origin!.heading, 90.0);
      expect(nav.origin!.recordedAtUtc, DateTime.parse('2026-10-05T07:59:50Z'));

      // Destination
      expect(nav.destination, isNotNull);
      expect(nav.destination!.latitude, 29.338);
      expect(nav.destination!.longitude, 48.023);
      expect(nav.destination!.label, 'محمد علي');
      expect(nav.destination!.source, 'trip_stop');
    });

    test('maps route_unavailable_fixture correctly', () {
      final json = readFixture('route_unavailable_fixture.json');
      final dto = DriverMapRouteResponseDto.fromJson(json);
      final entity = dto.toEntity();

      final nav = entity.navigation;
      expect(nav, isNotNull);
      expect(nav!.routeStatus, DriverMapRouteStatus.unavailable);
      expect(
        nav.unavailableReason,
        DriverMapUnavailableReason.driverLocationStale,
      );
      expect(nav.encodedPolyline, isNull);
      expect(nav.distanceMeters, isNull);
      expect(nav.durationSeconds, isNull);
      expect(nav.canNavigate, isTrue); // External navigation allowed if destination exists
    });

    test('maps route_completed_fixture correctly', () {
      final json = readFixture('route_completed_fixture.json');
      final dto = DriverMapRouteResponseDto.fromJson(json);
      final entity = dto.toEntity();

      final nav = entity.navigation;
      expect(nav, isNotNull);
      expect(nav!.routeStatus, DriverMapRouteStatus.completed);
      expect(nav.unavailableReason, isNull);
      expect(nav.encodedPolyline, isNull);
      expect(nav.distanceMeters, 0); // 0 distance preserved
      expect(nav.durationSeconds, 0);
      expect(nav.canNavigate, isFalse);
      expect(nav.googleMapsUrl, isNull);
      expect(entity.stops.first.status, DriverDeliveryStatus.delivered);
    });

    test('maps route_navigation_null_fixture with null coordinates safely', () {
      final json = readFixture('route_navigation_null_fixture.json');
      final dto = DriverMapRouteResponseDto.fromJson(json);
      final entity = dto.toEntity();

      expect(entity.navigation, isNull);
      expect(entity.stops.length, 1);
      expect(entity.stops[0].latitude, isNull);
      expect(entity.stops[0].longitude, isNull);
    });
  });
}
