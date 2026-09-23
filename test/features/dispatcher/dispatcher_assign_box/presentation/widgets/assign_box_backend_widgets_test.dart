import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/widget/app_cached_network_image.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_candidate_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_driver_status_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_meal_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_order_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_priority.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_summary_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_bottom_actions.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_driver_avatar.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_driver_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_driver_status_badge.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_recommended_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_summary_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_summary_content.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/widgets/assign_box_summary_meal_row.dart';

Widget buildTestWidget({
  required Widget child,
  Locale locale = const Locale('ar'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: child),
  );
}


void main() {
  const sampleBox = AssignBoxOrderEntity(
    boxId: 'a1111111-1111-1111-1111-111111111111',
    boxCode: '#BX-1256',
    zoneName: 'المنطقة الشرقية',
    deliveryTimeWindow: '10:00 - 11:30 ص',
    mealsCount: 4,
    mealsCountText: '4 وجبات',
    distanceKm: 3.5,
    distanceText: '3.5 كم',
    priority: AssignBoxPriority.high,
    priorityText: 'أولوية عالية',
    status: AssignBoxStatus.pending,
    statusText: 'قيد الانتظار',
  );

  const sampleBestDriver = AssignBoxCandidateDriverEntity(
    driverId: '33333333-3333-3333-3333-333333333333',
    fullName: 'سالم الحربي',
    avatarUrl: 'https://example.com/avatar.jpg',
    plateNumber: '40-12849',
    phone: '0501234567',
    distanceKm: 2.4,
    distanceText: '2.4 كم',
    activeOrdersCount: 1,
    currentLoadBoxes: 4,
    currentLoadLabel: '4 بوكسات',
    rating: 4.8,
    status: AssignBoxDriverStatusType.available,
    driverStatusText: 'متاح',
    statusTag: 'الأسرع وصولاً',
    estimatedFinishTimeText: '10:20 ص',
    rank: 1,
    isRecommended: true,
    recommendationReason: 'الأقرب لموقع الاستلام',
  );

  const sampleSummary = AssignBoxSummaryEntity(
    boxId: 'a1111111-1111-1111-1111-111111111111',
    boxCode: '#BX-1256',
    customerMaskedId: 'CUST-***42',
    customerNameMasked: 'أحمد ***',
    customerPhoneMasked: '+965 **** 1234',
    zoneName: 'السالمية',
    address: 'شارع سالم المبارك، برج السنابل، شقة 14',
    deliveryTimeWindow: '11:00 ص - 12:30 م',
    boxCount: 1,
    barcode: 'MM-BX-1256-KWT',
    deliveryNotes: 'يرجى وضع البوكس عند الباب والاتصال',
    allergies: ['مكسرات', 'لاكتوز'],
    meals: [
      AssignBoxMealEntity(
        mealId: 'm-1',
        mealName: 'سالمون مشوي مع الكينوا والخضار السوتيه',
        quantity: 2,
        category: 'غداء كيتو',
        notes: 'بدون بصل',
      ),
    ],
  );

  group('AssignBoxSummaryCard', () {
    testWidgets('renders all box details properly', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(child: const AssignBoxSummaryCard(order: sampleBox)),
      );

      expect(find.text('#BX-1256'), findsOneWidget);
      expect(find.text('قيد الانتظار'), findsOneWidget);
      expect(find.text('أولوية عالية'), findsOneWidget);
      expect(find.text('المنطقة الشرقية'), findsOneWidget);
      expect(find.text('3.5 كم'), findsOneWidget);
      expect(find.text('4 وجبات'), findsOneWidget);
      expect(find.text('10:00 - 11:30 ص'), findsOneWidget);
    });
  });

  group('AssignBoxRecommendedCard', () {
    testWidgets('renders best suggestion details, radio selection, and network avatar', (tester) async {
      var selected = false;
      await tester.pumpWidget(
        buildTestWidget(
          child: AssignBoxRecommendedCard(
            driver: sampleBestDriver,
            isSelected: true,
            onSelected: () => selected = true,
          ),
        ),
      );

      expect(find.text('سالم الحربي'), findsOneWidget);
      expect(find.text('4 بوكسات'), findsOneWidget);
      expect(find.text('2.4 كم'), findsOneWidget);
      expect(find.text('الأسرع وصولاً'), findsOneWidget);
      expect(find.byType(AppCachedNetworkImage), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_checked_rounded), findsOneWidget);

      await tester.tap(find.byType(AssignBoxRecommendedCard));
      expect(selected, isTrue);
    });
  });

  group('AssignBoxDriverCard', () {
    testWidgets('renders candidate driver row with metrics and status badge', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: AssignBoxDriverCard(
            driver: sampleBestDriver,
            isSelected: false,
            onSelected: () {},
          ),
        ),
      );

      expect(find.text('سالم الحربي'), findsOneWidget);
      expect(find.text('4 بوكسات'), findsOneWidget);
      expect(find.text('2.4 كم'), findsOneWidget);
      expect(find.byType(AppCachedNetworkImage), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_off_rounded), findsOneWidget);
    });
  });

  group('AssignBoxDriverStatusBadge', () {
    testWidgets('renders four status types and unknown properly', (tester) async {
      for (final status in AssignBoxDriverStatusType.values) {
        await tester.pumpWidget(
          buildTestWidget(
            child: AssignBoxDriverStatusBadge(
              statusType: status,
              statusText: status.name,
            ),
          ),
        );
        expect(find.text(status.name), findsOneWidget);
      }
    });
  });

  group('AssignBoxBottomActions', () {
    testWidgets('handles isConfirmEnabled and isSubmitting states', (tester) async {
      var confirmTapped = false;
      await tester.pumpWidget(
        buildTestWidget(
          child: AssignBoxBottomActions(
            isConfirmEnabled: false,
            isSubmitting: false,
            onConfirmPressed: () => confirmTapped = true,
          ),
        ),
      );

      await tester.tap(find.text('تأكيد الإسناد'));
      expect(confirmTapped, isFalse);

      // Loading state
      await tester.pumpWidget(
        buildTestWidget(
          child: const AssignBoxBottomActions(
            isConfirmEnabled: true,
            isSubmitting: true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('AssignBoxSummaryContent and AssignBoxSummaryMealRow', () {
    testWidgets('renders full masked customer data, barcode, allergies, and meals', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: const AssignBoxSummaryContent(summary: sampleSummary),
        ),
      );

      expect(find.text('#BX-1256'), findsOneWidget);
      expect(find.text('MM-BX-1256-KWT'), findsOneWidget);
      expect(find.text('أحمد ***'), findsOneWidget);
      expect(find.text('+965 **** 1234'), findsOneWidget);
      expect(find.text('السالمية'), findsOneWidget);
      expect(find.text('شارع سالم المبارك، برج السنابل، شقة 14'), findsOneWidget);
      expect(find.text('مكسرات'), findsOneWidget);
      expect(find.text('لاكتوز'), findsOneWidget);
      expect(find.text('سالمون مشوي مع الكينوا والخضار السوتيه'), findsOneWidget);
      expect(find.text('بدون بصل'), findsOneWidget);
    });

    testWidgets('renders empty allergies and empty meals gracefully with localized fallback', (tester) async {
      const emptySummary = AssignBoxSummaryEntity(
        boxId: 'b-1',
        boxCode: '#BX-1',
        boxCount: 1,
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: const AssignBoxSummaryContent(summary: emptySummary),
        ),
      );

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow on narrow 360px viewport', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestWidget(
          child: const SingleChildScrollView(
            child: AssignBoxSummaryContent(summary: sampleSummary),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
