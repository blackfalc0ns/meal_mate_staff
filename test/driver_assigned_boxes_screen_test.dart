import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/screens/driver_assigned_boxes_screen.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_assigned_box_card.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_boxes_delivery_mode_chip.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_boxes_filter_bar.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_boxes_header_logo.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_boxes_stats_banner.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_boxes_title_bar.dart';

void main() {
  Widget buildSubject({Locale locale = const Locale('ar')}) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: const DriverAssignedBoxesScreen(),
    );
  }

  testWidgets('renders driver assigned boxes screen with all sections in Arabic', (
    tester,
  ) async {
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
    expect(find.text('32'), findsOneWidget);
    expect(find.text('إجمالي الوجبات'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('إجمالي الصناديق المخصصة اليوم'), findsOneWidget);

    // Filter Bar
    expect(find.byType(DriverBoxesFilterBar), findsOneWidget);
    expect(find.text('الكل'), findsOneWidget);
    expect(find.text('لم يتم التحميل'), findsWidgets);
    expect(find.text('تم التحميل'), findsWidgets);

    // Cards
    expect(find.byType(DriverAssignedBoxCard), findsWidgets);
    expect(find.text('#BOX-1256'), findsOneWidget);
    expect(find.text('#MM-1256'), findsOneWidget);
  });

  testWidgets('filters boxes correctly when selecting filter tabs', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Initially All 8 boxes are present
    expect(find.text('#BOX-1256'), findsOneWidget); // unloaded
    expect(find.text('#BOX-1260'), findsOneWidget); // loaded

    // Tap "لم يتم التحميل" tab in filter bar
    final notLoadedTab = find.descendant(
      of: find.byType(DriverBoxesFilterBar),
      matching: find.text('لم يتم التحميل'),
    );
    await tester.tap(notLoadedTab);
    await tester.pumpAndSettle();

    // Unloaded box is still present, loaded box is filtered out
    expect(find.text('#BOX-1256'), findsOneWidget);
    expect(find.text('#BOX-1260'), findsNothing);

    // Tap "تم التحميل" tab in filter bar
    final loadedTab = find.descendant(
      of: find.byType(DriverBoxesFilterBar),
      matching: find.text('تم التحميل'),
    );
    await tester.tap(loadedTab);
    await tester.pumpAndSettle();

    // Loaded box is present, unloaded box is filtered out
    expect(find.text('#BOX-1260'), findsOneWidget);
    expect(find.text('#BOX-1256'), findsNothing);
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
  });
}
