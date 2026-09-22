import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/data_source/dispatcher_support_remote_data_source.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/models/response/dispatcher_support_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/repo/dispatcher_support_repository_impl.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_date_preset.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_support_status.dart';

void main() {
  test(
    'forwards all 8 query parameters and maps to entity on success',
    () async {
      final recordingSource = _RecordingRemoteDataSource();
      final repository = DispatcherSupportRepositoryImpl(recordingSource);

      final fromDate = DateTime.utc(2026, 9, 1);
      final toDate = DateTime.utc(2026, 9, 20);

      final query = DispatcherSupportQueryEntity(
        area: 'Al Malqa',
        status: DispatcherSupportStatus.inProgress,
        search: 'box-99',
        datePreset: DispatcherSupportDatePreset.custom,
        fromDateUtc: fromDate,
        toDateUtc: toDate,
        pageNumber: 2,
        pageSize: 30,
      );

      final result = await repository.getIssues(query);

      expect(recordingSource.lastQuery, equals(query));
      expect(result, isA<ApiSuccessResult>());
      final data = (result as ApiSuccessResult).data;
      expect(data.counters.openCount, 4);
      expect(data.issues.length, 1);
      expect(data.issues.first.id, 'iss-100');
    },
  );

  test('converts exceptions into ApiErrorResult via safeApiCall', () async {
    final failingSource = _FailingRemoteDataSource();
    final repository = DispatcherSupportRepositoryImpl(failingSource);

    final result = await repository.getIssues(
      const DispatcherSupportQueryEntity(),
    );

    expect(result, isA<ApiErrorResult>());
  });
}

class _RecordingRemoteDataSource implements DispatcherSupportRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  DispatcherSupportQueryEntity? lastQuery;

  @override
  Future<DispatcherSupportResponseDto> getIssues(
    DispatcherSupportQueryEntity query,
  ) async {
    lastQuery = query;
    return DispatcherSupportResponseDto.fromJson(const {
      'counters': {'openCount': 4},
      'issues': [
        {
          'id': 'iss-100',
          'boxCode': 'BX-100',
          'driverName': 'Ali',
          'area': 'North',
        },
      ],
      'pagination': {'pageNumber': 2, 'pageSize': 30, 'totalCount': 40},
    });
  }
}

class _FailingRemoteDataSource implements DispatcherSupportRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<DispatcherSupportResponseDto> getIssues(
    DispatcherSupportQueryEntity query,
  ) {
    throw DioException(
      requestOptions: RequestOptions(path: '/api/v1/dispatcher/support/issues'),
      type: DioExceptionType.badResponse,
    );
  }
}
