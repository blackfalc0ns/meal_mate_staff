import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/notifications/presentation/screens/dispatcher_notifications_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/notifications/presentation/widgets/dispatcher_notification_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/notifications/presentation/widgets/dispatcher_notifications_app_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/notifications/presentation/widgets/dispatcher_notifications_filter_tab_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/notifications/presentation/widgets/dispatcher_notifications_section_header.dart';

void main() {
  Widget buildSubject({Locale locale = const Locale('ar')}) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: const DispatcherNotificationsScreen(),
    );
  }

  group('DispatcherNotificationsScreen Widget Tests', () {
    testWidgets('renders all components and 7 notifications in Arabic', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // App Bar
      expect(find.byType(DispatcherNotificationsAppBar), findsOneWidget);
      expect(find.text('الإشعارات'), findsOneWidget);

      // Filter tabs
      expect(find.byType(DispatcherNotificationsFilterTabBar), findsOneWidget);
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('غير مقروءة'), findsOneWidget);
      expect(find.text('أرشيف'), findsOneWidget);

      // Section header
      expect(find.byType(DispatcherNotificationsSectionHeader), findsOneWidget);
      expect(find.text('أحدث الإشعارات'), findsOneWidget);
      expect(find.text('تحديد الكل كمقروءة'), findsOneWidget);

      // Notification cards
      expect(find.byType(DispatcherNotificationCard), findsNWidgets(7));
      expect(find.text('بوكس جديد جاهز للاستلام'), findsOneWidget);
      expect(find.text('مشكلة في بوكس'), findsOneWidget);
      expect(find.text('السائق أحمد أكمل كل بوكساته'), findsOneWidget);
      expect(find.text('تم استلام بوكس بديل'), findsOneWidget);
      expect(find.text('تنبيه أداء'), findsOneWidget);
      expect(find.text('تحديث على الرحلة'), findsOneWidget);
      expect(find.text('بوكس متأخر'), findsOneWidget);
    });

    testWidgets('filters by unread correctly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherNotificationCard), findsNWidgets(7));

      // Tap on "غير مقروءة" tab
      await tester.tap(find.text('غير مقروءة'));
      await tester.pumpAndSettle();

      // Only 3 unread items in initial fake data
      expect(find.byType(DispatcherNotificationCard), findsNWidgets(3));
      expect(find.text('بوكس جديد جاهز للاستلام'), findsOneWidget);
      expect(find.text('مشكلة في بوكس'), findsOneWidget);
      expect(find.text('السائق أحمد أكمل كل بوكساته'), findsOneWidget);
      expect(find.text('تم استلام بوكس بديل'), findsNothing);
    });

    testWidgets('mark all as read sets all items as read', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Tap "تحديد الكل كمقروءة"
      await tester.tap(find.text('تحديد الكل كمقروءة'));
      await tester.pumpAndSettle();

      // Switch to unread tab -> should now be empty
      await tester.tap(find.text('غير مقروءة'));
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherNotificationCard), findsNothing);
    });

    testWidgets('renders properly in English locale', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Unread'), findsOneWidget);
      expect(find.text('Archive'), findsOneWidget);
      expect(find.text('Recent Notifications'), findsOneWidget);
      expect(find.text('Mark all as read'), findsOneWidget);
      expect(find.text('بوكس جديد جاهز للاستلام'), findsOneWidget);
    });
  });
}
