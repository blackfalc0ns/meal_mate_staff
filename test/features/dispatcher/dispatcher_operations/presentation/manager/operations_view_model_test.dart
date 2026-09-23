import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operation_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_counters_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_date_preset.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_page_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_pagination_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/repo/operations_log_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/usecase/get_operations_log_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/manager/operations_event.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/presentation/manager/operations_view_model.dart';

class FakeOperationsRepository implements OperationsLogRepository {
  ApiResult<OperationsPageEntity> result = const ApiSuccessResult(
    data: OperationsPageEntity(
      counters: OperationsCountersEntity(allCount: 100),
      operations: [],
      pagination: OperationsPaginationEntity(
        pageNumber: 1,
        pageSize: 10,
        totalItems: 100,
        totalPages: 10,
        hasPreviousPage: false,
        hasNextPage: true,
      ),
    ),
  );
  int callCount = 0;
  OperationsQueryEntity? lastQuery;
  Duration delay = Duration.zero;

  @override
  Future<ApiResult<OperationsPageEntity>> getOperations(
    OperationsQueryEntity query,
  ) async {
    callCount++;
    lastQuery = query;
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }
    return result;
  }
}

void main() {
  late FakeOperationsRepository repository;
  late GetOperationsLogUseCase useCase;
  late OperationsViewModel viewModel;

  setUp(() {
    repository = FakeOperationsRepository();
    useCase = GetOperationsLogUseCase(repository);
    viewModel = OperationsViewModel(
      getOperationsLogUseCase: useCase,
      searchDebounceDuration: const Duration(milliseconds: 400),
    );
  });

  tearDown(() async {
    await viewModel.close();
  });

  group('OperationsViewModel', () {
    test('initial load triggers request and populates state', () async {
      expect(viewModel.state.isInitialLoading, isFalse);
      expect(viewModel.state.hasLoadedOnce, isFalse);

      await viewModel.doIntent(const LoadOperationsEvent());

      expect(viewModel.state.isInitialLoading, isFalse);
      expect(viewModel.state.hasLoadedOnce, isTrue);
      expect(viewModel.state.counters.allCount, 100);
      expect(viewModel.state.canGoNext, isTrue);
      expect(viewModel.state.canGoPrevious, isFalse);
      expect(repository.callCount, 1);
    });

    test('initial failure sets initialFailure and no response', () async {
      repository.result = ApiErrorResult(
        failure: Failure(errorMessage: 'Network error'),
      );

      await viewModel.doIntent(const LoadOperationsEvent());

      expect(viewModel.state.isInitialLoading, isFalse);
      expect(viewModel.state.initialFailure, isNotNull);
      expect(viewModel.state.response, isNull);
      expect(viewModel.state.nonFatalFailure, isNull);
    });

    test(
      'status change resets page to 1 and performs replacement load',
      () async {
        await viewModel.doIntent(const LoadOperationsEvent());
        expect(repository.callCount, 1);

        await viewModel.doIntent(
          const ChangeOperationsStatusEvent(OperationStatus.failed),
        );

        expect(repository.callCount, 2);
        expect(repository.lastQuery?.status, OperationStatus.failed);
        expect(repository.lastQuery?.pageNumber, 1);
        expect(viewModel.state.query.status, OperationStatus.failed);
      },
    );

    test('date preset change resets page to 1', () async {
      await viewModel.doIntent(const LoadOperationsEvent());

      await viewModel.doIntent(
        const ChangeOperationsDatePresetEvent(OperationsDatePreset.today),
      );

      expect(repository.lastQuery?.datePreset, OperationsDatePreset.today);
      expect(repository.lastQuery?.pageNumber, 1);
    });

    test('custom date range change resets page to 1 with UTC bounds', () async {
      await viewModel.doIntent(const LoadOperationsEvent());

      final from = DateTime.utc(2026, 9, 20);
      final to = DateTime.utc(2026, 9, 23);

      await viewModel.doIntent(
        ChangeOperationsCustomDateRangeEvent(fromDateUtc: from, toDateUtc: to),
      );

      expect(repository.lastQuery?.datePreset, OperationsDatePreset.custom);
      expect(repository.lastQuery?.fromDateUtc, from);
      expect(repository.lastQuery?.toDateUtc, to);
      expect(repository.lastQuery?.pageNumber, 1);
    });

    test('search debounces by configured duration and trims query', () async {
      final shortDebounceVm = OperationsViewModel(
        getOperationsLogUseCase: useCase,
        searchDebounceDuration: const Duration(milliseconds: 20),
      );
      unawaited(
        shortDebounceVm.doIntent(
          const ChangeOperationsSearchEvent('  BX-10256  '),
        ),
      );
      expect(shortDebounceVm.state.query.search, '  BX-10256  ');

      await Future<void>.delayed(const Duration(milliseconds: 5));
      expect(repository.callCount, 0);

      await Future<void>.delayed(const Duration(milliseconds: 35));
      expect(repository.callCount, 1);
      expect(repository.lastQuery?.search, 'BX-10256');
      expect(repository.lastQuery?.pageNumber, 1);

      await shortDebounceVm.close();
    });

    test(
      'pagination moves forward and backward respecting backend bounds',
      () async {
        await viewModel.doIntent(const LoadOperationsEvent());
        expect(viewModel.state.canGoNext, isTrue);
        expect(viewModel.state.canGoPrevious, isFalse);

        // Cannot go previous
        await viewModel.doIntent(const GoToPreviousOperationsPageEvent());
        expect(repository.callCount, 1);

        // Setup page 2 response
        repository.result = const ApiSuccessResult(
          data: OperationsPageEntity(
            counters: OperationsCountersEntity(allCount: 100),
            operations: [],
            pagination: OperationsPaginationEntity(
              pageNumber: 2,
              pageSize: 10,
              totalItems: 100,
              totalPages: 10,
              hasPreviousPage: true,
              hasNextPage: true,
            ),
          ),
        );

        // Go next
        await viewModel.doIntent(const GoToNextOperationsPageEvent());
        expect(repository.callCount, 2);
        expect(repository.lastQuery?.pageNumber, 2);
        expect(viewModel.state.canGoPrevious, isTrue);

        // Go previous
        await viewModel.doIntent(const GoToPreviousOperationsPageEvent());
        expect(repository.callCount, 3);
        expect(repository.lastQuery?.pageNumber, 1);
      },
    );

    test(
      'nonfatal replacement failure preserves existing response and updates noticeId',
      () async {
        await viewModel.doIntent(const LoadOperationsEvent());
        expect(viewModel.state.response, isNotNull);

        repository.result = ApiErrorResult(
          failure: Failure(errorMessage: 'Replacement failed'),
        );

        await viewModel.doIntent(
          const ChangeOperationsStatusEvent(OperationStatus.cancelled),
        );

        // Previous response is kept!
        expect(viewModel.state.response, isNotNull);
        expect(viewModel.state.isReplacementLoading, isFalse);
        expect(
          viewModel.state.nonFatalFailure?.errorMessage,
          'Replacement failed',
        );
        expect(viewModel.state.noticeId, 1);
      },
    );
  });
}
