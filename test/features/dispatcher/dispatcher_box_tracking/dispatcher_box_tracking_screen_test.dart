import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_step_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_step_icon_kind.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_step_state.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/report_box_issue_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/report_box_issue_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/repo/box_tracking_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/usecase/get_box_tracking_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/usecase/report_box_issue_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/presentation/manager/box_tracking_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/presentation/screens/dispatcher_box_tracking_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_app_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_details_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_driver_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_header_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_report_issue_button.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_report_issue_sheet.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/presentation/widgets/box_tracking_timeline_card.dart';

const _testBoxId = '4f8a3c21-9b12-42e7-90c1-872f2316e110';

const _testTracking = BoxTrackingEntity(
  boxId: _testBoxId,
  boxCode: '#BX-10256',
  status: BoxTrackingStatus.onTheWay,
  statusText: 'في الطريق للتوصيل',
  statusColor: '#3B82F6',
  customerName: 'أحمد العتيبي',
  scheduledTimeText: '12:30 م - 01:30 م',
  deliveryAddress: 'شارع الملك فهد، حي الصحافة',
  driver: BoxTrackingDriverEntity(
    driverId: 'drv-1',
    driverCode: 'DR-1025',
    fullName: 'أحمد السعيد',
    phoneNumber: '+966501234567',
    avatarUrl: null,
  ),
  programType: 'دايت متوازن',
  orderDateText: 'اليوم 09:50 ص',
  customerNotes: 'يرجى الاتصال قبل الوصول',
  mealsSummary: '3 وجبات (يوم كامل)',
  steps: [
    BoxTrackingStepEntity(
      step: 1,
      state: BoxTrackingStepState.completed,
      iconKind: BoxTrackingStepIconKind.restaurant,
      title: 'جاهز في المطعم',
      description: 'تم تجهيز البوكس وجاهز للاستلام',
      time: '09:15 ص',
    ),
    BoxTrackingStepEntity(
      step: 2,
      state: BoxTrackingStepState.completed,
      iconKind: BoxTrackingStepIconKind.driver,
      title: 'استلمه السائق',
      description: 'أحمد السعيد استلم البوكس',
      time: '09:30 ص',
    ),
    BoxTrackingStepEntity(
      step: 3,
      state: BoxTrackingStepState.active,
      iconKind: BoxTrackingStepIconKind.truck,
      title: 'في الطريق للتوصيل',
      description: 'البوكس في طريقه إلى العميل',
      time: '10:00 ص',
    ),
    BoxTrackingStepEntity(
      step: 4,
      state: BoxTrackingStepState.pending,
      iconKind: BoxTrackingStepIconKind.receipt,
      title: 'تم التسليم',
      description: 'سيفتح السائق كود العميل لتأكيد التسليم',
      time: null,
    ),
  ],
);

class _FakeBoxTrackingRepo implements BoxTrackingRepository {
  Completer<ApiResult<BoxTrackingEntity>>? getTrackingCompleter;
  ApiResult<BoxTrackingEntity>? getTrackingResult;
  int getTrackingCallCount = 0;

  Completer<ApiResult<ReportBoxIssueResultEntity>>? reportIssueCompleter;
  int reportIssueCallCount = 0;

  @override
  Future<ApiResult<BoxTrackingEntity>> getTracking(String boxId) {
    getTrackingCallCount++;
    if (getTrackingCompleter != null) {
      return getTrackingCompleter!.future;
    }
    return Future.value(
      getTrackingResult ?? const ApiSuccessResult(data: _testTracking),
    );
  }

  @override
  Future<ApiResult<ReportBoxIssueResultEntity>> reportIssue(
    String boxId,
    ReportBoxIssueRequestEntity request,
  ) {
    reportIssueCallCount++;
    if (reportIssueCompleter != null) {
      return reportIssueCompleter!.future;
    }
    return Future.value(
      const ApiSuccessResult(
        data: ReportBoxIssueResultEntity(
          boxId: _testBoxId,
          issueId: 'iss-123',
          reportedAtUtc: null,
          message: 'تم الإبلاغ بنجاح',
        ),
      ),
    );
  }
}

void main() {
  late _FakeBoxTrackingRepo repo;
  late BoxTrackingViewModel viewModel;

  setUp(() {
    repo = _FakeBoxTrackingRepo();
    viewModel = BoxTrackingViewModel(
      GetBoxTrackingUseCase(repo),
      ReportBoxIssueUseCase(repo),
      boxId: _testBoxId,
    );
  });

  tearDown(() async {
    await viewModel.close();
  });

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
        boxId: _testBoxId,
        viewModel: viewModel,
        onBack: onBack,
        onMore: onMore,
        onLiveTracking: onLiveTracking,
        onSendMessage: onSendMessage,
        onCall: onCall,
        onReportIssue: onReportIssue,
      ),
    );
  }

  group('DispatcherBoxTrackingScreen Integration Tests', () {
    testWidgets(
      'shows BoxTrackingShimmer initially while tracking is loading',
      (tester) async {
        repo.getTrackingCompleter = Completer();

        await tester.pumpWidget(buildSubject());
        await tester.pump();

        expect(find.byType(BoxTrackingShimmer), findsOneWidget);
        expect(find.byType(BoxTrackingHeaderCard), findsNothing);

        repo.getTrackingCompleter!.complete(
          const ApiSuccessResult(data: _testTracking),
        );
        await tester.pumpAndSettle();

        expect(find.byType(BoxTrackingShimmer), findsNothing);
        expect(find.byType(BoxTrackingHeaderCard), findsOneWidget);
      },
    );

    testWidgets('renders all loaded sections and data on success', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.byType(BoxTrackingAppBar), findsOneWidget);
      expect(find.byType(BoxTrackingHeaderCard), findsOneWidget);
      expect(find.byType(BoxTrackingTimelineCard), findsOneWidget);
      expect(find.byType(BoxTrackingDriverCard), findsOneWidget);
      expect(find.byType(BoxTrackingDetailsCard), findsOneWidget);
      expect(find.byType(BoxTrackingReportIssueButton), findsOneWidget);

      expect(find.text('#BX-10256'), findsOneWidget);
      expect(find.text('أحمد السعيد'), findsOneWidget);
      expect(find.text('دايت متوازن'), findsOneWidget);
    });

    testWidgets(
      'renders ApiErrorWidget on initial load failure and retry triggers reload',
      (tester) async {
        repo.getTrackingResult = ApiErrorResult(
          failure: Failure.fromException(
            const ApiException(
              message: 'Server error',
              errorType: ApiErrorType.serverError,
            ),
          ),
        );

        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        expect(find.byType(ApiErrorWidget), findsOneWidget);
        expect(find.byType(BoxTrackingHeaderCard), findsNothing);
        expect(repo.getTrackingCallCount, 1);

        // Now prepare success for retry
        repo.getTrackingResult = const ApiSuccessResult(data: _testTracking);
        final retryBtnFinder = find.widgetWithText(
          ElevatedButton,
          'إعادة المحاولة',
        );
        if (retryBtnFinder.evaluate().isNotEmpty) {
          await tester.tap(retryBtnFinder);
        } else {
          // Find any InkWell / Button in ApiErrorWidget
          await tester.tap(find.byType(ApiErrorWidget));
        }
        await tester.pumpAndSettle();

        expect(repo.getTrackingCallCount, 2);
        expect(find.byType(BoxTrackingHeaderCard), findsOneWidget);
      },
    );

    testWidgets(
      'tapping report issue button opens BoxTrackingReportIssueSheet',
      (tester) async {
        await tester.pumpWidget(buildSubject());
        await tester.pumpAndSettle();

        final reportBtnFinder = find.byType(BoxTrackingReportIssueButton);
        await tester.ensureVisible(reportBtnFinder);
        await tester.tap(reportBtnFinder);
        await tester.pumpAndSettle();

        expect(find.byType(BoxTrackingReportIssueSheet), findsOneWidget);
      },
    );

    testWidgets('renders without overflow on narrow 320x640 viewport', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(BoxTrackingHeaderCard), findsOneWidget);
    });
  });
}
