import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_assigned_box_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_box_delivery_status.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/screens/driver_assigned_boxes_screen.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_assigned_box_card.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_boxes_delivery_mode_chip.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_boxes_filter_bar.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_boxes_header_logo.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_boxes_stats_banner.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_boxes_title_bar.dart';

void main() {
  Widget buildSubject({
    Locale locale = const Locale('ar'),
    List<DriverAssignedBoxEntity>? initialBoxes,
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: DriverAssignedBoxesScreen(initialBoxes: initialBoxes),
    );
  }

  testWidgets(
    'renders driver assigned boxes screen with all sections in Arabic',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Top Header Logo
      expect(find.byType(DriverBoxesHeaderLogo), findsOneWidget);

      // Title Bar and Delivery Mode
      expect(find.byType(DriverBoxesTitleBar), findsOneWidget);
      expect(find.text('قائمة الصناديق'), findsOneWidget);
      expect(find.text('الصناديق المخصصة قبل التوصيل'), findsOneWidget);
      expect(find.byType(DriverBoxesDeliveryModeChip), findsOneWidget);
      expect(find.text('أنت في وضع التوصيل'), findsOneWidget);

      // Stats Banner
      expect(find.byType(DriverBoxesStatsBanner), findsOneWidget);
      expect(find.text('53'), findsOneWidget);
      expect(find.text('إجمالي الوجبات'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('إجمالي الصناديق المخصصة اليوم'), findsOneWidget);

      // Filter Bar
      expect(find.byType(DriverBoxesFilterBar), findsOneWidget);
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('جاهز للتوصيل'), findsWidgets);
      expect(find.text('تم التوصيل'), findsWidgets);

      // Cards
      expect(find.byType(DriverAssignedBoxCard), findsWidgets);
      expect(find.text('#BOX-1256'), findsWidgets);
      expect(find.text('#MM-1256'), findsWidgets);
      expect(find.text('لم يتم التحميل'), findsWidgets);
      expect(find.text('استكمال\nالاجراء'), findsWidgets);
      expect(find.text('ابدأ التوصيل'), findsWidgets);
      expect(find.text('فشل التوصيل'), findsWidgets);
      expect(find.text('حدثت مشكلة'), findsWidgets);
    },
  );

  testWidgets('filters boxes correctly when selecting filter tabs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    const testBoxes = [
      DriverAssignedBoxEntity(
        boxId: '#BOX-TEST-1',
        orderCode: '#MM-TEST-1',
        mealCount: 3,
        area: 'حي النرجس',
        status: DriverBoxDeliveryStatus.ready,
      ),
      DriverAssignedBoxEntity(
        boxId: '#BOX-TEST-2',
        orderCode: '#MM-TEST-2',
        mealCount: 4,
        area: 'حي الياسمين',
        status: DriverBoxDeliveryStatus.delivered,
      ),
    ];

    await tester.pumpWidget(buildSubject(initialBoxes: testBoxes));
    await tester.pumpAndSettle();

    // Initially All boxes are present
    expect(find.text('#BOX-TEST-1'), findsOneWidget);
    expect(find.text('#BOX-TEST-2'), findsOneWidget);

    // Tap "جاهز للتوصيل" tab in filter bar
    final readyTab = find.descendant(
      of: find.byType(DriverBoxesFilterBar),
      matching: find.text('جاهز للتوصيل'),
    );
    await tester.tap(readyTab);
    await tester.pumpAndSettle();

    // Ready box is present, delivered box is filtered out
    expect(find.text('#BOX-TEST-1'), findsOneWidget);
    expect(find.text('#BOX-TEST-2'), findsNothing);

    // Tap "تم التوصيل" tab in filter bar
    final deliveredTab = find.descendant(
      of: find.byType(DriverBoxesFilterBar),
      matching: find.text('تم التوصيل'),
    );
    await tester.tap(deliveredTab);
    await tester.pumpAndSettle();

    // Delivered box is present, ready box is filtered out
    expect(find.text('#BOX-TEST-2'), findsOneWidget);
    expect(find.text('#BOX-TEST-1'), findsNothing);
  });

  testWidgets('renders correctly in English', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject(locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('Boxes List'), findsOneWidget);
    expect(find.text('Assigned boxes before delivery'), findsOneWidget);
    expect(find.text('You are in delivery mode'), findsOneWidget);
    expect(find.text('Total Meals'), findsOneWidget);
    expect(find.text('Total boxes assigned today'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Ready for delivery'), findsWidgets);
    expect(find.text('Delivered'), findsWidgets);
  });

  testWidgets('shows CustomSnackbar and transitions status when action button is tapped', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    const testBoxes = [
      DriverAssignedBoxEntity(
        boxId: '#BOX-ACT-1',
        orderCode: '#MM-ACT-1',
        mealCount: 2,
        area: 'حي النرجس',
        status: DriverBoxDeliveryStatus.notLoaded,
      ),
    ];

    await tester.pumpWidget(buildSubject(initialBoxes: testBoxes));
    await tester.pumpAndSettle();

    // Tap "استكمال الاجراء"
    final completeActionButton = find.text('استكمال\nالاجراء');
    expect(completeActionButton, findsOneWidget);
    await tester.tap(completeActionButton);
    await tester.pump();

    // Verify CustomSnackbar appears
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('استكمال الاجراء'), findsOneWidget);

    await tester.pumpAndSettle();

    // Box has transitioned to ready with "ابدأ التوصيل"
    final startDeliveryButton = find.text('ابدأ التوصيل');
    expect(startDeliveryButton, findsOneWidget);

    // Tap "ابدأ التوصيل"
    await tester.tap(startDeliveryButton);
    await tester.pump(const Duration(milliseconds: 300));

    // Verify CustomSnackbar appears for starting delivery
    expect(find.byType(SnackBar), findsOneWidget);

    await tester.pumpAndSettle();

    // Box has transitioned to delivered with "تم التوصيل"
    expect(find.text('تم التوصيل'), findsWidgets);
  });
}
