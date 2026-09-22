import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_detail_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_driver_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_resolution_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassignment_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/resolve_issue_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/usecase/get_dispatcher_issue_details_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/usecase/resolve_dispatcher_issue_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/repo/dispatcher_support_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/manager/issue_details/dispatcher_issue_details_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/manager/issue_details/dispatcher_issue_details_view_model.dart';

class _MockSupportRepo implements DispatcherSupportRepository {
  ApiResult<DispatcherIssueDetailEntity>? nextDetailsResult;
  ApiResult<ResolveIssueResultEntity>? nextResolveResult;
  int getDetailsCallCount = 0;
  int resolveCallCount = 0;
  String? lastResolvedNotes;
  Completer<ApiResult<DispatcherIssueDetailEntity>>? pendingDetailsCompleter;

  @override
  Future<ApiResult<DispatcherIssueDetailEntity>> getIssueDetails(String issueId) async {
    getDetailsCallCount++;
    if (pendingDetailsCompleter != null) {
      return pendingDetailsCompleter!.future;
    }
    return nextDetailsResult ??
        ApiSuccessResult(data: _buildDetail(issueId: issueId, status: DispatcherIssueStatus.open));
  }

  @override
  Future<ApiResult<ResolveIssueResultEntity>> resolveIssue(
    String issueId,
    String resolutionNotes,
  ) async {
    resolveCallCount++;
    lastResolvedNotes = resolutionNotes;
    return nextResolveResult ??
        ApiSuccessResult(
          data: ResolveIssueResultEntity(
            issueId: issueId,
            status: DispatcherIssueStatus.resolved,
            resolution: DispatcherIssueResolutionEntity(
              resolutionNotes: resolutionNotes,
              resolvedAtUtc: DateTime.utc(2026, 9, 22, 12, 0),
            ),
          ),
        );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DispatcherIssueDetailEntity _buildDetail({
  required String issueId,
  DispatcherIssueStatus status = DispatcherIssueStatus.open,
  DispatcherIssueResolutionEntity? resolution,
  DispatcherIssueDriverEntity? driver,
}) {
  return DispatcherIssueDetailEntity(
    issueId: issueId,
    title: 'تأخير في التوصيل',
    boxCode: 'BOX-101',
    area: 'الرياض - الملز',
    status: status,
    resolution: resolution,
    driver: driver ??
        const DispatcherIssueDriverEntity(
          id: 'driver-1',
          name: 'محمد أحمد',
          code: 'DRV-001',
        ),
  );
}

void main() {
  late _MockSupportRepo repository;
  late GetDispatcherIssueDetailsUseCase getDetailsUseCase;
  late ResolveDispatcherIssueUseCase resolveUseCase;

  setUp(() {
    repository = _MockSupportRepo();
    getDetailsUseCase = GetDispatcherIssueDetailsUseCase(repository);
    resolveUseCase = ResolveDispatcherIssueUseCase(repository);
  });

  DispatcherIssueDetailsViewModel createViewModel({String issueId = 'issue-100'}) {
    return DispatcherIssueDetailsViewModel(
      issueId: issueId,
      getDetailsUseCase: getDetailsUseCase,
      resolveUseCase: resolveUseCase,
    );
  }

  test('initial state is correct', () async {
    final vm = createViewModel();
    expect(vm.state.detail, isNull);
    expect(vm.state.isInitialLoading, isFalse);
    expect(vm.state.isResolving, isFalse);
    expect(vm.state.initialFailure, isNull);
    expect(vm.state.resolveFailure, isNull);
    expect(vm.state.resolutionNotesError, isNull);
    expect(vm.state.canMutate, isFalse);
    expect(vm.state.resolveSuccessId, 0);
    expect(vm.state.requiresRefresh, isFalse);
    await vm.close();
  });

  test('LoadIssueDetails loads detail and sets canMutate to true', () async {
    final vm = createViewModel();
    final expected = _buildDetail(issueId: 'issue-100');
    repository.nextDetailsResult = ApiSuccessResult(data: expected);

    await vm.doIntent(const LoadIssueDetails());

    expect(vm.state.isInitialLoading, isFalse);
    expect(vm.state.hasLoadedOnce, isTrue);
    expect(vm.state.detail?.issueId, 'issue-100');
    expect(vm.state.initialFailure, isNull);
    expect(vm.state.canMutate, isTrue);
    await vm.close();
  });

  test('LoadIssueDetails on failure emits initialFailure and keeps detail null', () async {
    final vm = createViewModel();
    final failure = Failure(errorMessage: 'Network error');
    repository.nextDetailsResult = ApiErrorResult(failure: failure);

    await vm.doIntent(const LoadIssueDetails());

    expect(vm.state.isInitialLoading, isFalse);
    expect(vm.state.detail, isNull);
    expect(vm.state.initialFailure, failure);
    expect(vm.state.canMutate, isFalse);
    await vm.close();
  });

  test('RetryIssueDetails re-fetches details after initial failure', () async {
    final vm = createViewModel();
    repository.nextDetailsResult = ApiErrorResult(failure: Failure(errorMessage: 'Net error'));
    await vm.doIntent(const LoadIssueDetails());
    expect(vm.state.initialFailure, isNotNull);

    repository.nextDetailsResult = ApiSuccessResult(data: _buildDetail(issueId: 'issue-100'));
    await vm.doIntent(const RetryIssueDetails());

    expect(vm.state.initialFailure, isNull);
    expect(vm.state.detail?.issueId, 'issue-100');
    await vm.close();
  });

  test('SubmitIssueResolution rejects notes shorter than 3 characters without calling usecase', () async {
    final vm = createViewModel();
    repository.nextDetailsResult = ApiSuccessResult(data: _buildDetail(issueId: 'issue-100'));
    await vm.doIntent(const LoadIssueDetails());

    await vm.doIntent(const SubmitIssueResolution('  ab '));

    expect(repository.resolveCallCount, 0);
    expect(vm.state.resolutionNotesError, isNotNull);
    expect(vm.state.isResolving, isFalse);
    await vm.close();
  });

  test('SubmitIssueResolution rejects notes longer than 500 characters without calling usecase', () async {
    final vm = createViewModel();
    repository.nextDetailsResult = ApiSuccessResult(data: _buildDetail(issueId: 'issue-100'));
    await vm.doIntent(const LoadIssueDetails());

    final longNote = 'A' * 501;
    await vm.doIntent(SubmitIssueResolution(longNote));

    expect(repository.resolveCallCount, 0);
    expect(vm.state.resolutionNotesError, isNotNull);
    expect(vm.state.isResolving, isFalse);
    await vm.close();
  });

  test('SubmitIssueResolution successfully resolves and updates detail locally', () async {
    final vm = createViewModel();
    final detail = _buildDetail(issueId: 'issue-100');
    repository.nextDetailsResult = ApiSuccessResult(data: detail);
    await vm.doIntent(const LoadIssueDetails());

    final resolution = DispatcherIssueResolutionEntity(
      resolutionNotes: 'تم حل المشكلة واستبدال السائق',
      resolvedAtUtc: DateTime.utc(2026, 9, 22, 14, 0),
    );
    repository.nextResolveResult = ApiSuccessResult(
      data: ResolveIssueResultEntity(
        issueId: 'issue-100',
        status: DispatcherIssueStatus.resolved,
        resolution: resolution,
      ),
    );

    await vm.doIntent(const SubmitIssueResolution('تم حل المشكلة واستبدال السائق'));

    expect(repository.resolveCallCount, 1);
    expect(repository.lastResolvedNotes, 'تم حل المشكلة واستبدال السائق');
    expect(vm.state.isResolving, isFalse);
    expect(vm.state.resolveSuccessId, 1);
    expect(vm.state.requiresRefresh, isTrue);
    expect(vm.state.detail?.isResolved, isTrue);
    expect(vm.state.detail?.resolution?.resolutionNotes, 'تم حل المشكلة واستبدال السائق');
    expect(vm.state.canMutate, isFalse);
    await vm.close();
  });

  test('SubmitIssueResolution on 409 ISSUE_ALREADY_RESOLVED refreshes details and shows resolution card', () async {
    final vm = createViewModel();
    final openDetail = _buildDetail(issueId: 'issue-100', status: DispatcherIssueStatus.open);
    repository.nextDetailsResult = ApiSuccessResult(data: openDetail);
    await vm.doIntent(const LoadIssueDetails());

    final conflictFailure = ServerFailure(
      errorMessage: 'Issue already resolved',
      code: 'ISSUE_ALREADY_RESOLVED',
      exception: const ApiException(
        errorType: ApiErrorType.unknown,
        message: 'Issue already resolved',
        backendErrorCode: 'ISSUE_ALREADY_RESOLVED',
      ),
    );
    repository.nextResolveResult = ApiErrorResult(failure: conflictFailure);

    // Setup refreshed detail from server
    final serverResolvedDetail = _buildDetail(
      issueId: 'issue-100',
      status: DispatcherIssueStatus.resolved,
      resolution: const DispatcherIssueResolutionEntity(
        resolutionNotes: 'تم الحل مسبقاً من قِبل مسؤول آخر',
      ),
    );
    repository.nextDetailsResult = ApiSuccessResult(data: serverResolvedDetail);

    await vm.doIntent(const SubmitIssueResolution('تم الحل الآن'));

    expect(repository.resolveCallCount, 1);
    expect(repository.getDetailsCallCount, 2); // 1 initial + 1 refresh
    expect(vm.state.detail?.isResolved, isTrue);
    expect(vm.state.detail?.resolution?.resolutionNotes, contains('مسؤول آخر'));
    expect(vm.state.requiresRefresh, isTrue);
    expect(vm.state.isResolving, isFalse);
    expect(vm.state.resolveFailure, isNull);
    await vm.close();
  });

  test('SubmitIssueResolution on non-conflict failure keeps detail and preserves resolveFailure', () async {
    final vm = createViewModel();
    final openDetail = _buildDetail(issueId: 'issue-100', status: DispatcherIssueStatus.open);
    repository.nextDetailsResult = ApiSuccessResult(data: openDetail);
    await vm.doIntent(const LoadIssueDetails());

    final generalFailure = Failure(errorMessage: 'Internal server error', code: 'INTERNAL_ERROR');
    repository.nextResolveResult = ApiErrorResult(failure: generalFailure);

    await vm.doIntent(const SubmitIssueResolution('حل المشكلة كذا'));

    expect(vm.state.isResolving, isFalse);
    expect(vm.state.detail, same(openDetail));
    expect(vm.state.resolveFailure, generalFailure);
    expect(vm.state.canMutate, isTrue);
    await vm.close();
  });

  test('ClearIssueResolutionFailure clears resolveFailure and notes error', () async {
    final vm = createViewModel();
    repository.nextDetailsResult = ApiSuccessResult(data: _buildDetail(issueId: 'issue-100'));
    await vm.doIntent(const LoadIssueDetails());

    await vm.doIntent(const SubmitIssueResolution('x')); // too short
    expect(vm.state.resolutionNotesError, isNotNull);

    await vm.doIntent(const ClearIssueResolutionFailure());
    expect(vm.state.resolutionNotesError, isNull);
    expect(vm.state.resolveFailure, isNull);
    await vm.close();
  });

  test('ApplyReassignmentResult updates driver and status without refetching', () async {
    final vm = createViewModel();
    final detail = _buildDetail(
      issueId: 'issue-100',
      status: DispatcherIssueStatus.open,
      driver: const DispatcherIssueDriverEntity(id: 'old-drv', name: 'القديم', code: 'DRV-OLD'),
    );
    repository.nextDetailsResult = ApiSuccessResult(data: detail);
    await vm.doIntent(const LoadIssueDetails());
    expect(repository.getDetailsCallCount, 1);

    const reassignmentResult = ReassignmentResultEntity(
      issueId: 'issue-100',
      status: DispatcherIssueStatus.resolved,
      reassignedDriver: DispatcherIssueDriverEntity(id: 'new-drv', name: 'الجديد', code: 'DRV-NEW'),
    );

    await vm.doIntent(const ApplyReassignmentResult(reassignmentResult));

    expect(repository.getDetailsCallCount, 1); // No new network request!
    expect(vm.state.detail?.driver?.id, 'new-drv');
    expect(vm.state.detail?.driver?.name, 'الجديد');
    expect(vm.state.detail?.status, DispatcherIssueStatus.resolved);
    expect(vm.state.requiresRefresh, isTrue);
    await vm.close();
  });

  test('stale request generation ignored after rapid retry', () async {
    final vm = createViewModel();
    final completer1 = Completer<ApiResult<DispatcherIssueDetailEntity>>();
    repository.pendingDetailsCompleter = completer1;

    // Start initial load
    unawaited(vm.doIntent(const LoadIssueDetails()));

    // Trigger retry before completer1 finishes
    final completer2 = Completer<ApiResult<DispatcherIssueDetailEntity>>();
    repository.pendingDetailsCompleter = completer2;
    unawaited(vm.doIntent(const RetryIssueDetails()));

    // Completer 2 finishes first
    completer2.complete(ApiSuccessResult(data: _buildDetail(issueId: 'new-response')));
    await pumpEventQueue();

    expect(vm.state.detail?.issueId, 'new-response');

    // Completer 1 finishes late
    completer1.complete(ApiSuccessResult(data: _buildDetail(issueId: 'stale-response')));
    await pumpEventQueue();

    // Still the new response, not overwritten by stale response!
    expect(vm.state.detail?.issueId, 'new-response');
    await vm.close();
  });
}
