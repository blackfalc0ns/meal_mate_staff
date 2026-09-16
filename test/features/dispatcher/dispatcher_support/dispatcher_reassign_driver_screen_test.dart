import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassign_driver_candidate_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/fake_data/dispatcher_issue_detail_fake_data.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/fake_data/dispatcher_reassign_driver_fake_data.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/screens/dispatcher_reassign_driver_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/reassign_driver_app_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/reassign_driver_bottom_button.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/reassign_driver_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/reassign_driver_issue_summary_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/widgets/reassign_driver/reassign_driver_list_header.dart';

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
    home: child,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DispatcherReassignDriverScreen Tests', () {
    testWidgets('renders all major components and cards in RTL Arabic', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 882 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(child: const DispatcherReassignDriverScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherReassignDriverScreen), findsOneWidget);
      expect(find.byType(ReassignDriverAppBar), findsOneWidget);
      expect(find.byType(ReassignDriverIssueSummaryCard), findsOneWidget);
      expect(find.byType(ReassignDriverListHeader), findsOneWidget);
      expect(
        find.byType(ReassignDriverCard),
        findsNWidgets(
          DispatcherReassignDriverFakeData.defaultCandidates.length,
        ),
      );
      expect(find.byType(ReassignDriverBottomButton), findsOneWidget);

      // Verify task number and issue title
      expect(
        find.text(DispatcherIssueDetailFakeData.sampleIssueDetail.title),
        findsOneWidget,
      );
      expect(
        find.text(DispatcherIssueDetailFakeData.sampleIssueDetail.taskNumber),
        findsOneWidget,
      );

      // Verify first candidate driver name
      expect(
        find.text(
          DispatcherReassignDriverFakeData.defaultCandidates.first.name,
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders properly in English locale', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 882 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(
          locale: const Locale('en'),
          child: const DispatcherReassignDriverScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherReassignDriverScreen), findsOneWidget);
      expect(find.text('Assign Replacement Driver'), findsOneWidget);
      expect(find.text('Select Replacement Driver'), findsOneWidget);
      expect(find.text('Confirm Driver Selection'), findsOneWidget);
    });

    testWidgets('allows selecting another driver and triggers onConfirm', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 882 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      ReassignDriverCandidateEntity? selectedResult;

      await tester.pumpWidget(
        _buildTestableWidget(
          child: DispatcherReassignDriverScreen(
            onConfirm: (driver) {
              selectedResult = driver;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap second driver
      final secondDriver =
          DispatcherReassignDriverFakeData.defaultCandidates[1];
      await tester.tap(find.text(secondDriver.name));
      await tester.pumpAndSettle();

      // Tap confirm button
      await tester.tap(find.byType(ReassignDriverBottomButton));
      await tester.pumpAndSettle();

      expect(selectedResult, isNotNull);
      expect(selectedResult!.id, secondDriver.id);
      expect(selectedResult!.name, secondDriver.name);
    });

    testWidgets('renders without overflow on narrow viewport (360x720)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(360 * 2, 720 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(child: const DispatcherReassignDriverScreen()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow on extra small viewport (320x640)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320 * 2, 640 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(child: const DispatcherReassignDriverScreen()),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
