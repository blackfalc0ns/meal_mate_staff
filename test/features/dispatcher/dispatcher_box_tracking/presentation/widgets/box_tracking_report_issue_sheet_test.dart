import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_issue_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/report_box_issue_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/report_box_issue_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/repo/box_tracking_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/usecase/get_box_tracking_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/usecase/report_box_issue_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/presentation/manager/box_tracking_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_report_issue_sheet.dart';

class _FakeBoxTrackingRepo implements BoxTrackingRepository {
  Completer<ApiResult<ReportBoxIssueResultEntity>>? reportIssueCompleter;
  int reportIssueCallCount = 0;
  ReportBoxIssueRequestEntity? lastRequest;

  @override
  Future<ApiResult<BoxTrackingEntity>> getTracking(String boxId) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<ReportBoxIssueResultEntity>> reportIssue(
    String boxId,
    ReportBoxIssueRequestEntity request,
  ) {
    reportIssueCallCount++;
    lastRequest = request;
    if (reportIssueCompleter != null) {
      return reportIssueCompleter!.future;
    }
    return Future.value(
      const ApiSuccessResult(
        data: ReportBoxIssueResultEntity(
          boxId: '4f8a3c21-9b12-42e7-90c1-872f2316e110',
          issueId: 'iss-123',
          reportedAtUtc: null,
          message: 'Success',
        ),
      ),
    );
  }
}

Widget _buildWrapper({
  required Widget child,
  Locale locale = const Locale('ar'),
}) {
  return MaterialApp(
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: AppTheme.lightTheme,
    home: Scaffold(body: child),
  );
}

void main() {
  const testBoxId = '4f8a3c21-9b12-42e7-90c1-872f2316e110';
  late _FakeBoxTrackingRepo repo;
  late BoxTrackingViewModel viewModel;

  setUp(() {
    repo = _FakeBoxTrackingRepo();
    viewModel = BoxTrackingViewModel(
      GetBoxTrackingUseCase(repo),
      ReportBoxIssueUseCase(repo),
      boxId: testBoxId,
    );
  });

  tearDown(() async {
    await viewModel.close();
  });

  group('BoxTrackingReportIssueSheet', () {
    testWidgets('renders all 5 issue types and input field', (tester) async {
      await tester.pumpWidget(
        _buildWrapper(
          child: BlocProvider.value(
            value: viewModel,
            child: BoxTrackingReportIssueSheet(viewModel: viewModel),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check title or issue type choices
      expect(find.byType(TextField), findsOneWidget);
      // All 5 issue types exist
      expect(find.text('صندوق تالف'), findsOneWidget);
      expect(find.text('تأخر في التوصيل'), findsOneWidget);
      expect(find.text('عنوان خاطئ'), findsOneWidget);
      expect(find.text('العميل غير متاح'), findsOneWidget);
      expect(find.text('أخرى'), findsOneWidget);
    });

    testWidgets('selection of issue type updates state', (tester) async {
      await tester.pumpWidget(
        _buildWrapper(
          child: BlocProvider.value(
            value: viewModel,
            child: BoxTrackingReportIssueSheet(viewModel: viewModel),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Default is other
      expect(viewModel.state.selectedIssueType, BoxIssueType.other);

      // Tap damagedBox option
      await tester.tap(find.text('صندوق تالف'));
      await tester.pumpAndSettle();

      expect(viewModel.state.selectedIssueType, BoxIssueType.damagedBox);
    });

    testWidgets('submit is disabled when description is empty', (tester) async {
      await tester.pumpWidget(
        _buildWrapper(
          child: BlocProvider.value(
            value: viewModel,
            child: BoxTrackingReportIssueSheet(viewModel: viewModel),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final submitBtnFinder = find.byKey(
        const Key('box_tracking_report_submit_button'),
      );
      expect(submitBtnFinder, findsOneWidget);

      // Attempt tap while empty
      await tester.tap(submitBtnFinder);
      await tester.pumpAndSettle();

      expect(repo.reportIssueCallCount, 0);
    });

    testWidgets(
      'entering description enables submit and dispatches submit event',
      (tester) async {
        await tester.pumpWidget(
          _buildWrapper(
            child: BlocProvider.value(
              value: viewModel,
              child: BoxTrackingReportIssueSheet(viewModel: viewModel),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Enter text
        await tester.enterText(find.byType(TextField), 'الصندوق ممزق بالكامل');
        await tester.pumpAndSettle();

        expect(viewModel.state.issueDescription, 'الصندوق ممزق بالكامل');

        final submitBtnFinder = find.byKey(
          const Key('box_tracking_report_submit_button'),
        );
        await tester.tap(submitBtnFinder);
        await tester.pumpAndSettle();

        expect(repo.reportIssueCallCount, 1);
        expect(repo.lastRequest?.description, 'الصندوق ممزق بالكامل');
      },
    );

    testWidgets('shows loading state while isSubmittingIssue is true', (
      tester,
    ) async {
      repo.reportIssueCompleter = Completer();

      await tester.pumpWidget(
        _buildWrapper(
          child: BlocProvider.value(
            value: viewModel,
            child: BoxTrackingReportIssueSheet(viewModel: viewModel),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'الصندوق ممزق');
      await tester.pumpAndSettle();

      final submitBtnFinder = find.byKey(
        const Key('box_tracking_report_submit_button'),
      );
      await tester.tap(submitBtnFinder);
      await tester.pump();

      expect(viewModel.state.isSubmittingIssue, isTrue);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Clean up completer
      repo.reportIssueCompleter!.complete(
        const ApiSuccessResult(
          data: ReportBoxIssueResultEntity(
            boxId: testBoxId,
            issueId: 'iss-1',
            reportedAtUtc: null,
            message: 'Done',
          ),
        ),
      );
      await tester.pumpAndSettle();
    });
  });
}
