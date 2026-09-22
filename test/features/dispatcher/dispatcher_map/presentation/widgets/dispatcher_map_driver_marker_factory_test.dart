import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/domain/entities/dispatcher_map_driver_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_driver_marker_factory.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/presentation/widgets/dispatcher_map_marker_item.dart';

void main() {
  group('DispatcherMapMarkerBitmapFactory Cache Keys', () {
    test('cacheKey changes when appearance fields change', () {
      const driver1 = DispatcherMapDriverEntity(
        id: 'd1',
        name: 'Ali',
        boxId: 'B1',
        status: DispatcherMapDriverStatus.inDelivery,
        avatarUrl: 'https://img.com/1.png',
      );

      final key1 = DispatcherMapMarkerBitmapFactory.cacheKey(driver1, isSelected: false);
      final keySelected = DispatcherMapMarkerBitmapFactory.cacheKey(driver1, isSelected: true);
      expect(key1, isNot(equals(keySelected)));

      final driver2 = driver1.copyWith(status: DispatcherMapDriverStatus.hasIssue);
      final keyIssue = DispatcherMapMarkerBitmapFactory.cacheKey(driver2, isSelected: false);
      expect(key1, isNot(equals(keyIssue)));

      // Location change does NOT change the cache key!
      final driverLocationChanged = driver1.copyWith(latitude: 30.0, longitude: 50.0);
      final keyLocation = DispatcherMapMarkerBitmapFactory.cacheKey(driverLocationChanged, isSelected: false);
      expect(key1, equals(keyLocation));
    });
  });

  group('DispatcherMapMarkerItem Widget', () {
    Widget buildSubject(DispatcherMapDriverEntity driver, {bool isSelected = false}) {
      return MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: DispatcherMapMarkerItem(
              driver: driver,
              isSelected: isSelected,
            ),
          ),
        ),
      );
    }

    testWidgets('renders all driver statuses without error', (tester) async {
      for (final status in DispatcherMapDriverStatus.values) {
        final driver = DispatcherMapDriverEntity(
          id: 'drv-test',
          name: 'Test Driver',
          boxId: 'BOX-99',
          status: status,
        );

        await tester.pumpWidget(buildSubject(driver));
        await tester.pumpAndSettle();

        expect(find.text('BOX-99'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('calls onAvatarResolved when avatar is missing/null', (tester) async {
      bool resolved = false;
      const driver = DispatcherMapDriverEntity(
        id: 'drv-test',
        name: 'Test Driver',
        boxId: 'BOX-99',
        status: DispatcherMapDriverStatus.inDelivery,
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: DispatcherMapMarkerItem(
                driver: driver,
                onAvatarResolved: (_) => resolved = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(resolved, isTrue);
    });

    testWidgets('DispatcherMapMarkerBitmapFactory creates or falls back to descriptor', (tester) async {
      const driver = DispatcherMapDriverEntity(
        id: 'drv-test',
        name: 'Test Driver',
        boxId: 'BOX-99',
        status: DispatcherMapDriverStatus.inDelivery,
      );

      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (ctx) {
              capturedContext = ctx;
              return const Scaffold();
            },
          ),
        ),
      );

      final descriptor = await tester.runAsync(() => DispatcherMapMarkerBitmapFactory.create(
        capturedContext,
        driver,
        isSelected: false,
      ));

      expect(descriptor, isA<BitmapDescriptor>());
    });
  });
}
