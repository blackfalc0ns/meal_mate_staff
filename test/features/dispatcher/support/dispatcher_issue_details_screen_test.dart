import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/dispatcher/support/domain/fake_data/dispatcher_issue_detail_fake_data.dart';
import 'package:meal_mate_delivery/features/dispatcher/support/presentation/screens/dispatcher_issue_details_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/support/presentation/widgets/dispatcher_issue_details_action_buttons.dart';
import 'package:meal_mate_delivery/features/dispatcher/support/presentation/widgets/dispatcher_issue_details_attachments_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/support/presentation/widgets/dispatcher_issue_details_description_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/support/presentation/widgets/dispatcher_issue_details_driver_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/support/presentation/widgets/dispatcher_issue_details_header_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/support/presentation/widgets/dispatcher_issue_details_trip_card.dart';

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

  group('DispatcherIssueDetailsScreen Tests', () {
    testWidgets('renders all major components and cards in RTL',
        (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 907 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(
          child: const DispatcherIssueDetailsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherIssueDetailsScreen), findsOneWidget);
      expect(find.byType(DispatcherIssueDetailsHeaderCard), findsOneWidget);
      expect(find.byType(DispatcherIssueDetailsDriverCard), findsOneWidget);
      expect(find.byType(DispatcherIssueDetailsDescriptionCard), findsOneWidget);
      expect(find.byType(DispatcherIssueDetailsAttachmentsCard), findsOneWidget);
      expect(find.byType(DispatcherIssueDetailsTripCard), findsOneWidget);
      expect(find.byType(DispatcherIssueDetailsActionButtons), findsOneWidget);

      // Verify header details
      expect(
        find.text(DispatcherIssueDetailFakeData.sampleIssueDetail.title),
        findsOneWidget,
      );
      expect(
        find.text(DispatcherIssueDetailFakeData.sampleIssueDetail.taskNumber),
        findsOneWidget,
      );
      expect(
        find.text(DispatcherIssueDetailFakeData.sampleIssueDetail.area),
        findsOneWidget,
      );

      // Verify driver info
      expect(
        find.text(DispatcherIssueDetailFakeData.sampleIssueDetail.driverName),
        findsOneWidget,
      );
      expect(
        find.text(DispatcherIssueDetailFakeData.sampleIssueDetail.driverCode),
        findsOneWidget,
      );

      // Verify trip info
      expect(
        find.text(DispatcherIssueDetailFakeData.sampleIssueDetail.clientName),
        findsOneWidget,
      );
      expect(
        find.text(
          DispatcherIssueDetailFakeData.sampleIssueDetail.pickupLocation,
        ),
        findsOneWidget,
      );
    });

    testWidgets('renders properly in LTR English without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 907 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestableWidget(
          locale: const Locale('en'),
          child: const DispatcherIssueDetailsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DispatcherIssueDetailsScreen), findsOneWidget);
      expect(find.text('Problem Details'), findsOneWidget);
      expect(find.text('Driver Info'), findsOneWidget);
      expect(find.text('Quick Actions'), findsOneWidget);
    });

    testWidgets('quick action buttons are tappable', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 907 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool assignTapped = false;
      bool contactTapped = false;

      await tester.pumpWidget(
        _buildTestableWidget(
          child: Scaffold(
            body: DispatcherIssueDetailsActionButtons(
              onAssignReplacementTap: () => assignTapped = true,
              onContactDriverTap: () => contactTapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(assignTapped, isTrue);

      await tester.tap(find.byType(OutlinedButton));
      await tester.pump();
      expect(contactTapped, isTrue);
    });
  });
}
