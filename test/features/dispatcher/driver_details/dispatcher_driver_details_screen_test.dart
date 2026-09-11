import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/driver_details/domain/fake_data/driver_details_fake_data.dart';
import 'package:meal_mate_delivery/features/dispatcher/driver_details/presentation/screens/dispatcher_driver_details_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/driver_details/presentation/widgets/driver_details_action_buttons.dart';
import 'package:meal_mate_delivery/features/dispatcher/driver_details/presentation/widgets/driver_details_app_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/driver_details/presentation/widgets/driver_details_boxes_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/driver_details/presentation/widgets/driver_details_kpi_row.dart';
import 'package:meal_mate_delivery/features/dispatcher/driver_details/presentation/widgets/driver_details_location_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/driver_details/presentation/widgets/driver_details_performance_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/driver_details/presentation/widgets/driver_details_profile_card.dart';

void main() {
  Widget buildSubject({
    Locale locale = const Locale('ar'),
    VoidCallback? onBack,
    VoidCallback? onMore,
    VoidCallback? onOpenMap,
    VoidCallback? onSendMessage,
    VoidCallback? onCall,
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: DispatcherDriverDetailsScreen(
        driver: DriverDetailsFakeData.defaultDriver,
        onBack: onBack,
        onMore: onMore,
        onOpenMap: onOpenMap,
        onSendMessage: onSendMessage,
        onCall: onCall,
      ),
    );
  }

  group('DispatcherDriverDetailsScreen Tests', () {
    testWidgets('renders all major components and cards in RTL Arabic',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(DriverDetailsAppBar), findsOneWidget);
      expect(find.byType(DriverDetailsProfileCard), findsOneWidget);
      expect(find.byType(DriverDetailsKpiRow), findsOneWidget);
      expect(find.byType(DriverDetailsLocationCard), findsOneWidget);
      expect(find.byType(DriverDetailsBoxesCard), findsOneWidget);
      expect(find.byType(DriverDetailsPerformanceCard), findsOneWidget);
      expect(find.byType(DriverDetailsActionButtons), findsOneWidget);

      expect(find.text('تفاصيل السائق'), findsOneWidget);
      expect(find.text('أحمد السعيد'), findsOneWidget);
      expect(find.text('DR-1025'), findsOneWidget);
      expect(find.text('+966 50 123 4567'), findsOneWidget);
      expect(find.text('متاح'), findsOneWidget);
      expect(find.text('آخر تحديث الآن'), findsOneWidget);
      expect(find.text('البوكسات الحالية'), findsOneWidget);
      expect(find.text('تم التوصيل اليوم'), findsOneWidget);
      expect(find.text('متوسط التأخير (د)'), findsOneWidget);
      expect(find.text('تقييم الأداء'), findsOneWidget);
      expect(find.text('الموقع الحالي'), findsOneWidget);
      expect(find.text('فتح على الخريطة'), findsOneWidget);
      expect(find.text('ملخص الأداء اليومي'), findsOneWidget);
      expect(find.text('إرسال رسالة'), findsOneWidget);
      expect(find.text('اتصال'), findsOneWidget);
    });

    testWidgets('renders properly in English locale', (tester) async {
      await tester.pumpWidget(buildSubject(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Driver Details'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      expect(find.text('Last updated now'), findsOneWidget);
      expect(find.text('Current Boxes'), findsOneWidget);
      expect(find.text('Delivered Today'), findsOneWidget);
      expect(find.text('Open on Map'), findsOneWidget);
      expect(find.text('Daily Performance Summary'), findsOneWidget);
      expect(find.text('Send Message'), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);
    });

    testWidgets('triggers callback buttons when tapped', (tester) async {
      bool backCalled = false;
      bool callCalled = false;
      bool msgCalled = false;
      bool mapCalled = false;

      await tester.pumpWidget(
        buildSubject(
          onBack: () => backCalled = true,
          onCall: () => callCalled = true,
          onSendMessage: () => msgCalled = true,
          onOpenMap: () => mapCalled = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('فتح على الخريطة'));
      expect(mapCalled, isTrue);

      await tester.tap(
        find
            .descendant(
              of: find.byType(DriverDetailsAppBar),
              matching: find.byType(IconButton),
            )
            .first,
      );
      expect(backCalled, isTrue);

      await tester.ensureVisible(find.text('اتصال'));
      await tester.tap(find.text('اتصال'));
      expect(callCalled, isTrue);

      await tester.ensureVisible(find.text('إرسال رسالة'));
      await tester.tap(find.text('إرسال رسالة'));
      expect(msgCalled, isTrue);
    });

    testWidgets('renders without overflow on narrow viewport (360x720)',
        (tester) async {
      tester.view.physicalSize = const Size(360, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DispatcherDriverDetailsScreen), findsOneWidget);
    });

    testWidgets('renders without overflow on extra small viewport (320x640)',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      final exception = tester.takeException();
      expect(exception, isNull);
      expect(find.byType(DispatcherDriverDetailsScreen), findsOneWidget);
    });
  });
}
