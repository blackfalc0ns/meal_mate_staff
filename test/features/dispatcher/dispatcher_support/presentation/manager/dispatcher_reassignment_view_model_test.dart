import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_response_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassign_driver_candidate_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassign_driver_candidates_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassign_driver_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassignment_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/repo/dispatcher_support_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/usecase/get_replacement_driver_candidates_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/usecase/reassign_dispatcher_issue_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/manager/reassignment/dispatcher_reassignment_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/manager/reassignment/dispatcher_reassignment_view_model.dart';

class _MockSupportRepo implements DispatcherSupportRepository {
  ApiResult<ReassignDriverCandidatesEntity>? nextCandidatesResult;
  ApiResult<ReassignmentResultEntity>? nextReassignResult;
  int getCandidatesCallCount = 0;
  int reassignCallCount = 0;
  int lastRequestedPage = 1;
  String? lastReassignedDriverId;

  @override
  Future<ApiResult<ReassignDriverCandidatesEntity>> getReplacementCandidates(
    String issueId, {
    int pageNumber = 1,
    int pageSize = 20,
  }) async {
    getCandidatesCallCount++;
    lastRequestedPage = pageNumber;
    return nextCandidatesResult ??
        ApiSuccessResult(
          data: _buildCandidates(
            issueId: issueId,
            candidates: [_buildCandidate('cand-1', 'سائق 1')],
            page: pageNumber,
          ),
        );
  }

  @override
  Future<ApiResult<ReassignmentResultEntity>> reassignIssue(
    String issueId,
    ReassignDriverRequestEntity request,
  ) async {
    reassignCallCount++;
    lastReassignedDriverId = request.replacementDriverId;
    return nextReassignResult ??
        ApiSuccessResult(
          data: ReassignmentResultEntity(
            issueId: issueId,
            status: DispatcherIssueStatus.resolved,
            reassignedDriver: DispatcherIssueDriverEntity(
              id: request.replacementDriverId,
              name: 'سائق بديل',
              code: 'DRV-NEW',
            ),
          ),
        );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ReassignDriverCandidateEntity _buildCandidate(String id, String name, {int rank = 1}) {
  return ReassignDriverCandidateEntity(
    id: id,
    name: name,
    code: 'CODE-$id',
    rating: 4.8,
    distanceKm: 2.5,
    recommendationRank: rank,
  );
}

ReassignDriverCandidatesEntity _buildCandidates({
  required String issueId,
  List<ReassignDriverCandidateEntity> candidates = const [],
  int page = 1,
  bool hasNextPage = false,
}) {
  return ReassignDriverCandidatesEntity(
    summary: ReassignDriverIssueSummaryEntity(
      issueId: issueId,
      title: 'عطل في المركبة',
      taskNumber: 'TASK-1',
    ),
    currentDriver: const DispatcherIssueDriverEntity(
      id: 'current-drv',
      name: 'السائق الحالي',
      code: 'DRV-CURR',
    ),
    candidates: candidates,
    pagination: DispatcherSupportPaginationEntity(
      pageNumber: page,
      pageSize: 20,
      totalCount: candidates.length,
      totalPages: hasNextPage ? page + 1 : page,
      hasNextPage: hasNextPage,
      hasPreviousPage: page > 1,
    ),
  );
}

void main() {
  late _MockSupportRepo repository;
  late GetReplacementDriverCandidatesUseCase getCandidatesUseCase;
  late ReassignDispatcherIssueUseCase reassignUseCase;

  setUp(() {
    repository = _MockSupportRepo();
    getCandidatesUseCase = GetReplacementDriverCandidatesUseCase(repository);
    reassignUseCase = ReassignDispatcherIssueUseCase(repository);
  });

  DispatcherReassignmentViewModel createViewModel({String issueId = 'issue-200'}) {
    return DispatcherReassignmentViewModel(
      issueId: issueId,
      getCandidatesUseCase: getCandidatesUseCase,
      reassignUseCase: reassignUseCase,
    );
  }

  test('initial state is correct', () async {
    final vm = createViewModel();
    expect(vm.state.data, isNull);
    expect(vm.state.selectedDriverId, isNull);
    expect(vm.state.isInitialLoading, isFalse);
    expect(vm.state.isRefreshing, isFalse);
    expect(vm.state.isNextPageLoading, isFalse);
    expect(vm.state.isSubmitting, isFalse);
    expect(vm.state.initialFailure, isNull);
    expect(vm.state.pageFailure, isNull);
    expect(vm.state.submitFailure, isNull);
    expect(vm.state.terminalIssueConflict, isFalse);
    expect(vm.state.successResult, isNull);
    expect(vm.state.canSubmit, isFalse);
    await vm.close();
  });

  test('LoadReplacementCandidates loads page 1 and auto-selects first ranked driver', () async {
    final vm = createViewModel();
    final candidatesData = _buildCandidates(
      issueId: 'issue-200',
      candidates: [
        _buildCandidate('driver-1', 'الأول', rank: 1),
        _buildCandidate('driver-2', 'الثاني', rank: 2),
      ],
    );
    repository.nextCandidatesResult = ApiSuccessResult(data: candidatesData);

    await vm.doIntent(const LoadReplacementCandidates());

    expect(vm.state.isInitialLoading, isFalse);
    expect(vm.state.data?.candidates.length, 2);
    expect(vm.state.selectedDriverId, 'driver-1');
    expect(vm.state.canSubmit, isTrue);
    expect(vm.state.initialFailure, isNull);
    await vm.close();
  });

  test('LoadReplacementCandidates with empty list sets selectedDriverId to null and canSubmit to false', () async {
    final vm = createViewModel();
    repository.nextCandidatesResult = ApiSuccessResult(
      data: _buildCandidates(issueId: 'issue-200', candidates: []),
    );

    await vm.doIntent(const LoadReplacementCandidates());

    expect(vm.state.data?.candidates, isEmpty);
    expect(vm.state.selectedDriverId, isNull);
    expect(vm.state.canSubmit, isFalse);
    await vm.close();
  });

  test('LoadReplacementCandidates failure emits initialFailure and leaves data null', () async {
    final vm = createViewModel();
    final failure = Failure(errorMessage: 'Network timeout');
    repository.nextCandidatesResult = ApiErrorResult(failure: failure);

    await vm.doIntent(const LoadReplacementCandidates());

    expect(vm.state.isInitialLoading, isFalse);
    expect(vm.state.data, isNull);
    expect(vm.state.initialFailure, failure);
    expect(vm.state.canSubmit, isFalse);
    await vm.close();
  });

  test('RetryReplacementCandidates recovers after initial failure', () async {
    final vm = createViewModel();
    repository.nextCandidatesResult = ApiErrorResult(failure: Failure(errorMessage: 'Failed'));
    await vm.doIntent(const LoadReplacementCandidates());
    expect(vm.state.initialFailure, isNotNull);

    repository.nextCandidatesResult = ApiSuccessResult(
      data: _buildCandidates(
        issueId: 'issue-200',
        candidates: [_buildCandidate('d-1', 'سائق')],
      ),
    );
    await vm.doIntent(const RetryReplacementCandidates());

    expect(vm.state.initialFailure, isNull);
    expect(vm.state.data?.candidates.length, 1);
    expect(vm.state.selectedDriverId, 'd-1');
    await vm.close();
  });

  test('RefreshReplacementCandidates retains prior data during refresh and preserves selection if present', () async {
    final vm = createViewModel();
    repository.nextCandidatesResult = ApiSuccessResult(
      data: _buildCandidates(
        issueId: 'issue-200',
        candidates: [
          _buildCandidate('d-1', 'سائق 1'),
          _buildCandidate('d-2', 'سائق 2'),
        ],
      ),
    );
    await vm.doIntent(const LoadReplacementCandidates());
    await vm.doIntent(const SelectReplacementDriver('d-2'));
    expect(vm.state.selectedDriverId, 'd-2');

    // Refresh with both drivers still there
    repository.nextCandidatesResult = ApiSuccessResult(
      data: _buildCandidates(
        issueId: 'issue-200',
        candidates: [
          _buildCandidate('d-1', 'سائق 1'),
          _buildCandidate('d-2', 'سائق 2'),
        ],
      ),
    );
    await vm.doIntent(const RefreshReplacementCandidates());

    expect(vm.state.isRefreshing, isFalse);
    expect(vm.state.selectedDriverId, 'd-2'); // Preserved!
    await vm.close();
  });

  test('LoadNextReplacementCandidatesPage appends new candidates and de-duplicates', () async {
    final vm = createViewModel();
    repository.nextCandidatesResult = ApiSuccessResult(
      data: _buildCandidates(
        issueId: 'issue-200',
        page: 1,
        hasNextPage: true,
        candidates: [_buildCandidate('d-1', 'سائق 1')],
      ),
    );
    await vm.doIntent(const LoadReplacementCandidates());
    expect(vm.state.data?.candidates.length, 1);

    // Page 2 returns d-1 (duplicate) and d-2 (new)
    repository.nextCandidatesResult = ApiSuccessResult(
      data: _buildCandidates(
        issueId: 'issue-200',
        page: 2,
        hasNextPage: false,
        candidates: [
          _buildCandidate('d-1', 'سائق 1'),
          _buildCandidate('d-2', 'سائق 2'),
        ],
      ),
    );

    await vm.doIntent(const LoadNextReplacementCandidatesPage());

    expect(repository.lastRequestedPage, 2);
    expect(vm.state.data?.candidates.length, 2); // De-duplicated: d-1 was not added twice
    expect(vm.state.data?.candidates.map((c) => c.id).toList(), ['d-1', 'd-2']);
    expect(vm.state.data?.pagination.pageNumber, 2);
    expect(vm.state.isNextPageLoading, isFalse);
    await vm.close();
  });

  test('LoadNextReplacementCandidatesPage failure retains page 1 data and sets pageFailure', () async {
    final vm = createViewModel();
    repository.nextCandidatesResult = ApiSuccessResult(
      data: _buildCandidates(
        issueId: 'issue-200',
        page: 1,
        hasNextPage: true,
        candidates: [_buildCandidate('d-1', 'سائق 1')],
      ),
    );
    await vm.doIntent(const LoadReplacementCandidates());

    final failure = Failure(errorMessage: 'Page 2 failed');
    repository.nextCandidatesResult = ApiErrorResult(failure: failure);

    await vm.doIntent(const LoadNextReplacementCandidatesPage());

    expect(vm.state.isNextPageLoading, isFalse);
    expect(vm.state.pageFailure, failure);
    expect(vm.state.data?.candidates.length, 1); // Page 1 retained!
    await vm.close();
  });

  test('SelectReplacementDriver changes selectedDriverId', () async {
    final vm = createViewModel();
    repository.nextCandidatesResult = ApiSuccessResult(
      data: _buildCandidates(
        issueId: 'issue-200',
        candidates: [
          _buildCandidate('d-1', 'سائق 1'),
          _buildCandidate('d-2', 'سائق 2'),
        ],
      ),
    );
    await vm.doIntent(const LoadReplacementCandidates());
    expect(vm.state.selectedDriverId, 'd-1');

    await vm.doIntent(const SelectReplacementDriver('d-2'));
    expect(vm.state.selectedDriverId, 'd-2');
    await vm.close();
  });

  test('SubmitReplacementDriver successfully reassigns and sets successResult', () async {
    final vm = createViewModel();
    repository.nextCandidatesResult = ApiSuccessResult(
      data: _buildCandidates(
        issueId: 'issue-200',
        candidates: [_buildCandidate('d-1', 'سائق 1')],
      ),
    );
    await vm.doIntent(const LoadReplacementCandidates());

    const resultEntity = ReassignmentResultEntity(
      issueId: 'issue-200',
      status: DispatcherIssueStatus.resolved,
      reassignedDriver: DispatcherIssueDriverEntity(id: 'd-1', name: 'سائق 1', code: 'DRV-1'),
    );
    repository.nextReassignResult = const ApiSuccessResult(data: resultEntity);

    await vm.doIntent(const SubmitReplacementDriver());

    expect(repository.reassignCallCount, 1);
    expect(repository.lastReassignedDriverId, 'd-1');
    expect(vm.state.isSubmitting, isFalse);
    expect(vm.state.successResult, resultEntity);
    await vm.close();
  });

  test('SubmitReplacementDriver prevents double-submit while in progress', () async {
    final vm = createViewModel();
    repository.nextCandidatesResult = ApiSuccessResult(
      data: _buildCandidates(
        issueId: 'issue-200',
        candidates: [_buildCandidate('d-1', 'سائق 1')],
      ),
    );
    await vm.doIntent(const LoadReplacementCandidates());

    // Submit once
    final future1 = vm.doIntent(const SubmitReplacementDriver());
    // Immediately attempt second submit
    final future2 = vm.doIntent(const SubmitReplacementDriver());

    await Future.wait([future1, future2]);

    expect(repository.reassignCallCount, 1); // Only 1 network call occurred!
    await vm.close();
  });

  test('SubmitReplacementDriver on 409 REPLACEMENT_DRIVER_NO_LONGER_AVAILABLE clears selected id, shows failure, refreshes, and selects new first candidate', () async {
    final vm = createViewModel();
    repository.nextCandidatesResult = ApiSuccessResult(
      data: _buildCandidates(
        issueId: 'issue-200',
        candidates: [
          _buildCandidate('d-1', 'سائق غير متاح'),
          _buildCandidate('d-2', 'سائق بديل متاح'),
        ],
      ),
    );
    await vm.doIntent(const LoadReplacementCandidates());
    expect(vm.state.selectedDriverId, 'd-1');

    final driverConflict = ServerFailure(
      errorMessage: 'Replacement driver no longer available',
      code: 'REPLACEMENT_DRIVER_NO_LONGER_AVAILABLE',
      exception: const ApiException(
        errorType: ApiErrorType.unknown,
        message: 'Replacement driver no longer available',
        backendErrorCode: 'REPLACEMENT_DRIVER_NO_LONGER_AVAILABLE',
      ),
    );
    repository.nextReassignResult = ApiErrorResult(failure: driverConflict);

    // When refreshed, d-1 is gone, only d-2 is returned
    repository.nextCandidatesResult = ApiSuccessResult(
      data: _buildCandidates(
        issueId: 'issue-200',
        candidates: [_buildCandidate('d-2', 'سائق بديل متاح')],
      ),
    );

    await vm.doIntent(const SubmitReplacementDriver());

    expect(vm.state.isSubmitting, isFalse);
    expect(vm.state.submitFailure, driverConflict);
    expect(repository.getCandidatesCallCount, 2); // 1 initial + 1 conflict refresh
    expect(vm.state.data?.candidates.first.id, 'd-2');
    expect(vm.state.selectedDriverId, 'd-2'); // Auto-selected new first candidate!
    expect(vm.state.terminalIssueConflict, isFalse);
    await vm.close();
  });

  test('SubmitReplacementDriver on 409 ISSUE_ALREADY_RESOLVED_OR_REASSIGNED exposes terminal conflict', () async {
    final vm = createViewModel();
    repository.nextCandidatesResult = ApiSuccessResult(
      data: _buildCandidates(
        issueId: 'issue-200',
        candidates: [_buildCandidate('d-1', 'سائق 1')],
      ),
    );
    await vm.doIntent(const LoadReplacementCandidates());

    final terminalConflict = ServerFailure(
      errorMessage: 'Issue already resolved or reassigned',
      code: 'ISSUE_ALREADY_RESOLVED_OR_REASSIGNED',
      exception: const ApiException(
        errorType: ApiErrorType.unknown,
        message: 'Issue already resolved or reassigned',
        backendErrorCode: 'ISSUE_ALREADY_RESOLVED_OR_REASSIGNED',
      ),
    );
    repository.nextReassignResult = ApiErrorResult(failure: terminalConflict);

    await vm.doIntent(const SubmitReplacementDriver());

    expect(vm.state.isSubmitting, isFalse);
    expect(vm.state.terminalIssueConflict, isTrue);
    expect(vm.state.submitFailure, terminalConflict);
    expect(vm.state.canSubmit, isFalse); // Cannot submit after terminal conflict!
    await vm.close();
  });

  test('SubmitReplacementDriver on general failure keeps selected driver and exposes submitFailure', () async {
    final vm = createViewModel();
    repository.nextCandidatesResult = ApiSuccessResult(
      data: _buildCandidates(
        issueId: 'issue-200',
        candidates: [_buildCandidate('d-1', 'سائق 1')],
      ),
    );
    await vm.doIntent(const LoadReplacementCandidates());

    final generalFailure = Failure(errorMessage: 'Network error', code: 'INTERNAL_ERROR');
    repository.nextReassignResult = ApiErrorResult(failure: generalFailure);

    await vm.doIntent(const SubmitReplacementDriver());

    expect(vm.state.isSubmitting, isFalse);
    expect(vm.state.selectedDriverId, 'd-1'); // Retained
    expect(vm.state.submitFailure, generalFailure);
    expect(vm.state.terminalIssueConflict, isFalse);
    expect(vm.state.canSubmit, isTrue); // Can retry!
    await vm.close();
  });

  test('ClearReassignmentFailure clears submitFailure and pageFailure', () async {
    final vm = createViewModel();
    repository.nextCandidatesResult = ApiSuccessResult(
      data: _buildCandidates(
        issueId: 'issue-200',
        candidates: [_buildCandidate('d-1', 'سائق 1')],
      ),
    );
    await vm.doIntent(const LoadReplacementCandidates());

    repository.nextReassignResult = ApiErrorResult(failure: Failure(errorMessage: 'Error'));
    await vm.doIntent(const SubmitReplacementDriver());
    expect(vm.state.submitFailure, isNotNull);

    await vm.doIntent(const ClearReassignmentFailure());
    expect(vm.state.submitFailure, isNull);
    await vm.close();
  });
}
