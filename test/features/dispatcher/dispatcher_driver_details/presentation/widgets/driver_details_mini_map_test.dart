import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_current_location_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/domain/entities/driver_location_point_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/widgets/driver_details_mini_map.dart';

void main() {
  group('DriverDetailsMapPresentationHelper', () {
    test('builds driver-only marker with heading', () {
      final markers = DriverDetailsMapPresentationHelper.buildMarkers(
        driverLat: 29.3375,
        driverLng: 48.0211,
        heading: 90.0,
      );

      expect(markers.length, 1);
      final driverMarker = markers.firstWhere(
        (m) => m.markerId.value == 'driver',
      );
      expect(driverMarker.position.latitude, 29.3375);
      expect(driverMarker.position.longitude, 48.0211);
      expect(driverMarker.rotation, 90.0);
    });

    test('builds driver and destination markers when destination exists', () {
      final markers = DriverDetailsMapPresentationHelper.buildMarkers(
        driverLat: 29.3375,
        driverLng: 48.0211,
        destLat: 29.3500,
        destLng: 48.0300,
      );

      expect(markers.length, 2);
      expect(markers.any((m) => m.markerId.value == 'driver'), isTrue);
      expect(markers.any((m) => m.markerId.value == 'destination'), isTrue);

      final destMarker = markers.firstWhere(
        (m) => m.markerId.value == 'destination',
      );
      expect(destMarker.position.latitude, 29.3500);
      expect(destMarker.position.longitude, 48.0300);
    });

    test('buildPolylines returns empty set with fewer than two points', () {
      final emptyResult = DriverDetailsMapPresentationHelper.buildPolylines(
        const [],
        polylineColor: Colors.blue,
      );
      expect(emptyResult, isEmpty);

      final singlePointResult =
          DriverDetailsMapPresentationHelper.buildPolylines(const [
            DriverLocationPointEntity(latitude: 29.0, longitude: 48.0),
          ], polylineColor: Colors.blue);
      expect(singlePointResult, isEmpty);
    });

    test('buildPolylines returns polyline with two or more points', () {
      final polylines =
          DriverDetailsMapPresentationHelper.buildPolylines(const [
            DriverLocationPointEntity(latitude: 29.3375, longitude: 48.0211),
            DriverLocationPointEntity(latitude: 29.3400, longitude: 48.0250),
            DriverLocationPointEntity(latitude: 29.3500, longitude: 48.0300),
          ], polylineColor: Colors.purple);

      expect(polylines.length, 1);
      final routePolyline = polylines.first;
      expect(routePolyline.polylineId.value, 'driver_route');
      expect(routePolyline.points.length, 3);
      expect(routePolyline.points.first.latitude, 29.3375);
      expect(routePolyline.points.last.latitude, 29.3500);
      expect(routePolyline.color, Colors.purple);
    });

    test(
      'calculateBounds returns null or single center when points are insufficient',
      () {
        final bounds = DriverDetailsMapPresentationHelper.calculateBounds(
          driverLat: 29.3375,
          driverLng: 48.0211,
        );
        expect(bounds, isNull);

        final multiBounds = DriverDetailsMapPresentationHelper.calculateBounds(
          driverLat: 29.3375,
          driverLng: 48.0211,
          destLat: 29.3500,
          destLng: 48.0300,
        );
        expect(multiBounds, isNotNull);
        expect(multiBounds!.southwest.latitude, 29.3375);
        expect(multiBounds.northeast.latitude, 29.3500);
      },
    );
  });

  group('DriverDetailsMiniMap Widget', () {
    testWidgets('does not render GoogleMap when location is offline', (
      tester,
    ) async {
      const offlineLocation = DriverCurrentLocationEntity(
        latitude: null,
        longitude: null,
        statusBadgeText: 'Offline',
        timeAgoText: 'Now',
        streetName: '',
        areaName: '',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DriverDetailsMiniMap(location: offlineLocation)),
        ),
      );

      expect(find.byType(GoogleMap), findsNothing);
    });
  });
}
