import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/domain/entities/driver_notification_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/presentation/screens/driver_notifications_screen.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/presentation/widgets/driver_notification_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/presentation/widgets/driver_notifications_filter_tab_bar.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/presentation/widgets/driver_notifications_header.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/presentation/widgets/driver_notifications_mark_all_button.dart';
import 'package:meal_mate_delivery/features/driver/driver_notifications/presentation/widgets/driver_notifications_section_header.dart';

void main() {
  Widget buildSubject({
    List<DriverNotificationEntity>? initialNotifications,
    Locale locale = const Locale('ar'),
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
      home: DriverNotificationsScreen(
        initialNotifications: initialNotifications,
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

    expect(find.byType(DriverNotificationsHeader), findsOneWidget);
    expect(find.byType(DriverNotificationsFilterTabBar), findsOneWidget);
    expect(find.byType(DriverNotificationsSectionHeader), findsNWidgets(2));
    expect(find.byType(DriverNotificationCard), findsNWidgets(6));
    expect(find.byType(DriverNotificationsMarkAllButton), findsOneWidget);

    expect(find.text('الاشعارات'), findsOneWidget);
    expect(find.text('طلب جديد'), findsOneWidget);
    expect(find.text('عرض الكل كمقروء'), findsOneWidget);

    final allRect = tester.getRect(find.text('الكل'));
    final systemRect = tester.getRect(find.text('النظام'));
    final tabsCenter = (allRect.right + systemRect.left) / 2;
    // 540 / 2 = 270
    expect((tabsCenter - 270).abs(), lessThan(5.0));
  });

  testWidgets('renders all major components in English LTR without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject(locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Mark All as Read'), findsOneWidget);
  });

  testWidgets('filtering by offers displays only offer notifications', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    final offersTab = find.text('العروض');
    await tester.tap(offersTab);
    await tester.pumpAndSettle();

    expect(find.byType(DriverNotificationCard), findsOneWidget);
    expect(find.text('عرض جديد'), findsOneWidget);
    expect(find.text('طلب جديد'), findsNothing);
  });

  testWidgets('tapping mark all as read marks notifications as read', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    bool isUnreadDot(Widget w) =>
        w is Container &&
        w.constraints?.maxWidth == 7 &&
        w.decoration is BoxDecoration &&
        (w.decoration as BoxDecoration).shape == BoxShape.circle;

    expect(find.byWidgetPredicate(isUnreadDot), findsOneWidget);

    final markAllButton = find.byType(DriverNotificationsMarkAllButton);
    await tester.ensureVisible(markAllButton);
    await tester.tap(markAllButton);
    await tester.pump();

    // Unread indicator dot is now gone
    expect(find.byWidgetPredicate(isUnreadDot), findsNothing);
  });
}
