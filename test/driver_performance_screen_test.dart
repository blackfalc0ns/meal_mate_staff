import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/domain/entities/driver_performance_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/screens/driver_performance_screen.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_performance_deliveries_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_performance_distance_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_performance_excellence_banner.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_performance_header.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_performance_on_time_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_performance_period_toggle.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_performance_section_title.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_performance_summary_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_profile/presentation/widgets/driver_performance_working_hours_card.dart';

void main() {
  Widget buildSubject({
    DriverPerformanceEntity? performance,
    Locale locale = const Locale('ar'),
    bool showBackButton = true,
    VoidCallback? onBackTap,
    VoidCallback? onViewDetailsTap,
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      home: DriverPerformanceScreen(
        performance: performance,
        showBackButton: showBackButton,
        onBackTap: onBackTap,
        onViewDetailsTap: onViewDetailsTap,
      ),
    );
  }

  testWidgets('renders all major components and cards in RTL Arabic', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    expect(find.byType(DriverPerformanceHeader), findsOneWidget);
    expect(find.byType(DriverPerformancePeriodToggle), findsOneWidget);
    expect(find.byType(DriverPerformanceSummaryCard), findsOneWidget);
    expect(find.byType(DriverPerformanceSectionTitle), findsOneWidget);
    expect(find.byType(DriverPerformanceOnTimeCard), findsOneWidget);
    expect(find.byType(DriverPerformanceDeliveriesCard), findsOneWidget);
    expect(find.byType(DriverPerformanceDistanceCard), findsOneWidget);
    expect(find.byType(DriverPerformanceWorkingHoursCard), findsOneWidget);
    expect(find.byType(DriverPerformanceExcellenceBanner), findsOneWidget);

    expect(find.text('الأداء'), findsOneWidget);
    expect(find.text('اليوم'), findsOneWidget);
    expect(find.text('هذا الأسبوع'), findsOneWidget);
    expect(find.text('أنت متصل'), findsOneWidget);
    expect(find.text('إجمالي الطلبات'), findsOneWidget);
    expect(find.text('نظرة عامة على الأداء'), findsOneWidget);
    expect(find.text('أداء رائع اليوم! استمر بنفس التميز'), findsOneWidget);
    expect(find.text('عرض التفاصيل'), findsOneWidget);
  });

  testWidgets('renders all major components in English LTR without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject(locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Performance'), findsOneWidget);
    expect(find.text('Today'), findsOneWidget);
    expect(find.text('This Week'), findsOneWidget);
    expect(find.text('You are online'), findsOneWidget);
    expect(find.text('Total Orders'), findsOneWidget);
    expect(find.text('Performance Overview'), findsOneWidget);
    expect(
      find.text('Great performance today! Keep up the excellence'),
      findsOneWidget,
    );
    expect(find.text('View Details'), findsOneWidget);
  });

  testWidgets('switching period toggle updates displayed data', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Default is today: total orders 8
    expect(find.text('8'), findsWidgets);

    // Tap "هذا الأسبوع"
    await tester.tap(find.text('هذا الأسبوع'));
    await tester.pumpAndSettle();

    // Now week is selected: total orders 48
    expect(find.text('48'), findsOneWidget);
  });

  testWidgets('tapping back button calls onBackTap', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool backTapped = false;
    await tester.pumpWidget(buildSubject(
      onBackTap: () => backTapped = true,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(backTapped, isTrue);
  });

  testWidgets('tapping view details calls onViewDetailsTap', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    bool detailsTapped = false;
    await tester.pumpWidget(buildSubject(
      onViewDetailsTap: () => detailsTapped = true,
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.text('عرض التفاصيل'));
    await tester.pumpAndSettle();

    expect(detailsTapped, isTrue);
  });
}
