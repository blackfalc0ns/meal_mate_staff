import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_step_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_step_icon_kind.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_step_state.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_details_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_driver_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_header_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_timeline_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_timeline_step_item.dart';

Widget _buildWrapper({
  required Widget child,
  Locale locale = const Locale('ar'),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: AppTheme.lightTheme,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('BoxTrackingDriverCard', () {
    testWidgets('renders properly with assigned driver', (tester) async {
      const driver = BoxTrackingDriverEntity(
        driverId: 'drv-1',
        driverCode: 'DR-1025',
        fullName: 'أحمد السعيد',
        phoneNumber: '+966501234567',
        avatarUrl: null,
      );

      await tester.pumpWidget(
        _buildWrapper(child: const BoxTrackingDriverCard(driver: driver)),
      );

      expect(find.text('أحمد السعيد'), findsOneWidget);
      expect(find.text('DR-1025'), findsOneWidget);
    });

    testWidgets('renders unassigned placeholder when driver is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildWrapper(child: const BoxTrackingDriverCard(driver: null)),
      );

      expect(find.byType(BoxTrackingDriverCard), findsOneWidget);
      expect(find.text('DR-1025'), findsNothing);
    });
  });

  group('BoxTrackingTimelineStepItem', () {
    testWidgets('renders unknown iconKind safely without exception', (
      tester,
    ) async {
      const step = BoxTrackingStepEntity(
        step: 99,
        title: 'خطوة خاصة',
        description: 'تفاصيل خاصة',
        time: null,
        state: BoxTrackingStepState.pending,
        iconKind: BoxTrackingStepIconKind.unknown,
      );

      await tester.pumpWidget(
        _buildWrapper(
          child: const BoxTrackingTimelineStepItem(
            step: step,
            isLast: true,
            isFirst: true,
          ),
        ),
      );

      expect(find.text('خطوة خاصة'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('BoxTrackingTimelineCard', () {
    testWidgets('handles empty steps list without crash', (tester) async {
      await tester.pumpWidget(
        _buildWrapper(child: const BoxTrackingTimelineCard(steps: [])),
      );

      expect(find.byType(BoxTrackingTimelineCard), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('BoxTrackingDetailsCard and HeaderCard at 320px width', () {
    testWidgets('renders without overflow on narrow 320px screen', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const tracking = BoxTrackingEntity(
        boxId: '4f8a3c21-9b12-42e7-90c1-872f2316e110',
        boxCode: '#BX-10256',
        status: BoxTrackingStatus.onTheWay,
        statusText: 'في الطريق للتوصيل',
        statusColor: '#3B82F6',
        customerName: 'عبدالرحمن بن عبدالعزيز آل سعود',
        scheduledTimeText: '12:30 م - 01:30 م',
        deliveryAddress:
            'شارع الملك فهد بن عبدالعزيز، برج المملكة، الدور 45، شقة 402',
        driver: null,
        programType: 'دايت متوازن مع وجبات خفيفة إضافية',
        orderDateText: 'اليوم 09:50 ص',
        customerNotes:
            'يرجى الاتصال والتنسيق مع حارس الأمن عند البوابة الرئيسية قبل الصعود',
        mealsSummary: '5 وجبات متكاملة (يوم كامل مع سناك)',
        steps: [],
      );

      await tester.pumpWidget(
        _buildWrapper(
          child: const Column(
            children: [
              BoxTrackingHeaderCard(box: tracking),
              SizedBox(height: 16),
              BoxTrackingDetailsCard(box: tracking),
            ],
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('#BX-10256'), findsOneWidget);
    });
  });
}
