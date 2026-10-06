import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_driver_marker_item.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_marker_bitmap_factory.dart';
import 'package:meal_mate_delivery/features/driver/map/presentation/widgets/driver_map_stop_marker_item.dart';

Widget _buildTestApp(Widget child) {
  return MaterialApp(
    locale: const Locale('ar'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: AppTheme.lightTheme,
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('DriverMapDriverMarkerItem', () {
    testWidgets('renders person icon inside circular avatar', (tester) async {
      await tester.pumpWidget(_buildTestApp(const DriverMapDriverMarkerItem()));
      await tester.pumpAndSettle();

      expect(find.byType(DriverMapDriverMarkerItem), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
  });

  group('DriverMapStopMarkerItem', () {
    testWidgets('renders box icon and box code text when selected', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const DriverMapStopMarkerItem(
            boxCode: '#BX-1256',
            isSelected: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DriverMapStopMarkerItem), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
      expect(find.text('#BX-1256'), findsOneWidget);
    });

    testWidgets('renders box icon and box code when not selected', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const DriverMapStopMarkerItem(
            boxCode: '#BX-9999',
            isSelected: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('#BX-9999'), findsOneWidget);
      expect(find.byType(SvgPicture), findsOneWidget);
    });

    testWidgets('does not render pill when boxCode is empty', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          const DriverMapStopMarkerItem(
            boxCode: '',
            isSelected: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text(''), findsNothing);
      expect(find.byType(SvgPicture), findsOneWidget);
    });
  });

  group('DriverMapMarkerBitmapFactory', () {
    test('cache keys are consistent and distinct', () {
      final key1 = DriverMapMarkerBitmapFactory.stopCacheKey('1', '#BX-1', isSelected: false);
      final key1Sel = DriverMapMarkerBitmapFactory.stopCacheKey('1', '#BX-1', isSelected: true);
      final key2 = DriverMapMarkerBitmapFactory.stopCacheKey('2', '#BX-2', isSelected: false);

      expect(key1, isNot(equals(key1Sel)));
      expect(key1, isNot(equals(key2)));
      expect(DriverMapMarkerBitmapFactory.driverCacheKey, equals('driver_marker'));
    });

    testWidgets('creates or falls back to descriptor safely in tests', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        _buildTestApp(
          Builder(
            builder: (ctx) {
              capturedContext = ctx;
              return const SizedBox();
            },
          ),
        ),
      );

      final driverDescriptor = await tester.runAsync(
        () => DriverMapMarkerBitmapFactory.createDriverMarker(capturedContext),
      );
      expect(driverDescriptor, isA<BitmapDescriptor>());

      final stopDescriptor = await tester.runAsync(
        () => DriverMapMarkerBitmapFactory.createStopMarker(
          capturedContext,
          stopId: 'stop-1',
          boxCode: '#BX-100',
          isSelected: true,
        ),
      );
      expect(stopDescriptor, isA<BitmapDescriptor>());
    });
  });
}
