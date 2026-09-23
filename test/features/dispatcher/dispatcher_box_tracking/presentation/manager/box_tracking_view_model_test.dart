import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_issue_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/report_box_issue_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/report_box_issue_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/repo/box_tracking_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/usecase/get_box_tracking_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/usecase/report_box_issue_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/presentation/manager/box_tracking_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/presentation/manager/box_tracking_view_model.dart';

class _FakeBoxTrackingRepo implements BoxTrackingRepository {
  Completer<ApiResult<BoxTrackingEntity>>? getTrackingCompleter;
  Completer<ApiResult<ReportBoxIssueResultEntity>>? reportIssueCompleter;
  int reportIssueCallCount = 0;

  @override
  Future<ApiResult<BoxTrackingEntity>> getTracking(String boxId) {
    if (getTrackingCompleter != null) {
      return getTrackingCompleter!.future;
    }
    return Future.value(const ApiSuccessResult(data: _testTracking));
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
          issueId: 'iss-1',
          boxId: '4f8a3c21-9b12-42e7-90c1-872f2316e110',
          reportedAtUtc: null,
          message: 'تم الإبلاغ بنجاح',
        ),
      ),
    );
  }
}

const _testTracking = BoxTrackingEntity(
  boxId: '4f8a3c21-9b12-42e7-90c1-872f2316e110',
  boxCode: '#BX-10256',
  status: BoxTrackingStatus.onTheWay,
  statusText: 'في الطريق',
  statusColor: '#3B82F6',
  customerName: 'أحمد',
  scheduledTimeText: '12:00 م',
  deliveryAddress: 'الرياض',
  programType: 'دايت',
  orderDateText: 'اليوم',
  customerNotes: 'ملاحظة',
  mealsSummary: '2 وجبات',
  steps: [],
);

void main() {
  late _FakeBoxTrackingRepo fakeRepo;
  late GetBoxTrackingUseCase getTrackingUseCase;
  late ReportBoxIssueUseCase reportIssueUseCase;
  late BoxTrackingViewModel viewModel;

  const testBoxId = '4f8a3c21-9b12-42e7-90c1-872f2316e110';

  setUp(() {
    fakeRepo = _FakeBoxTrackingRepo();
    getTrackingUseCase = GetBoxTrackingUseCase(fakeRepo);
    reportIssueUseCase = ReportBoxIssueUseCase(fakeRepo);
    viewModel = BoxTrackingViewModel(
      getTrackingUseCase,
      reportIssueUseCase,
      boxId: testBoxId,
    );
  });

  tearDown(() async {
    await viewModel.close();
  });

  group('BoxTrackingViewModel', () {
    test('initial state has correct defaults', () {
      expect(viewModel.state.boxId, testBoxId);
      expect(viewModel.state.tracking, isNull);
      expect(viewModel.state.isInitialLoading, isFalse);
      expect(viewModel.state.isRefreshing, isFalse);
      expect(viewModel.state.selectedIssueType, BoxIssueType.other);
      expect(viewModel.state.issueDescription, isEmpty);
      expect(viewModel.state.isSubmittingIssue, isFalse);
    });

    test(
      'LoadBoxTrackingEvent sets loading, fetches data and populates tracking',
      () async {
        fakeRepo.getTrackingCompleter = Completer();

        final future = viewModel.doIntent(const LoadBoxTrackingEvent());
        expect(viewModel.state.isInitialLoading, isTrue);

        fakeRepo.getTrackingCompleter!.complete(
          const ApiSuccessResult(data: _testTracking),
        );
        await future;

        expect(viewModel.state.isInitialLoading, isFalse);
        expect(viewModel.state.tracking, _testTracking);
        expect(viewModel.state.initialFailure, isNull);
      },
    );

    test('LoadBoxTrackingEvent handles failure', () async {
      fakeRepo.getTrackingCompleter = Completer();

      final future = viewModel.doIntent(const LoadBoxTrackingEvent());
      expect(viewModel.state.isInitialLoading, isTrue);

      fakeRepo.getTrackingCompleter!.complete(
        ApiErrorResult(failure: Failure(errorMessage: 'Network error')),
      );
      await future;

      expect(viewModel.state.isInitialLoading, isFalse);
      expect(viewModel.state.tracking, isNull);
      expect(viewModel.state.initialFailure?.errorMessage, 'Network error');
    });

    test(
      'RefreshBoxTrackingEvent preserves tracking on error and sets nonFatalFailure',
      () async {
        // First load tracking
        await viewModel.doIntent(const LoadBoxTrackingEvent());
        expect(viewModel.state.tracking, isNotNull);

        // Now refresh fails
        fakeRepo.getTrackingCompleter = Completer();
        final future = viewModel.doIntent(const RefreshBoxTrackingEvent());
        expect(viewModel.state.isRefreshing, isTrue);

        fakeRepo.getTrackingCompleter!.complete(
          ApiErrorResult(failure: Failure(errorMessage: 'Refresh failed')),
        );
        await future;

        expect(viewModel.state.isRefreshing, isFalse);
        expect(viewModel.state.tracking, _testTracking); // Preserved!
        expect(viewModel.state.nonFatalFailure?.errorMessage, 'Refresh failed');
        expect(viewModel.state.noticeId, 1);
      },
    );

    test('form events update issueType and description', () async {
      await viewModel.doIntent(
        const ChangeBoxIssueTypeEvent(BoxIssueType.damagedBox),
      );
      expect(viewModel.state.selectedIssueType, BoxIssueType.damagedBox);

      await viewModel.doIntent(
        const ChangeBoxIssueDescriptionEvent('صندوق تالف'),
      );
      expect(viewModel.state.issueDescription, 'صندوق تالف');
    });

    test('SubmitBoxIssueEvent guards against empty description', () async {
      await viewModel.doIntent(const ChangeBoxIssueDescriptionEvent('   '));
      await viewModel.doIntent(const SubmitBoxIssueEvent());

      expect(fakeRepo.reportIssueCallCount, 0);
      expect(viewModel.state.isSubmittingIssue, isFalse);
    });

    test(
      'SubmitBoxIssueEvent submits successfully, clears form and sets success message',
      () async {
        await viewModel.doIntent(
          const ChangeBoxIssueTypeEvent(BoxIssueType.delayedDelivery),
        );
        await viewModel.doIntent(const ChangeBoxIssueDescriptionEvent('تأخير'));

        fakeRepo.reportIssueCompleter = Completer();
        final future = viewModel.doIntent(const SubmitBoxIssueEvent());
        expect(viewModel.state.isSubmittingIssue, isTrue);

        fakeRepo.reportIssueCompleter!.complete(
          const ApiSuccessResult(
            data: ReportBoxIssueResultEntity(
              issueId: 'iss-1',
              boxId: testBoxId,
              reportedAtUtc: null,
              message: 'تم الإبلاغ بنجاح',
            ),
          ),
        );
        await future;

        expect(viewModel.state.isSubmittingIssue, isFalse);
        expect(viewModel.state.reportSuccessMessage, 'تم الإبلاغ بنجاح');
        expect(viewModel.state.reportNoticeId, 1);
        expect(viewModel.state.issueDescription, isEmpty);
        expect(viewModel.state.selectedIssueType, BoxIssueType.other);
      },
    );

    test('SubmitBoxIssueEvent preserves form on failure', () async {
      await viewModel.doIntent(
        const ChangeBoxIssueTypeEvent(BoxIssueType.damagedBox),
      );
      await viewModel.doIntent(
        const ChangeBoxIssueDescriptionEvent('الصندوق مكسور'),
      );

      fakeRepo.reportIssueCompleter = Completer();
      final future = viewModel.doIntent(const SubmitBoxIssueEvent());
      expect(viewModel.state.isSubmittingIssue, isTrue);

      fakeRepo.reportIssueCompleter!.complete(
        ApiErrorResult(failure: Failure(errorMessage: 'خطأ بالسيرفر')),
      );
      await future;

      expect(viewModel.state.isSubmittingIssue, isFalse);
      expect(viewModel.state.reportFailure?.errorMessage, 'خطأ بالسيرفر');
      expect(viewModel.state.reportNoticeId, 1);
      expect(viewModel.state.issueDescription, 'الصندوق مكسور'); // Preserved!
      expect(viewModel.state.selectedIssueType, BoxIssueType.damagedBox);
    });
  });
}
