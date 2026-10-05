import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_navigation_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_route_status.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_navigation_launcher.dart';

void main() {
  late DriverMapNavigationLauncher launcher;
  Uri? launchedUri;
  bool shouldSucceed = true;

  setUp(() {
    launchedUri = null;
    shouldSucceed = true;
    launcher = DriverMapNavigationLauncher(
      urlOpener: (uri) async {
        launchedUri = uri;
        return shouldSucceed;
      },
    );
  });

  group('DriverMapNavigationLauncher', () {
    test('opens exact server URL when canNavigate is true and stop IDs match', () async {
      const serverUrl =
          'https://www.google.com/maps/dir/?api=1&destination=29.338%2C48.023&travelmode=driving&dir_action=navigate';
      const navigation = DriverMapNavigationEntity(
        destinationStopId: 'stop-1',
        routeStatus: DriverMapRouteStatus.ready,
        googleMapsUrl: serverUrl,
        canNavigate: true,
      );

      final success = await launcher.launchNavigation(
        navigation: navigation,
        selectedStopId: 'stop-1',
      );

      expect(success, isTrue);
      expect(launchedUri?.toString(), serverUrl);
    });

    test('refuses to launch if canNavigate is false', () async {
      const navigation = DriverMapNavigationEntity(
        destinationStopId: 'stop-1',
        routeStatus: DriverMapRouteStatus.completed,
        googleMapsUrl: 'https://maps.google.com',
        canNavigate: false,
      );

      final success = await launcher.launchNavigation(
        navigation: navigation,
        selectedStopId: 'stop-1',
      );

      expect(success, isFalse);
      expect(launchedUri, isNull);
    });

    test('refuses to launch if selectedStopId does not match destinationStopId', () async {
      const navigation = DriverMapNavigationEntity(
        destinationStopId: 'stop-1',
        routeStatus: DriverMapRouteStatus.ready,
        googleMapsUrl: 'https://maps.google.com',
        canNavigate: true,
      );

      final success = await launcher.launchNavigation(
        navigation: navigation,
        selectedStopId: 'stop-2', // Mismatch!
      );

      expect(success, isFalse);
      expect(launchedUri, isNull);
    });

    test('allows launch if canNavigate is true even when routeStatus is unavailable', () async {
      const serverUrl =
          'https://www.google.com/maps/dir/?api=1&destination=29.338%2C48.023&travelmode=driving&dir_action=navigate';
      const navigation = DriverMapNavigationEntity(
        destinationStopId: 'stop-1',
        routeStatus: DriverMapRouteStatus.unavailable,
        googleMapsUrl: serverUrl,
        canNavigate: true,
      );

      final success = await launcher.launchNavigation(
        navigation: navigation,
        selectedStopId: 'stop-1',
      );

      expect(success, isTrue);
      expect(launchedUri?.toString(), serverUrl);
    });

    test('returns false without crashing when urlOpener throws exception', () async {
      launcher = DriverMapNavigationLauncher(
        urlOpener: (_) async => throw Exception('Cannot open URL'),
      );

      const navigation = DriverMapNavigationEntity(
        destinationStopId: 'stop-1',
        routeStatus: DriverMapRouteStatus.ready,
        googleMapsUrl: 'https://maps.google.com',
        canNavigate: true,
      );

      final success = await launcher.launchNavigation(
        navigation: navigation,
        selectedStopId: 'stop-1',
      );

      expect(success, isFalse);
    });
  });
}
