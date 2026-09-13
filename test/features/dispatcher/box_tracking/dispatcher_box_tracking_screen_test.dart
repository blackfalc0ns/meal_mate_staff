import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/box_tracking/domain/fake_data/box_tracking_fake_data.dart';
import 'package:meal_mate_delivery/features/dispatcher/box_tracking/presentation/screens/dispatcher_box_tracking_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/box_tracking/presentation/widgets/box_tracking_app_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/box_tracking/presentation/widgets/box_tracking_details_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/box_tracking/presentation/widgets/box_tracking_driver_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/box_tracking/presentation/widgets/box_tracking_header_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/box_tracking/presentation/widgets/box_tracking_report_issue_button.dart';
import 'package:meal_mate_delivery/features/dispatcher/box_tracking/presentation/widgets/box_tracking_timeline_card.dart';

void main() {
  Widget buildSubject({
    Locale locale = const Locale('ar'),
    VoidCallback? onBack,
    VoidCallback? onMore,
    VoidCallback? onLiveTracking,
    VoidCallback? onSendMessage,
    VoidCallback? onCall,
    VoidCallback? onReportIssue,
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: DispatcherBoxTrackingScreen(
        box: BoxTrackingFakeData.defaultBox,
        onBack: onBack,
        onMore: onMore,
        onLiveTracking: onLiveTracking,
        onSendMessage: onSendMessage,
        onCall: onCall,
        onReportIssue: onReportIssue,
      ),
    );
  }

  group('DispatcherBoxTrackingScreen Tests', () {
    testWidgets('renders all major components and cards in RTL Arabic',
        (tester) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(BoxTrackingAppBar), findsOneWidget);
      expect(find.byType(BoxTrackingHeaderCard), findsOneWidget);
      expect(find.byType(BoxTrackingTimelineCard), findsOneWidget);
      expect(find.byType(BoxTrackingDriverCard), findsOneWidget);
      expect(find.byType(BoxTrackingDetailsCard), findsOneWidget);
      expect(find.byType(BoxTrackingReportIssueButton), findsOneWidget);

      expect(find.text('متابعة البوكس'), findsOneWidget);
      expect(find.text('#BX-10256'), findsOneWidget);
      expect(find.text('عميل: أحمد العتيبي'), findsOneWidget);
      expect(find.text('في الطريق'), findsOneWidget);
      expect(find.text('حالة البوكس'), findsOneWidget);
      expect(find.text('جاهز في المطعم'), findsOneWidget);
      expect(find.text('استلمه السائق'), findsOneWidget);
      expect(find.text('في الطريق للتوصيل'), findsOneWidget);
      expect(find.text('تم التسليم'), findsOneWidget);
      expect(find.text('أحمد السعيد'), findsOneWidget);
      expect(find.text('تتبع مباشر'), findsOneWidget);
      expect(find.text('رسالة'), findsOneWidget);
      expect(find.text('اتصال'), findsOneWidget);
      expect(find.text('تفاصيل البوكس'), findsOneWidget);
      expect(find.text('نوع البرنامج'), findsOneWidget);
      expect(find.text('دايت متوازن'), findsOneWidget);
      expect(find.text('الإبلاغ عن مشكلة في البوكس'), findsOneWidget);
    });

    testWidgets('renders properly in English locale', (tester) async {
      await tester.pumpWidget(buildSubject(locale: const Locale('en')));
      await tester.pumpAndSettle();

      expect(find.text('Box Tracking'), findsOneWidget);
      expect(find.text('Customer: أحمد العتيبي'), findsOneWidget);
      expect(find.text('On the way'), findsOneWidget);
      expect(find.text('Box Status'), findsOneWidget);
      expect(find.text('Live Tracking'), findsOneWidget);
      expect(find.text('Message'), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('Box Details'), findsOneWidget);
      expect(find.text('Plan Type'), findsOneWidget);
      expect(find.text('Report an issue with the box'), findsOneWidget);
    });

    testWidgets('triggers callback buttons when tapped', (tester) async {
      bool backCalled = false;
      bool moreCalled = false;
      bool liveCalled = false;
      bool msgCalled = false;
      bool callCalled = false;
      bool reportCalled = false;

      await tester.pumpWidget(
        buildSubject(
          onBack: () => backCalled = true,
          onMore: () => moreCalled = true,
          onLiveTracking: () => liveCalled = true,
          onSendMessage: () => msgCalled = true,
          onCall: () => callCalled = true,
          onReportIssue: () => reportCalled = true,
        ),
      );
      await tester.pumpAndSettle();

      // Tap back button
      final backButton = find.descendant(
        of: find.byType(BoxTrackingAppBar),
        matching: find.byType(IconButton),
      ).first;
      await tester.tap(backButton);
      expect(backCalled, isTrue);

      // Tap more options
      final moreButton = find.byIcon(Icons.more_vert_rounded);
      await tester.tap(moreButton);
      expect(moreCalled, isTrue);

      // Tap live tracking
      await tester.ensureVisible(find.text('تتبع مباشر'));
      await tester.tap(find.text('تتبع مباشر'));
      expect(liveCalled, isTrue);

      // Tap message
      await tester.ensureVisible(find.text('رسالة'));
      await tester.tap(find.text('رسالة'));
      expect(msgCalled, isTrue);

      // Tap call
      await tester.ensureVisible(find.text('اتصال'));
      await tester.tap(find.text('اتصال'));
      expect(callCalled, isTrue);

      // Tap report issue
      await tester.ensureVisible(find.text('الإبلاغ عن مشكلة في البوكس'));
      await tester.tap(find.text('الإبلاغ عن مشكلة في البوكس'));
      expect(reportCalled, isTrue);
    });

    testWidgets('renders without overflow on narrow viewport (360x720)',
        (tester) async {
      tester.view.physicalSize = const Size(360, 720);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DispatcherBoxTrackingScreen), findsOneWidget);
    });

    testWidgets('renders without overflow on extra small viewport (320x640)',
        (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(DispatcherBoxTrackingScreen), findsOneWidget);
    });
  });
}
