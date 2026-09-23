import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_candidate_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_details_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_driver_status_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_order_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_priority.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_summary_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/repo/assign_box_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/usecase/get_assign_box_details_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/usecase/get_assign_box_summary_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/manager/assign_box_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/presentation/manager/assign_box_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/assign_driver_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/driver_assignment_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/repo/dispatcher_drivers_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/usecase/assign_driver_to_box_usecase.dart';

class MockAssignBoxRepository implements AssignBoxRepository {
  int getDetailsCalls = 0;
  int getSummaryCalls = 0;
  Completer<ApiResult<AssignBoxDetailsEntity>>? detailsCompleter;
  Completer<ApiResult<AssignBoxSummaryEntity>>? summaryCompleter;

  ApiResult<AssignBoxDetailsEntity>? nextDetailsResult;
  ApiResult<AssignBoxSummaryEntity>? nextSummaryResult;

  @override
  Future<ApiResult<AssignBoxDetailsEntity>> getDetails(String boxId) {
    getDetailsCalls++;
    if (detailsCompleter != null) {
      return detailsCompleter!.future;
    }
    return Future.value(nextDetailsResult);
  }

  @override
  Future<ApiResult<AssignBoxSummaryEntity>> getSummary(String boxId) {
    getSummaryCalls++;
    if (summaryCompleter != null) {
      return summaryCompleter!.future;
    }
    return Future.value(nextSummaryResult);
  }
}

class MockDriversRepository implements DispatcherDriversRepository {
  int assignCalls = 0;
  AssignDriverRequestEntity? lastRequest;
  Completer<ApiResult<DriverAssignmentResultEntity>>? assignCompleter;
  ApiResult<DriverAssignmentResultEntity>? nextAssignResult;

  @override
  Future<ApiResult<DriverAssignmentResultEntity>> assignDriver(
    AssignDriverRequestEntity request,
  ) {
    assignCalls++;
    lastRequest = request;
    if (assignCompleter != null) {
      return assignCompleter!.future;
    }
    return Future.value(nextAssignResult);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  const boxId = 'a1111111-1111-1111-1111-111111111111';
  const driverId1 = '33333333-3333-3333-3333-333333333333';
  const driverId2 = '44444444-4444-4444-4444-444444444444';

  const sampleBox = AssignBoxOrderEntity(
    boxId: boxId,
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

  const sampleBestSuggestion = AssignBoxCandidateDriverEntity(
    driverId: driverId1,
    fullName: 'سالم الحربي',
    distanceText: '2.4 كم',
    activeOrdersCount: 1,
    currentLoadBoxes: 4,
    currentLoadLabel: '4 بوكسات',
    status: AssignBoxDriverStatusType.available,
    driverStatusText: 'متاح',
    statusTag: 'الأسرع وصولاً',
    estimatedFinishTimeText: '10:20 ص',
    rank: 1,
    isRecommended: true,
  );

  const sampleCandidate = AssignBoxCandidateDriverEntity(
    driverId: driverId2,
    fullName: 'عمر الدوسري',
    distanceText: '5.2 كم',
    activeOrdersCount: 3,
    currentLoadBoxes: 5,
    currentLoadLabel: '5 بوكسات',
    status: AssignBoxDriverStatusType.inDelivery,
    driverStatusText: 'في الطريق',
    statusTag: 'في المنطقة',
    estimatedFinishTimeText: '10:45 ص',
    rank: 2,
  );

  const sampleDetails = AssignBoxDetailsEntity(
    box: sampleBox,
    bestSuggestion: sampleBestSuggestion,
    candidates: [sampleCandidate],
  );

  const sampleSummary = AssignBoxSummaryEntity(
    boxId: boxId,
    boxCode: '#BX-1256',
    boxCount: 1,
  );

  late MockAssignBoxRepository boxRepo;
  late MockDriversRepository driversRepo;
  late GetAssignBoxDetailsUseCase getDetailsUseCase;
  late GetAssignBoxSummaryUseCase getSummaryUseCase;
  late AssignDriverToBoxUseCase assignDriverUseCase;
  late AssignBoxViewModel viewModel;

  setUp(() {
    boxRepo = MockAssignBoxRepository();
    driversRepo = MockDriversRepository();
    getDetailsUseCase = GetAssignBoxDetailsUseCase(boxRepo);
    getSummaryUseCase = GetAssignBoxSummaryUseCase(boxRepo);
    assignDriverUseCase = AssignDriverToBoxUseCase(driversRepo);
    viewModel = AssignBoxViewModel(
      getDetailsUseCase,
      getSummaryUseCase,
      assignDriverUseCase,
      boxId: boxId,
    );
  });

  group('AssignBoxViewModel - Details and Selection', () {
    test('initial load sets isInitialLoading and selects bestSuggestion by default', () async {
      boxRepo.detailsCompleter = Completer<ApiResult<AssignBoxDetailsEntity>>();

      final loadFuture = viewModel.doIntent(const LoadAssignBoxEvent());
      expect(viewModel.state.isInitialLoading, isTrue);

      boxRepo.detailsCompleter!.complete(const ApiSuccessResult(data: sampleDetails));
      await loadFuture;

      expect(viewModel.state.isInitialLoading, isFalse);
      expect(viewModel.state.details, sampleDetails);
      expect(viewModel.state.selectedDriverId, driverId1);
      expect(viewModel.state.canSubmit, isTrue);
    });

    test('initial load falls back to first candidate if bestSuggestion is null', () async {
      const detailsNoBest = AssignBoxDetailsEntity(
        box: sampleBox,
        bestSuggestion: null,
        candidates: [sampleCandidate],
      );
      boxRepo.nextDetailsResult = const ApiSuccessResult(data: detailsNoBest);

      await viewModel.doIntent(const LoadAssignBoxEvent());

      expect(viewModel.state.details, detailsNoBest);
      expect(viewModel.state.selectedDriverId, driverId2);
      expect(viewModel.state.canSubmit, isTrue);
    });

    test('initial load with no candidates leaves selectedDriverId null and canSubmit false', () async {
      const detailsEmpty = AssignBoxDetailsEntity(
        box: sampleBox,
        bestSuggestion: null,
        candidates: [],
      );
      boxRepo.nextDetailsResult = const ApiSuccessResult(data: detailsEmpty);

      await viewModel.doIntent(const LoadAssignBoxEvent());

      expect(viewModel.state.selectedDriverId, isNull);
      expect(viewModel.state.canSubmit, isFalse);
    });

    test('SelectAssignBoxDriverEvent updates single selection locally without API call', () async {
      boxRepo.nextDetailsResult = const ApiSuccessResult(data: sampleDetails);
      await viewModel.doIntent(const LoadAssignBoxEvent());
      expect(viewModel.state.selectedDriverId, driverId1);

      await viewModel.doIntent(const SelectAssignBoxDriverEvent(driverId2));
      expect(viewModel.state.selectedDriverId, driverId2);
      expect(boxRepo.getDetailsCalls, 1); // No new call made
    });

    test('refresh preserves selected driver if still in candidates, else falls back', () async {
      boxRepo.nextDetailsResult = const ApiSuccessResult(data: sampleDetails);
      await viewModel.doIntent(const LoadAssignBoxEvent());
      await viewModel.doIntent(const SelectAssignBoxDriverEvent(driverId2));
      expect(viewModel.state.selectedDriverId, driverId2);

      // Refresh 1: driverId2 is still present
      await viewModel.doIntent(const RefreshAssignBoxDetailsEvent());
      expect(viewModel.state.selectedDriverId, driverId2);

      // Refresh 2: driverId2 is no longer present
      const detailsWithoutDriver2 = AssignBoxDetailsEntity(
        box: sampleBox,
        bestSuggestion: sampleBestSuggestion,
        candidates: [],
      );
      boxRepo.nextDetailsResult = const ApiSuccessResult(data: detailsWithoutDriver2);
      await viewModel.doIntent(const RefreshAssignBoxDetailsEvent());
      expect(viewModel.state.selectedDriverId, driverId1); // fell back to bestSuggestion
    });
  });

  group('AssignBoxViewModel - Lazy Summary Caching and Retry', () {
    test('loads summary on first tap, caches it, and ignores duplicate calls', () async {
      boxRepo.nextSummaryResult = const ApiSuccessResult(data: sampleSummary);

      // First tap
      await viewModel.doIntent(const LoadAssignBoxSummaryEvent());
      expect(viewModel.state.summary, sampleSummary);
      expect(boxRepo.getSummaryCalls, 1);

      // Second tap: should return cached summary without calling API
      await viewModel.doIntent(const LoadAssignBoxSummaryEvent());
      expect(boxRepo.getSummaryCalls, 1);
    });

    test('ignores duplicate load summary tap while first call is in flight', () async {
      boxRepo.summaryCompleter = Completer<ApiResult<AssignBoxSummaryEntity>>();

      final call1 = viewModel.doIntent(const LoadAssignBoxSummaryEvent());
      expect(viewModel.state.isSummaryLoading, isTrue);

      // Second tap while still loading
      final call2 = viewModel.doIntent(const LoadAssignBoxSummaryEvent());
      expect(boxRepo.getSummaryCalls, 1);

      boxRepo.summaryCompleter!.complete(const ApiSuccessResult(data: sampleSummary));
      await Future.wait([call1, call2]);

      expect(viewModel.state.isSummaryLoading, isFalse);
      expect(viewModel.state.summary, sampleSummary);
    });

    test('summary retry clears failure and calls API again', () async {
      boxRepo.nextSummaryResult = ApiErrorResult(
        failure: Failure(
          errorMessage: 'Server error',
          code: '500',
          exception: const ApiException(
            errorType: ApiErrorType.serverError,
            message: 'Server error',
          ),
        ),
      );

      await viewModel.doIntent(const LoadAssignBoxSummaryEvent());
      expect(viewModel.state.summaryFailure, isNotNull);

      boxRepo.nextSummaryResult = const ApiSuccessResult(data: sampleSummary);
      await viewModel.doIntent(const RetryAssignBoxSummaryEvent());

      expect(viewModel.state.summaryFailure, isNull);
      expect(viewModel.state.summary, sampleSummary);
      expect(boxRepo.getSummaryCalls, 2);
    });
  });

  group('AssignBoxViewModel - Submit Assignment', () {
    test('submits with localizedNotes and selected driver, increments successId on success', () async {
      boxRepo.nextDetailsResult = const ApiSuccessResult(data: sampleDetails);
      await viewModel.doIntent(const LoadAssignBoxEvent());

      driversRepo.nextAssignResult = const ApiSuccessResult(
        data: DriverAssignmentResultEntity(
          success: true,
          message: 'تم إسناد البوكس بنجاح',
        ),
      );

      await viewModel.doIntent(
        const SubmitAssignBoxEvent(localizedNotes: 'إسناد سريع للبوكس #BX-1256'),
      );

      expect(driversRepo.assignCalls, 1);
      expect(driversRepo.lastRequest?.boxId, boxId);
      expect(driversRepo.lastRequest?.driverId, driverId1);
      expect(driversRepo.lastRequest?.notes, 'إسناد سريع للبوكس #BX-1256');

      expect(viewModel.state.successId, 1);
      expect(viewModel.state.assignmentResult?.message, 'تم إسناد البوكس بنجاح');
    });

    test('ignores duplicate submit taps while submission is in progress', () async {
      boxRepo.nextDetailsResult = const ApiSuccessResult(data: sampleDetails);
      await viewModel.doIntent(const LoadAssignBoxEvent());

      driversRepo.assignCompleter = Completer<ApiResult<DriverAssignmentResultEntity>>();

      final tap1 = viewModel.doIntent(
        const SubmitAssignBoxEvent(localizedNotes: 'Note'),
      );
      expect(viewModel.state.isSubmitting, isTrue);

      final tap2 = viewModel.doIntent(
        const SubmitAssignBoxEvent(localizedNotes: 'Note'),
      );
      expect(driversRepo.assignCalls, 1);

      driversRepo.assignCompleter!.complete(
        const ApiSuccessResult(
          data: DriverAssignmentResultEntity(success: true, message: 'Done'),
        ),
      );
      await Future.wait([tap1, tap2]);
      expect(viewModel.state.isSubmitting, isFalse);
    });

    test('submit 409 conflict emits failure notice and triggers details refresh', () async {
      boxRepo.nextDetailsResult = const ApiSuccessResult(data: sampleDetails);
      await viewModel.doIntent(const LoadAssignBoxEvent());

      driversRepo.nextAssignResult = ApiErrorResult(
        failure: Failure(
          errorMessage: 'Driver busy',
          code: '409',
          exception: const ApiException(
            errorType: ApiErrorType.conflict,
            message: 'Driver busy',
          ),
        ),
      );

      await viewModel.doIntent(
        const SubmitAssignBoxEvent(localizedNotes: 'Note'),
      );

      expect(viewModel.state.submitFailure, isNotNull);
      expect(viewModel.state.noticeId, 1);
      // Detail calls should be 2 because refresh was triggered
      expect(boxRepo.getDetailsCalls, 2);
    });
  });
}
