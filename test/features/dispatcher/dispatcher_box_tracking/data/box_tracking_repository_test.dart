import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/data/data_source/box_tracking_remote_data_source.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/data/models/request/report_box_issue_request_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/data/models/response/box_tracking_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/data/models/response/report_box_issue_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/data/repo/box_tracking_repository_impl.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_issue_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/box_tracking_status.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/domain/entities/report_box_issue_request_entity.dart';

class _FakeRemoteDataSource implements BoxTrackingRemoteDataSource {
  BoxTrackingResponseDto? trackingResponse;
  ReportBoxIssueResponseDto? reportResponse;
  Exception? errorToThrow;

  @override
  Future<BoxTrackingResponseDto> getTracking(String boxId) async {
    if (errorToThrow != null) throw errorToThrow!;
    return trackingResponse ?? const BoxTrackingResponseDto();
  }

  @override
  Future<ReportBoxIssueResponseDto> reportIssue(
    String boxId,
    ReportBoxIssueRequestDto request,
  ) async {
    if (errorToThrow != null) throw errorToThrow!;
    return reportResponse ?? const ReportBoxIssueResponseDto();
  }
}

void main() {
  late _FakeRemoteDataSource fakeRemoteDataSource;
  late BoxTrackingRepositoryImpl repository;

  const testBoxId = '4f8a3c21-9b12-42e7-90c1-872f2316e110';

  setUp(() {
    fakeRemoteDataSource = _FakeRemoteDataSource();
    repository = BoxTrackingRepositoryImpl(fakeRemoteDataSource);
  });

  group('BoxTrackingRepositoryImpl', () {
    test('getTracking returns mapped entity on success', () async {
      fakeRemoteDataSource.trackingResponse = const BoxTrackingResponseDto(
        box: BoxInfoDto(
          boxId: testBoxId,
          boxCode: '#BX-10256',
          status: 'OnTheWay',
          statusText: 'في الطريق',
          statusColor: '#3B82F6',
          customerName: 'أحمد العتيبي',
          scheduledTimeText: '12:30 م',
          deliveryAddress: 'السليمانية، الرياض',
        ),
      );

      final result = await repository.getTracking(testBoxId);

      expect(result, isA<ApiSuccessResult>());
      final entity = (result as ApiSuccessResult).data;
      expect(entity.boxId, testBoxId);
      expect(entity.boxCode, '#BX-10256');
      expect(entity.status, BoxTrackingStatus.onTheWay);
    });

    test(
      'getTracking catches DioException and returns ApiErrorResult',
      () async {
        fakeRemoteDataSource.errorToThrow = DioException(
          requestOptions: RequestOptions(path: '/tracking'),
          type: DioExceptionType.connectionTimeout,
          error: 'Connection timeout',
        );

        final result = await repository.getTracking(testBoxId);

        expect(result, isA<ApiErrorResult>());
      },
    );

    test(
      'reportIssue calls remote with DTO and returns mapped result entity',
      () async {
        fakeRemoteDataSource.reportResponse = const ReportBoxIssueResponseDto(
          issueId: 'issue-100',
          boxId: testBoxId,
          reportedAtUtc: '2026-09-23T12:00:00Z',
          message: 'تم تسجيل البلاغ بنجاح',
        );

        const request = ReportBoxIssueRequestEntity(
          issueType: BoxIssueType.delayedDelivery,
          description: 'زحمة سير',
        );

        final result = await repository.reportIssue(testBoxId, request);

        expect(result, isA<ApiSuccessResult>());
        final entity = (result as ApiSuccessResult).data;
        expect(entity.issueId, 'issue-100');
        expect(entity.message, 'تم تسجيل البلاغ بنجاح');
      },
    );

    test('reportIssue catches exception and returns ApiErrorResult', () async {
      fakeRemoteDataSource.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/issues'),
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: RequestOptions(path: '/issues'),
          statusCode: 400,
        ),
      );

      const request = ReportBoxIssueRequestEntity(
        issueType: BoxIssueType.other,
        description: 'ملاحظة',
      );

      final result = await repository.reportIssue(testBoxId, request);

      expect(result, isA<ApiErrorResult>());
    });
  });
}
