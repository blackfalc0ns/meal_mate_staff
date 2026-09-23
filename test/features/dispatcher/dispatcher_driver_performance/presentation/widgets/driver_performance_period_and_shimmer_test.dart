import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/widget/shimmer_widget.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/domain/entities/driver_performance_period.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_comparison_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_date_filter_chip.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_overview_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_performance/presentation/widgets/driver_performance_period_sheet.dart';

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

  group('DriverPerformanceDateFilterChip and PeriodSheet Tests', () {
    testWidgets(
      'DriverPerformanceDateFilterChip displays dynamic label and triggers onTap',
      (tester) async {
        bool tapped = false;
        await tester.pumpWidget(
          _buildTestableWidget(
            child: DriverPerformanceDateFilterChip(
              label: '1 May - 7 May',
              onTap: () => tapped = true,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('1 May - 7 May'), findsOneWidget);
        await tester.tap(find.byType(DriverPerformanceDateFilterChip));
        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'DriverPerformancePeriodSheet renders all 6 choices and selects preset',
      (tester) async {
        DriverPerformancePeriod? selected;
        await tester.pumpWidget(
          _buildTestableWidget(
            child: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    await DriverPerformancePeriodSheet.show(
                      context,
                      selectedPeriod: DriverPerformancePeriod.last7Days,
                      onPeriodSelected: (p) => selected = p,
                      onCustomRangeSelected: (from, to) {},
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();

        expect(find.byType(DriverPerformancePeriodSheet), findsOneWidget);
        // Verify all 6 period labels appear in Arabic
        expect(find.text('اليوم'), findsOneWidget);
        expect(find.text('أمس'), findsOneWidget);
        expect(find.text('آخر 7 أيام'), findsOneWidget);
        expect(find.text('آخر 30 يوماً'), findsOneWidget);
        expect(find.text('هذا الشهر'), findsOneWidget);
        expect(find.text('مخصص'), findsOneWidget);

        // Tap 'Last 30 days'
        await tester.tap(find.text('آخر 30 يوماً'));
        await tester.pumpAndSettle();

        expect(selected, DriverPerformancePeriod.last30Days);
      },
    );
  });

  group('Shimmer Widgets Tests', () {
    testWidgets(
      'DriverPerformanceOverviewShimmer renders screen-shaped placeholders',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 870 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          _buildTestableWidget(child: const DriverPerformanceOverviewShimmer()),
        );
        await tester.pump();

        expect(find.byType(DriverPerformanceOverviewShimmer), findsOneWidget);
        // ShimmerWidget should be present in multiple places (KPIs, table, distribution, podium)
        expect(find.byType(ShimmerWidget), findsWidgets);
      },
    );

    testWidgets(
      'DriverPerformanceComparisonShimmer renders horizontal comparison cards',
      (tester) async {
        tester.view.physicalSize = const Size(390 * 2, 870 * 2);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          _buildTestableWidget(
            child: const DriverPerformanceComparisonShimmer(),
          ),
        );
        await tester.pump();

        expect(find.byType(DriverPerformanceComparisonShimmer), findsOneWidget);
        expect(find.byType(ShimmerWidget), findsWidgets);
      },
    );
  });
}
