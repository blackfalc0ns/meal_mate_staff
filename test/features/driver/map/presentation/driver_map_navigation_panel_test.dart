import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_location_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_navigation_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_route_status.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_unavailable_reason.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_navigation_panel.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_shimmer.dart';

void main() {
  Widget buildPanel({
    DriverMapNavigationEntity? navigation,
    bool isRefreshing = false,
    VoidCallback? onNavigatePressed,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: DriverMapNavigationPanel(
          navigation: navigation,
          isRefreshing: isRefreshing,
          onNavigatePressed: onNavigatePressed,
        ),
      ),
    );
  }

  testWidgets('renders shimmer when isRefreshing is true', (tester) async {
    await tester.pumpWidget(
      buildPanel(
        navigation: const DriverMapNavigationEntity(
          routeStatus: DriverMapRouteStatus.ready,
          canNavigate: true,
        ),
        isRefreshing: true,
      ),
    );

    expect(find.byType(DriverMapNavigationShimmer), findsOneWidget);
  });

  testWidgets('renders ready navigation metrics and button when canNavigate is true', (tester) async {
    var pressed = false;
    await tester.pumpWidget(
      buildPanel(
        navigation: DriverMapNavigationEntity(
          routeStatus: DriverMapRouteStatus.ready,
          canNavigate: true,
          distanceMeters: 5200,
          durationSeconds: 480,
          estimatedArrivalAtUtc: DateTime.utc(2026, 10, 5, 12, 30),
          googleMapsUrl: 'https://www.google.com/maps/dir/?api=1',
          origin: const DriverMapLocationEntity(
            latitude: 29.3,
            longitude: 48.0,
            label: 'Origin',
            source: 'tracking',
          ),
          destination: const DriverMapLocationEntity(
            latitude: 29.4,
            longitude: 48.1,
            label: 'Destination',
            source: 'trip_stop',
          ),
        ),
        onNavigatePressed: () => pressed = true,
      ),
    );

    expect(find.textContaining('5.2'), findsOneWidget);
    expect(find.textContaining('8'), findsOneWidget);
    expect(find.byIcon(Icons.navigation_rounded), findsOneWidget);

    await tester.tap(find.byIcon(Icons.navigation_rounded));
    expect(pressed, isTrue);
  });

  testWidgets('hides navigation button when canNavigate is false', (tester) async {
    await tester.pumpWidget(
      buildPanel(
        navigation: const DriverMapNavigationEntity(
          routeStatus: DriverMapRouteStatus.completed,
          canNavigate: false,
        ),
      ),
    );

    expect(find.byIcon(Icons.navigation_rounded), findsNothing);
  });

  testWidgets('renders business notice when route is unavailable', (tester) async {
    await tester.pumpWidget(
      buildPanel(
        navigation: const DriverMapNavigationEntity(
          routeStatus: DriverMapRouteStatus.unavailable,
          unavailableReason: DriverMapUnavailableReason.driverLocationMissing,
          canNavigate: true,
        ),
        onNavigatePressed: () {},
      ),
    );

    expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    expect(find.byIcon(Icons.navigation_rounded), findsOneWidget);
  });
}
