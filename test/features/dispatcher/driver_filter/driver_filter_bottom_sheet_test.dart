import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/driver_filter/domain/entities/driver_filter_criteria_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/driver_filter/presentation/widgets/driver_filter_action_buttons.dart';
import 'package:meal_mate_delivery/features/dispatcher/driver_filter/presentation/widgets/driver_filter_area_section.dart';
import 'package:meal_mate_delivery/features/dispatcher/driver_filter/presentation/widgets/driver_filter_bottom_sheet.dart';
import 'package:meal_mate_delivery/features/dispatcher/driver_filter/presentation/widgets/driver_filter_distance_section.dart';
import 'package:meal_mate_delivery/features/dispatcher/driver_filter/presentation/widgets/driver_filter_header.dart';
import 'package:meal_mate_delivery/features/dispatcher/driver_filter/presentation/widgets/driver_filter_orders_section.dart';
import 'package:meal_mate_delivery/features/dispatcher/driver_filter/presentation/widgets/driver_filter_rating_section.dart';
import 'package:meal_mate_delivery/features/dispatcher/driver_filter/presentation/widgets/driver_filter_search_section.dart';
import 'package:meal_mate_delivery/features/dispatcher/driver_filter/presentation/widgets/driver_filter_status_section.dart';

Widget _buildTestableWidget({
  required Widget child,
  Locale locale = const Locale('ar'),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6744C2)),
    ),
    home: Scaffold(body: child),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DriverFilterBottomSheet Tests', () {
    testWidgets('renders all major sections and components in RTL Arabic', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(child: const DriverFilterBottomSheet()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DriverFilterHeader), findsOneWidget);
      expect(find.byType(DriverFilterAreaSection), findsOneWidget);
      expect(find.byType(DriverFilterStatusSection), findsOneWidget);
      expect(find.byType(DriverFilterRatingSection), findsOneWidget);
      expect(find.byType(DriverFilterDistanceSection), findsOneWidget);
      expect(find.byType(DriverFilterOrdersSection), findsOneWidget);
      expect(find.byType(DriverFilterSearchSection), findsOneWidget);
      expect(find.byType(DriverFilterActionButtons), findsOneWidget);

      expect(find.text('تصفية السائقين'), findsOneWidget);
      expect(find.text('حسب المناطق'), findsOneWidget);
      expect(find.text('حسب الحالة'), findsOneWidget);
      expect(find.text('حسب التقييم'), findsOneWidget);
      expect(find.text('حسب المسافة'), findsOneWidget);
      expect(find.text('حسب عدد الطلبات المكتملة'), findsOneWidget);
      expect(find.text('بحث باسم السائق أو ID'), findsOneWidget);
      expect(find.text('إعادة تعيين الفلاتر'), findsOneWidget);
      expect(find.text('عرض النتائج'), findsOneWidget);
    });

    testWidgets('renders properly in English locale', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(
          locale: const Locale('en'),
          child: const DriverFilterBottomSheet(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Filter Drivers'), findsOneWidget);
      expect(find.text('By Area'), findsOneWidget);
      expect(find.text('By Status'), findsOneWidget);
      expect(find.text('By Rating'), findsOneWidget);
      expect(find.text('By Distance'), findsOneWidget);
      expect(find.text('By Completed Orders'), findsOneWidget);
      expect(find.text('Reset Filters'), findsOneWidget);
      expect(find.text('Show Results'), findsOneWidget);
    });

    testWidgets('allows selecting filters and applying criteria', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 900 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      DriverFilterCriteriaEntity? appliedCriteria;

      await tester.pumpWidget(
        _buildTestableWidget(
          child: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  DriverFilterBottomSheet.show(
                    context: context,
                    onApply: (c) => appliedCriteria = c,
                  );
                },
                child: const Text('Open'),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open sheet
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(DriverFilterBottomSheet), findsOneWidget);

      // Tap Salmiya area
      await tester.tap(find.text('السالمية'));
      await tester.pumpAndSettle();

      // Tap Available status
      await tester.tap(find.text('متاح'));
      await tester.pumpAndSettle();

      // Tap Apply Results
      await tester.tap(find.text('عرض النتائج'));
      await tester.pumpAndSettle();

      // Sheet should be popped and criteria applied
      expect(appliedCriteria, isNotNull);
      expect(appliedCriteria?.selectedArea, 'salmiya');
      expect(appliedCriteria?.selectedStatus, 'available');
    });
  });
}
