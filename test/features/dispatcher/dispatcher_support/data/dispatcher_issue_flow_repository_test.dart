import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/data_source/dispatcher_support_remote_data_source.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/models/request/reassign_driver_request_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/models/request/resolve_issue_request_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/models/response/dispatcher_issue_details_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/models/response/reassign_driver_candidates_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/models/response/reassignment_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/models/response/resolve_issue_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/data/repo/dispatcher_support_repository_impl.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_detail_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/dispatcher_issue_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassign_driver_candidates_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassign_driver_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/reassignment_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_support/domain/entities/resolve_issue_result_entity.dart';

class FakeDispatcherSupportRemoteDataSource
    implements DispatcherSupportRemoteDataSource {
  DispatcherIssueDetailsResponseDto? issueDetailsResponse;
  ResolveIssueResponseDto? resolveResponse;
  ReassignDriverCandidatesResponseDto? candidatesResponse;
  ReassignmentResponseDto? reassignmentResponse;

  Exception? errorToThrow;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  @override
  Future<DispatcherIssueDetailsResponseDto> getIssueDetails(String issueId) async {
    if (errorToThrow != null) throw errorToThrow!;
    return issueDetailsResponse!;
  }

  @override
  Future<ResolveIssueResponseDto> resolveIssue(
    String issueId,
    ResolveIssueRequestDto request,
  ) async {
    if (errorToThrow != null) throw errorToThrow!;
    return resolveResponse!;
  }

  @override
  Future<ReassignDriverCandidatesResponseDto> getReplacementCandidates(
    String issueId, {
    required int pageNumber,
    required int pageSize,
  }) async {
    if (errorToThrow != null) throw errorToThrow!;
    return candidatesResponse!;
  }

  @override
  Future<ReassignmentResponseDto> reassignIssue(
    String issueId,
    ReassignDriverRequestDto request,
  ) async {
    if (errorToThrow != null) throw errorToThrow!;
    return reassignmentResponse!;
  }
}

void main() {
  late FakeDispatcherSupportRemoteDataSource fakeDataSource;
  late DispatcherSupportRepositoryImpl repository;

  setUp(() {
    fakeDataSource = FakeDispatcherSupportRemoteDataSource();
    repository = DispatcherSupportRepositoryImpl(fakeDataSource);
  });

  group('DispatcherSupportRepository issue workflow tests', () {
    test('getIssueDetails returns ApiResult.success with mapped entity', () async {
      fakeDataSource.issueDetailsResponse =
          const DispatcherIssueDetailsResponseDto(
        issueId: 'iss-99',
        title: 'عطل مفاجئ',
        status: 'Open',
        boxCode: 'BX-99',
        area: 'حي الملز',
      );

      final result = await repository.getIssueDetails('iss-99');
      expect(result, isA<ApiSuccessResult<DispatcherIssueDetailEntity>>());
      final data = (result as ApiSuccessResult<DispatcherIssueDetailEntity>).data;
      expect(data.issueId, 'iss-99');
      expect(data.status, DispatcherIssueStatus.open);
    });

    test('resolveIssue maps 409 conflict preserving backendErrorCode', () async {
      fakeDataSource.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/resolve'),
        response: Response(
          requestOptions: RequestOptions(path: '/resolve'),
          statusCode: 409,
          data: {
            'errorCode': 'ISSUE_ALREADY_RESOLVED',
            'message': 'البلاغ تم حله مسبقاً',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final result = await repository.resolveIssue('iss-99', 'ملاحظات');
      expect(result, isA<ApiErrorResult<ResolveIssueResultEntity>>());
      final failure = (result as ApiErrorResult<ResolveIssueResultEntity>).failure;
      expect(failure.exception, isA<ApiException>());
      expect(failure.exception.backendErrorCode, 'ISSUE_ALREADY_RESOLVED');
      expect(failure.errorMessage, contains('تم حله مسبقاً'));
    });

    test('getReplacementCandidates returns mapped candidates and pagination', () async {
      fakeDataSource.candidatesResponse =
          const ReassignDriverCandidatesResponseDto(
        candidates: [
          ReassignDriverCandidateDto(
            id: 'c-1',
            name: 'سائق بديل',
            code: 'DRV-111',
            recommendationRank: 1,
            distanceKm: 1.2,
          ),
        ],
      );

      final result = await repository.getReplacementCandidates('iss-99');
      expect(result, isA<ApiSuccessResult<ReassignDriverCandidatesEntity>>());
      final data = (result as ApiSuccessResult<ReassignDriverCandidatesEntity>).data;
      expect(data.candidates.length, 1);
      expect(data.candidates.first.name, 'سائق بديل');
    });

    test('reassignIssue maps 409 REPLACEMENT_DRIVER_NO_LONGER_AVAILABLE', () async {
      fakeDataSource.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/reassign'),
        response: Response(
          requestOptions: RequestOptions(path: '/reassign'),
          statusCode: 409,
          data: {
            'errorCode': 'REPLACEMENT_DRIVER_NO_LONGER_AVAILABLE',
            'message': 'السائق لم يعد متاحاً',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final result = await repository.reassignIssue(
        'iss-99',
        const ReassignDriverRequestEntity(
          replacementDriverId: 'c-1',
          notes: null,
        ),
      );

      expect(result, isA<ApiErrorResult<ReassignmentResultEntity>>());
      final failure = (result as ApiErrorResult<ReassignmentResultEntity>).failure;
      expect(failure.exception, isA<ApiException>());
      expect(failure.exception.backendErrorCode, 'REPLACEMENT_DRIVER_NO_LONGER_AVAILABLE');
    });
  });
}
