import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/data/data_source/operations_log_remote_data_source.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/data/models/response/operations_log_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/data/repo/operations_log_repository_impl.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/entities/operations_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_operations/domain/repo/operations_log_repository.dart';

class MockOperationsLogRemoteDataSource
    implements OperationsLogRemoteDataSource {
  OperationsLogResponseDto? responseToReturn;
  Exception? exceptionToThrow;
  OperationsQueryEntity? capturedQuery;

  @override
  Future<OperationsLogResponseDto> getOperations(
    OperationsQueryEntity query,
  ) async {
    capturedQuery = query;
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return responseToReturn ?? const OperationsLogResponseDto();
  }
}

void main() {
  late MockOperationsLogRemoteDataSource remoteDataSource;
  late OperationsLogRepository repository;

  setUp(() {
    remoteDataSource = MockOperationsLogRemoteDataSource();
    repository = OperationsLogRepositoryImpl(remoteDataSource);
  });

  group('OperationsLogRepository', () {
    test('forwards query and returns ApiSuccessResult on success', () async {
      remoteDataSource.responseToReturn = const OperationsLogResponseDto(
        counters: OperationsCountersResponseDto(allCount: 50),
        operations: [],
        pagination: OperationsPaginationResponseDto(totalItems: 50),
      );

      const query = OperationsQueryEntity(search: '10256', pageNumber: 2);
      final result = await repository.getOperations(query);

      expect(remoteDataSource.capturedQuery, query);
      expect(result, isA<ApiSuccessResult>());
      final success = result as ApiSuccessResult;
      expect(success.data.counters.allCount, 50);
      expect(success.data.pagination.totalItems, 50);
    });

    test(
      'returns ApiErrorResult when remoteDataSource throws DioException',
      () async {
        remoteDataSource.exceptionToThrow = DioException(
          requestOptions: RequestOptions(
            path: '/api/v1/dispatcher/operations/log',
          ),
          type: DioExceptionType.connectionTimeout,
        );

        const query = OperationsQueryEntity();
        final result = await repository.getOperations(query);

        expect(result, isA<ApiErrorResult>());
        final error = result as ApiErrorResult;
        expect(error.failure, isNotNull);
      },
    );
  });
}
