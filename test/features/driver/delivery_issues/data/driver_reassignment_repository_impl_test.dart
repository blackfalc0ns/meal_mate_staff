import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/data/data_source/driver_reassignment_remote_data_source.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/data/models/request/driver_reassignment_request_dto.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/data/models/response/driver_reassignment_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/data/repo/driver_reassignment_repository_impl.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/reassignment_reason.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/reassignment_request_entity.dart';

class FakeDriverReassignmentRemoteDataSource
    implements DriverReassignmentRemoteDataSource {
  DriverReassignmentResponseDto? response;
  Object? throwError;

  String? capturedBoxId;
  DriverReassignmentRequestDto? capturedRequest;
  int callCount = 0;

  @override
  Future<DriverReassignmentResponseDto> submit({
    required String boxId,
    required DriverReassignmentRequestDto request,
  }) async {
    callCount++;
    capturedBoxId = boxId;
    capturedRequest = request;

    if (throwError != null) {
      throw throwError!;
    }
    return response!;
  }
}

void main() {
  group('DriverReassignmentRepositoryImpl Tests', () {
    late FakeDriverReassignmentRemoteDataSource fakeRemoteDataSource;
    late DriverReassignmentRepositoryImpl repository;

    setUp(() {
      fakeRemoteDataSource = FakeDriverReassignmentRemoteDataSource();
      repository = DriverReassignmentRepositoryImpl(fakeRemoteDataSource);
    });

    test('successfully submits reassignment with exact boxId and mapped body', () async {
      fakeRemoteDataSource.response = const DriverReassignmentResponseDto(
        requestId: 'req-uuid-1234',
        boxId: 'box-uuid-5678',
        boxCode: '#BX-100',
        status: 'ReassignmentRequested',
        message: 'Under review',
        requestedAtUtc: '2026-10-07T08:00:00Z',
      );

      final result = await repository.submit(
        boxId: 'box-uuid-5678',
        request: const ReassignmentRequestEntity(
          reason: ReassignmentReason.vehicleBreakdown,
          notes: 'Engine overheated',
          latitude: 29.35,
          longitude: 47.95,
        ),
      );

      expect(fakeRemoteDataSource.callCount, equals(1));
      expect(fakeRemoteDataSource.capturedBoxId, equals('box-uuid-5678'));
      expect(fakeRemoteDataSource.capturedRequest?.reason, equals('VehicleBreakdown'));
      expect(fakeRemoteDataSource.capturedRequest?.notes, equals('Engine overheated'));
      expect(fakeRemoteDataSource.capturedRequest?.latitude, equals(29.35));
      expect(fakeRemoteDataSource.capturedRequest?.longitude, equals(47.95));

      expect(result, isA<ApiSuccessResult>());
      final success = result as ApiSuccessResult;
      expect(success.data.requestId, equals('req-uuid-1234'));
      expect(success.data.boxId, equals('box-uuid-5678'));
      expect(success.data.boxCode, equals('#BX-100'));
      expect(success.data.status, equals('ReassignmentRequested'));
    });

    test('rejects empty target boxId locally before making network call', () async {
      final result = await repository.submit(
        boxId: '   ',
        request: const ReassignmentRequestEntity(
          reason: ReassignmentReason.deviceFailure,
        ),
      );

      expect(fakeRemoteDataSource.callCount, equals(0));
      expect(result, isA<ApiErrorResult>());
    });

    test('rejects notes exceeding 250 characters locally before making network call', () async {
      final longNotes = 'a' * 251;
      final result = await repository.submit(
        boxId: 'box-uuid-5678',
        request: ReassignmentRequestEntity(
          reason: ReassignmentReason.deviceFailure,
          notes: longNotes,
        ),
      );

      expect(fakeRemoteDataSource.callCount, equals(0));
      expect(result, isA<ApiErrorResult>());
    });

    test('safeApiCall maps DioException and preserves ProblemDetails backend code', () async {
      fakeRemoteDataSource.throwError = DioException(
        requestOptions: RequestOptions(path: '/api/v1/driver/orders/box-1/request-reassignment'),
        response: Response(
          requestOptions: RequestOptions(path: '/api/v1/driver/orders/box-1/request-reassignment'),
          statusCode: 409,
          data: {
            'type': 'https://httpstatuses.com/409',
            'title': 'Conflict',
            'status': 409,
            'detail': 'A reassignment request is already pending for this box.',
            'code': 'driver.reassignment.request_already_active',
          },
        ),
        type: DioExceptionType.badResponse,
      );

      final result = await repository.submit(
        boxId: 'box-1',
        request: const ReassignmentRequestEntity(
          reason: ReassignmentReason.trafficAccident,
        ),
      );

      expect(result, isA<ApiErrorResult>());
      final errorResult = result as ApiErrorResult;
      expect(errorResult.failure.code, equals('driver.reassignment.request_already_active'));
      expect(errorResult.failure.exception.backendErrorCode, equals('driver.reassignment.request_already_active'));
      expect(errorResult.failure.exception.statusCode, equals(409));
    });

    test('rejects response if returned boxId mismatches submitted boxId', () async {
      fakeRemoteDataSource.response = const DriverReassignmentResponseDto(
        requestId: 'req-uuid-1234',
        boxId: 'DIFFERENT-BOX-UUID',
        status: 'ReassignmentRequested',
      );

      final result = await repository.submit(
        boxId: 'SUBMITTED-BOX-UUID',
        request: const ReassignmentRequestEntity(
          reason: ReassignmentReason.medicalOrPersonalEmergency,
        ),
      );

      expect(result, isA<ApiErrorResult>());
    });
  });
}
