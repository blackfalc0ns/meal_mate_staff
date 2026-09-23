import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/data/data_source/assign_box_remote_data_source.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/data/models/response/assign_box_details_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/data/models/response/assign_box_summary_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/data/repo/assign_box_repository_impl.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_details_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_assign_box/domain/entities/assign_box_summary_entity.dart';

class FakeAssignBoxRemoteDataSource implements AssignBoxRemoteDataSource {
  AssignBoxDetailsResponseDto? detailsResponse;
  AssignBoxSummaryResponseDto? summaryResponse;
  Exception? exceptionToThrow;

  @override
  Future<AssignBoxDetailsResponseDto> getDetails(String boxId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return detailsResponse ?? const AssignBoxDetailsResponseDto();
  }

  @override
  Future<AssignBoxSummaryResponseDto> getSummary(String boxId) async {
    if (exceptionToThrow != null) throw exceptionToThrow!;
    return summaryResponse ?? const AssignBoxSummaryResponseDto();
  }
}

void main() {
  late FakeAssignBoxRemoteDataSource fakeDataSource;
  late AssignBoxRepositoryImpl repository;

  setUp(() {
    fakeDataSource = FakeAssignBoxRemoteDataSource();
    repository = AssignBoxRepositoryImpl(fakeDataSource);
  });

  group('AssignBoxRepositoryImpl - getDetails', () {
    const boxId = 'a1111111-1111-1111-1111-111111111111';

    test('returns ApiSuccessResult when remote data source succeeds', () async {
      fakeDataSource.detailsResponse = const AssignBoxDetailsResponseDto(
        box: AssignBoxOrderDto(boxId: boxId, boxCode: '#BX-1256'),
      );

      final result = await repository.getDetails(boxId);

      expect(result, isA<ApiSuccessResult<AssignBoxDetailsEntity>>());
      final data = (result as ApiSuccessResult<AssignBoxDetailsEntity>).data;
      expect(data.box.boxId, boxId);
      expect(data.box.boxCode, '#BX-1256');
    });

    test(
      'returns ApiErrorResult when remote data source throws DioException',
      () async {
        fakeDataSource.exceptionToThrow = DioException(
          requestOptions: RequestOptions(path: '/details'),
          response: Response(
            requestOptions: RequestOptions(path: '/details'),
            statusCode: 404,
            data: {'message': 'Box not found'},
          ),
          type: DioExceptionType.badResponse,
        );

        final result = await repository.getDetails(boxId);

        expect(result, isA<ApiErrorResult<AssignBoxDetailsEntity>>());
        final failure =
            (result as ApiErrorResult<AssignBoxDetailsEntity>).failure;
        expect(failure, isA<ServerFailure>());
      },
    );
  });

  group('AssignBoxRepositoryImpl - getSummary', () {
    const boxId = 'a1111111-1111-1111-1111-111111111111';

    test('returns ApiSuccessResult when remote data source succeeds', () async {
      fakeDataSource.summaryResponse = const AssignBoxSummaryResponseDto(
        boxId: boxId,
        boxCode: '#BX-1256',
        customerNameMasked: 'محمد ***',
      );

      final result = await repository.getSummary(boxId);

      expect(result, isA<ApiSuccessResult<AssignBoxSummaryEntity>>());
      final data = (result as ApiSuccessResult<AssignBoxSummaryEntity>).data;
      expect(data.boxId, boxId);
      expect(data.customerNameMasked, 'محمد ***');
    });

    test(
      'returns ApiErrorResult with Failure when remote data source throws generic exception',
      () async {
        fakeDataSource.exceptionToThrow = Exception('Network error');

        final result = await repository.getSummary(boxId);

        expect(result, isA<ApiErrorResult<AssignBoxSummaryEntity>>());
      },
    );
  });
}
