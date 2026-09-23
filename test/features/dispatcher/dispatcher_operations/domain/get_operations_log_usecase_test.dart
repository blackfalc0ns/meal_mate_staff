import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_counters_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_date_preset.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_page_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_pagination_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/repo/operations_log_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/usecase/get_operations_log_usecase.dart';

class MockOperationsLogRepository implements OperationsLogRepository {
  int calls = 0;
  OperationsQueryEntity? capturedQuery;
  ApiResult<OperationsPageEntity>? resultToReturn;

  @override
  Future<ApiResult<OperationsPageEntity>> getOperations(
    OperationsQueryEntity query,
  ) async {
    calls++;
    capturedQuery = query;
    return resultToReturn ??
        const ApiSuccessResult(
          data: OperationsPageEntity(
            counters: OperationsCountersEntity(),
            operations: [],
            pagination: OperationsPaginationEntity(),
          ),
        );
  }
}

void main() {
  late MockOperationsLogRepository repository;
  late GetOperationsLogUseCase useCase;

  setUp(() {
    repository = MockOperationsLogRepository();
    useCase = GetOperationsLogUseCase(repository);
  });

  group('GetOperationsLogUseCase', () {
    test(
      'locally rejects invalid custom date range without calling repository',
      () async {
        const invalidQuery = OperationsQueryEntity(
          datePreset: OperationsDatePreset.custom,
        );

        final result = await useCase(invalidQuery);

        expect(result, isA<ApiErrorResult<OperationsPageEntity>>());
        expect(repository.calls, 0);
      },
    );

    test(
      'locally rejects invalid pageNumber or pageSize without calling repository',
      () async {
        const invalidPage = OperationsQueryEntity(pageNumber: 0);
        final pageResult = await useCase(invalidPage);
        expect(pageResult, isA<ApiErrorResult<OperationsPageEntity>>());
        expect(repository.calls, 0);

        const invalidSize = OperationsQueryEntity(pageSize: 51);
        final sizeResult = await useCase(invalidSize);
        expect(sizeResult, isA<ApiErrorResult<OperationsPageEntity>>());
        expect(repository.calls, 0);
      },
    );

    test('forwards valid query to repository', () async {
      const validQuery = OperationsQueryEntity(
        datePreset: OperationsDatePreset.last7Days,
        pageNumber: 1,
        pageSize: 10,
      );

      final result = await useCase(validQuery);

      expect(result, isA<ApiSuccessResult<OperationsPageEntity>>());
      expect(repository.calls, 1);
      expect(repository.capturedQuery, validQuery);
    });
  });
}
