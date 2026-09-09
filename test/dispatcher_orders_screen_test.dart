import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/orders/presentation/screens/dispatcher_orders_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/orders/presentation/widgets/dispatcher_bottom_nav_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/orders/presentation/widgets/dispatcher_filter_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/orders/presentation/widgets/dispatcher_metrics_grid.dart';
import 'package:meal_mate_delivery/features/dispatcher/orders/presentation/widgets/dispatcher_order_card.dart';

void main() {
  Widget buildSubject({Locale locale = const Locale('ar')}) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      home: const DispatcherOrdersScreen(),
    );
  }

  testWidgets('renders dispatcher orders screen with all sections in Arabic', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject());
    await tester.pumpAndSettle();

    // Top Header
    expect(find.text('مطعم MealMate الكويت'), findsOneWidget);
    expect(find.text('Dispatcher'), findsOneWidget);

    // Title Section
    expect(find.text('الطلبات'), findsWidgets); // Title and bottom nav
    expect(find.text('طابور البوكسات في انتظار الإسناد'), findsOneWidget);

    // Metrics Section
    expect(find.byType(DispatcherMetricsGrid), findsOneWidget);
    expect(find.text('23'), findsWidgets); // Metric count & filter count
    expect(find.text('37'), findsWidgets);
    expect(find.text('58'), findsWidgets);
    expect(find.text('2'), findsWidgets);

    // Filter Bar
    expect(find.byType(DispatcherFilterBar), findsOneWidget);
    expect(find.text('الكل'), findsOneWidget);

    // Order cards
    expect(find.byType(DispatcherOrderCard), findsWidgets);
    expect(find.text('#BX-1256'), findsOneWidget);
    expect(find.text('جديد'), findsWidgets);
    expect(find.text('منطقة السالمية'), findsOneWidget);
    expect(find.text('إسناد'), findsWidgets);
    expect(find.text('التفاصيل'), findsWidgets);

    // Bottom Navigation Bar
    expect(find.byType(DispatcherBottomNavBar), findsOneWidget);
    expect(find.text('الرئيسية'), findsOneWidget);
    expect(find.text('التوصيل'), findsOneWidget);
    expect(find.text('الدعم'), findsOneWidget);
    expect(find.text('الحساب'), findsOneWidget);
  });

  testWidgets('renders dispatcher orders screen in English locale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject(locale: const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('MealMate Restaurant Kuwait'), findsOneWidget);
    expect(find.text('Orders'), findsWidgets);
    expect(find.text('Box queue awaiting assignment'), findsOneWidget);
    expect(find.text('Pending Assignment'), findsWidgets);
    expect(find.text('Assign'), findsWidgets);
    expect(find.text('Details'), findsWidgets);
  });
}
