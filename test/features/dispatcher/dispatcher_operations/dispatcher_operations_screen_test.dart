import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/screens/dispatcher_operations_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/widgets/operations_app_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/widgets/operations_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/widgets/operations_pagination_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/widgets/operations_search_filter_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/widgets/operations_status_tabs.dart';

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

  group('DispatcherOperationsScreen Tests', () {
    testWidgets('renders all major components in RTL', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(child: const DispatcherOperationsScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherOperationsScreen), findsOneWidget);
      expect(find.byType(OperationsAppBar), findsOneWidget);
      expect(find.byType(OperationsSearchFilterBar), findsOneWidget);
      expect(find.byType(OperationsStatusTabs), findsOneWidget);
      expect(find.byType(OperationsCard), findsWidgets);
      expect(find.byType(OperationsPaginationBar), findsOneWidget);

      // Verify title "سجل العمليات"
      expect(find.text('سجل العمليات'), findsWidgets);
    });

    testWidgets('filters list by status tab selection', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(child: const DispatcherOperationsScreen()),
      );
      await tester.pumpAndSettle();

      // Tap on "ملغاة" tab
      final cancelledTab = find.text('ملغاة');
      expect(cancelledTab, findsWidgets);
      await tester.tap(cancelledTab.first);
      await tester.pumpAndSettle();

      // Verify that cancelled card reason is visible
      expect(find.text('تم الإلغاء من قبل المطعم'), findsOneWidget);
    });

    testWidgets('filters list by search query', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(child: const DispatcherOperationsScreen()),
      );
      await tester.pumpAndSettle();

      // Enter search query
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);
      await tester.enterText(searchField, 'عبدالله الشهري');
      await tester.pumpAndSettle();

      // Verify exactly 1 operations card matches
      expect(find.byType(OperationsCard), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(OperationsCard),
          matching: find.text('عبدالله الشهري'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('pagination bar displays page count and responds to clicks', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(child: const DispatcherOperationsScreen()),
      );
      await tester.pumpAndSettle();

      // Page text check: "1 من 13"
      expect(find.text('1 من 13'), findsOneWidget);

      // Tap "التالي"
      final nextButton = find.text('التالي');
      expect(nextButton, findsOneWidget);
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Page text becomes "2 من 13"
      expect(find.text('2 من 13'), findsOneWidget);
    });
  });
}
