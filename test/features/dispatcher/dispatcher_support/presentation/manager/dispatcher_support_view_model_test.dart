import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_date_preset.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_issue_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_kpi_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_response_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/repo/dispatcher_support_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/usecase/get_dispatcher_support_issues_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/manager/dispatcher_support_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/presentation/manager/dispatcher_support_view_model.dart';

void main() {
  late _MockSupportRepository repository;
  late GetDispatcherSupportIssuesUseCase useCase;

  setUp(() {
    repository = _MockSupportRepository();
    useCase = GetDispatcherSupportIssuesUseCase(repository);
  });

  DispatcherSupportViewModel createViewModel({
    Duration debounceDuration = Duration.zero,
  }) {
    return DispatcherSupportViewModel(
      getIssuesUseCase: useCase,
      searchDebounceDuration: debounceDuration,
    );
  }

  test('initial state has default query with status open and page 1', () {
    final vm = createViewModel();
    expect(vm.state.query.status, DispatcherSupportStatus.open);
    expect(vm.state.query.pageNumber, 1);
    expect(vm.state.query.pageSize, 20);
    expect(vm.state.response, isNull);
    expect(vm.state.isInitialLoading, isFalse);
    vm.close();
  });

  test(
    'LoadDispatcherSupportEvent fetches initial data and emits success state',
    () async {
      final vm = createViewModel();
      repository.nextResult = ApiSuccessResult(
        data: _makeResponse(issues: [_makeIssue('1')], hasNextPage: true),
      );

      await vm.doIntent(const LoadDispatcherSupportEvent());

      expect(vm.state.isInitialLoading, isFalse);
      expect(vm.state.hasLoadedOnce, isTrue);
      expect(vm.state.response?.issues.length, 1);
      expect(vm.state.initialFailure, isNull);
      vm.close();
    },
  );

  test('LoadDispatcherSupportEvent emits initialFailure on error', () async {
    final vm = createViewModel();
    repository.nextResult = ApiErrorResult(
      failure: Failure(errorMessage: 'Server error'),
    );

    await vm.doIntent(const LoadDispatcherSupportEvent());

    expect(vm.state.isInitialLoading, isFalse);
    expect(vm.state.initialFailure, isNotNull);
    expect(vm.state.response, isNull);
    vm.close();
  });

  test('status change resets to page 1 and fetches replacement', () async {
    final vm = createViewModel();
    repository.nextResult = ApiSuccessResult(
      data: _makeResponse(issues: [_makeIssue('1')]),
    );
    await vm.doIntent(const LoadDispatcherSupportEvent());

    repository.nextResult = ApiSuccessResult(
      data: _makeResponse(issues: [_makeIssue('2')]),
    );

    await vm.doIntent(
      const ChangeDispatcherSupportStatusEvent(
        DispatcherSupportStatus.inProgress,
      ),
    );

    expect(vm.state.query.status, DispatcherSupportStatus.inProgress);
    expect(vm.state.query.pageNumber, 1);
    expect(vm.state.response?.issues.first.id, '2');
    vm.close();
  });

  test('area change resets to page 1 and fetches replacement', () async {
    final vm = createViewModel();
    repository.nextResult = ApiSuccessResult(data: _makeResponse());
    await vm.doIntent(const LoadDispatcherSupportEvent());

    await vm.doIntent(const ChangeDispatcherSupportAreaEvent('Downtown'));

    expect(vm.state.query.area, 'Downtown');
    expect(vm.state.query.pageNumber, 1);
    vm.close();
  });

  test('date preset and custom range change reset to page 1', () async {
    final vm = createViewModel();
    repository.nextResult = ApiSuccessResult(data: _makeResponse());
    await vm.doIntent(const LoadDispatcherSupportEvent());

    await vm.doIntent(
      const ChangeDispatcherSupportDatePresetEvent(
        DispatcherSupportDatePreset.today,
      ),
    );
    expect(vm.state.query.datePreset, DispatcherSupportDatePreset.today);
    expect(vm.state.query.pageNumber, 1);

    final fromDate = DateTime.utc(2026, 9, 10);
    final toDate = DateTime.utc(2026, 9, 20);
    await vm.doIntent(
      ChangeDispatcherSupportCustomDateRangeEvent(
        fromDateUtc: fromDate,
        toDateUtc: toDate,
      ),
    );
    expect(vm.state.query.datePreset, DispatcherSupportDatePreset.custom);
    expect(vm.state.query.fromDateUtc, fromDate);
    expect(vm.state.query.toDateUtc, toDate);
    expect(vm.state.query.pageNumber, 1);
    vm.close();
  });

  test('search change debounces, trims, and resets page 1', () async {
    final vm = createViewModel(
      debounceDuration: const Duration(milliseconds: 10),
    );
    repository.nextResult = ApiSuccessResult(data: _makeResponse());
    await vm.doIntent(const LoadDispatcherSupportEvent());

    await vm.doIntent(const ChangeDispatcherSupportSearchEvent('  box-10  '));
    expect(vm.state.query.search, '  box-10  ');

    // Wait for debounce to fire
    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(repository.lastQuery?.search, 'box-10');
    expect(vm.state.query.pageNumber, 1);
    vm.close();
  });

  test('clear search cancels debounce and reloads immediately', () async {
    final vm = createViewModel(
      debounceDuration: const Duration(milliseconds: 500),
    );
    repository.nextResult = ApiSuccessResult(data: _makeResponse());
    await vm.doIntent(const LoadDispatcherSupportEvent());

    // Trigger debounced search
    await vm.doIntent(const ChangeDispatcherSupportSearchEvent('abc'));

    // Immediately clear
    await vm.doIntent(const ClearDispatcherSupportSearchEvent());

    expect(vm.state.query.search, '');
    expect(repository.lastQuery?.search, '');
    vm.close();
  });

  test(
    'stale response rejection ignores earlier request that resolves later',
    () async {
      final vm = createViewModel();
      final completer1 =
          Completer<ApiResult<DispatcherSupportResponseEntity>>();
      final completer2 =
          Completer<ApiResult<DispatcherSupportResponseEntity>>();

      // Request 1
      repository.resultProvider = (_) => completer1.future;
      vm.doIntent(const LoadDispatcherSupportEvent());

      // Request 2 (e.g. status filter)
      repository.resultProvider = (_) => completer2.future;
      vm.doIntent(
        const ChangeDispatcherSupportStatusEvent(
          DispatcherSupportStatus.inProgress,
        ),
      );

      // Request 2 finishes FIRST
      completer2.complete(
        ApiSuccessResult(
          data: _makeResponse(issues: [_makeIssue('from-request-2')]),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(vm.state.response?.issues.first.id, 'from-request-2');

      // Request 1 finishes LATER (stale)
      completer1.complete(
        ApiSuccessResult(
          data: _makeResponse(issues: [_makeIssue('stale-request-1')]),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      // Stale result should NOT overwrite request 2
      expect(vm.state.response?.issues.first.id, 'from-request-2');
      vm.close();
    },
  );

  test(
    'infinite scroll loads next page, merges, and deduplicates by ID',
    () async {
      final vm = createViewModel();
      repository.nextResult = ApiSuccessResult(
        data: _makeResponse(
          issues: [_makeIssue('1'), _makeIssue('2')],
          pageNumber: 1,
          hasNextPage: true,
        ),
      );
      await vm.doIntent(const LoadDispatcherSupportEvent());

      repository.nextResult = ApiSuccessResult(
        data: _makeResponse(
          // '2' is duplicate, '3' is new
          issues: [_makeIssue('2'), _makeIssue('3')],
          pageNumber: 2,
          hasNextPage: false,
        ),
      );

      await vm.doIntent(const LoadNextDispatcherSupportPageEvent());

      expect(vm.state.query.pageNumber, 2);
      expect(vm.state.response?.issues.length, 3);
      expect(vm.state.response?.issues.map((i) => i.id).toList(), [
        '1',
        '2',
        '3',
      ]);
      expect(vm.state.isNextPageLoading, isFalse);
      vm.close();
    },
  );

  test('page failure retains existing data and sets pageFailure', () async {
    final vm = createViewModel();
    repository.nextResult = ApiSuccessResult(
      data: _makeResponse(issues: [_makeIssue('1')], hasNextPage: true),
    );
    await vm.doIntent(const LoadDispatcherSupportEvent());

    repository.nextResult = ApiErrorResult(
      failure: Failure(errorMessage: 'Next page network error'),
    );

    await vm.doIntent(const LoadNextDispatcherSupportPageEvent());

    expect(vm.state.response?.issues.length, 1);
    expect(vm.state.pageFailure, isNotNull);
    expect(vm.state.isNextPageLoading, isFalse);
    vm.close();
  });

  test(
    'filter failure retains existing data, sets nonFatalFailure, and increments noticeId',
    () async {
      final vm = createViewModel();
      repository.nextResult = ApiSuccessResult(
        data: _makeResponse(issues: [_makeIssue('1')]),
      );
      await vm.doIntent(const LoadDispatcherSupportEvent());
      final initialNoticeId = vm.state.noticeId;

      repository.nextResult = ApiErrorResult(
        failure: Failure(errorMessage: 'Filter network failure'),
      );

      await vm.doIntent(const ChangeDispatcherSupportAreaEvent('New Area'));

      expect(vm.state.response?.issues.length, 1);
      expect(vm.state.nonFatalFailure, isNotNull);
      expect(vm.state.noticeId, initialNoticeId + 1);
      expect(vm.state.isFilterLoading, isFalse);
      vm.close();
    },
  );
}

class _MockSupportRepository implements DispatcherSupportRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  ApiResult<DispatcherSupportResponseEntity>? nextResult;
  Future<ApiResult<DispatcherSupportResponseEntity>> Function(
    DispatcherSupportQueryEntity,
  )?
  resultProvider;
  DispatcherSupportQueryEntity? lastQuery;

  @override
  Future<ApiResult<DispatcherSupportResponseEntity>> getIssues(
    DispatcherSupportQueryEntity query,
  ) async {
    lastQuery = query;
    if (resultProvider != null) {
      return resultProvider!(query);
    }
    return nextResult!;
  }
}

DispatcherSupportResponseEntity _makeResponse({
  List<DispatcherSupportIssueEntity> issues = const [],
  int pageNumber = 1,
  bool hasNextPage = false,
}) {
  return DispatcherSupportResponseEntity(
    counters: const DispatcherSupportKpiEntity(openCount: 5),
    areaChips: const [],
    issues: issues,
    pagination: DispatcherSupportPaginationEntity(
      pageNumber: pageNumber,
      pageSize: 20,
      totalCount: issues.length,
      totalPages: hasNextPage ? pageNumber + 1 : pageNumber,
      hasNextPage: hasNextPage,
      hasPreviousPage: pageNumber > 1,
    ),
  );
}

DispatcherSupportIssueEntity _makeIssue(String id) {
  return DispatcherSupportIssueEntity(
    id: id,
    boxCode: 'BX-$id',
    driverName: 'Driver $id',
    area: 'Area $id',
  );
}
