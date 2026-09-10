import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/home/presentation/screens/dispatcher_home_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/home/presentation/widgets/dispatcher_home_alert_banner.dart';
import 'package:meal_mate_delivery/features/dispatcher/home/presentation/widgets/dispatcher_home_areas_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/home/presentation/widgets/dispatcher_home_drivers_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/home/presentation/widgets/dispatcher_home_header.dart';
import 'package:meal_mate_delivery/features/dispatcher/home/presentation/widgets/dispatcher_home_kpi_row.dart';
import 'package:meal_mate_delivery/features/dispatcher/home/presentation/widgets/dispatcher_home_map_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/home/presentation/widgets/dispatcher_home_operations_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/home/presentation/widgets/dispatcher_home_quick_actions.dart';

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
    onGenerateRoute: RouteGenerator.getRoute,
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DispatcherHomeScreen Widget Tests', () {
    testWidgets('renders all home screen sections and fake data in Arabic', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 1200 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(child: const DispatcherHomeScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherHomeScreen), findsOneWidget);
      expect(find.byType(DispatcherHomeHeader), findsOneWidget);
      expect(find.byType(DispatcherHomeKpiRow), findsOneWidget);
      expect(find.byType(DispatcherHomeQuickActions), findsOneWidget);
      expect(find.byType(DispatcherHomeMapCard), findsOneWidget);
      expect(find.byType(DispatcherHomeOperationsCard), findsOneWidget);
      expect(find.byType(DispatcherHomeDriversCard), findsOneWidget);
      expect(find.byType(DispatcherHomeAreasCard), findsOneWidget);
      expect(find.byType(DispatcherHomeAlertBanner), findsOneWidget);

      // Verify Header
      expect(find.text('مرحبًا'), findsOneWidget);
      expect(find.text('كل شيء تحت السيطرة اليوم 👋'), findsOneWidget);
      expect(find.text('مطعم MealMate الكويت'), findsOneWidget);
      expect(find.text('Dispatcher'), findsOneWidget);

      // Verify KPI Metrics
      expect(find.text('128'), findsOneWidget);
      expect(find.text('58'), findsWidgets);
      expect(find.text('23'), findsWidgets);
      expect(find.text('2'), findsOneWidget);

      // Verify Quick Actions
      expect(find.text('إجراءات سريعة'), findsOneWidget);
      expect(find.text('تعيين سائق'), findsOneWidget);
      expect(find.text('حل المشكلات'), findsOneWidget);
      expect(find.text('خريطة السائقين'), findsOneWidget);
      expect(find.text('كل السائقين'), findsOneWidget);

      // Verify Map Preview
      expect(find.text('مواقع السائقين'), findsOneWidget);
      expect(find.text('مراقبة السائقين في الوقت الفعلي'), findsOneWidget);
      expect(find.text('عرض الخريطة الكاملة'), findsOneWidget);
      expect(find.text('BX-458622'), findsWidgets);

      // Verify Operations Status
      expect(find.text('حالة العمليات'), findsOneWidget);
      expect(find.text('87%'), findsOneWidget);
      expect(find.text('معدل الإنجاز'), findsOneWidget);
      expect(find.text('عرض التقارير'), findsOneWidget);
      expect(find.text('112'), findsOneWidget);
      expect(find.text('7'), findsOneWidget);

      // Verify Top Drivers
      expect(find.text('استعراض السائقين'), findsOneWidget);
      expect(find.text('أحمد السعيد'), findsOneWidget);
      expect(find.text('محمد العنزي'), findsOneWidget);
      expect(find.text('يوسف خالد'), findsOneWidget);
      expect(find.text('عرض كل السائقين'), findsOneWidget);

      // Verify Areas Summary
      expect(find.text('ملخص المناطق'), findsOneWidget);
      expect(find.text('السالمية'), findsOneWidget);
      expect(find.text('حولي'), findsOneWidget);
      expect(find.text('الجهراء'), findsOneWidget);
      expect(find.text('العاصمة'), findsOneWidget);

      // Verify Alert Banner
      expect(find.text('هناك 2 مشكلة تحتاج إلى انتباهك'), findsOneWidget);
    });

    testWidgets('renders cleanly in English LTR without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 1200 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(
          locale: const Locale('en'),
          child: const DispatcherHomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherHomeScreen), findsOneWidget);
      expect(find.text('Welcome'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Drivers Locations'), findsOneWidget);
      expect(find.text('Operations Status'), findsOneWidget);
      expect(find.text('Drivers Review'), findsOneWidget);
      expect(find.text('Area Summary'), findsOneWidget);
    });
  });
}
