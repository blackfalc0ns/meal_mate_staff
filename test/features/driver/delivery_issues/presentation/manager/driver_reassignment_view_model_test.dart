import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/reassignment_reason.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/reassignment_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/reassignment_result_entity.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/usecase/submit_driver_reassignment_usecase.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/presentation/manager/driver_reassignment_event.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/presentation/manager/driver_reassignment_state.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/presentation/manager/driver_reassignment_view_model.dart';

class CompleterFakeSubmitDriverReassignmentUseCase
    implements SubmitDriverReassignmentUseCase {
  Completer<ApiResult<ReassignmentResultEntity>> completer = Completer();
  int callCount = 0;
  String? capturedBoxId;
  ReassignmentRequestEntity? capturedRequest;


  @override
  Future<ApiResult<ReassignmentResultEntity>> call({
    required String boxId,
    required ReassignmentRequestEntity request,
  }) {
    callCount++;
    capturedBoxId = boxId;
    capturedRequest = request;
    return completer.future;
  }
}

void main() {
  group('DriverReassignmentViewModel Tests', () {
    late CompleterFakeSubmitDriverReassignmentUseCase fakeUseCase;
    late DriverReassignmentViewModel viewModel;

    setUp(() {
      fakeUseCase = CompleterFakeSubmitDriverReassignmentUseCase();
      viewModel = DriverReassignmentViewModel(submitUseCase: fakeUseCase);
    });

    tearDown(() async {
      await viewModel.close();
    });

    test('initial state is idle with no failure or result', () {
      expect(viewModel.state.status, equals(DriverReassignmentStatus.idle));
      expect(viewModel.state.isSubmitting, isFalse);
      expect(viewModel.state.failure, isNull);
      expect(viewModel.state.result, isNull);
    });

    test('two submit dispatches while pending produce only one usecase call', () async {
      const event = SubmitDriverReassignmentEvent(
        boxId: 'box-123',
        request: ReassignmentRequestEntity(
          reason: ReassignmentReason.vehicleBreakdown,
          notes: 'Engine smoke',
        ),
      );

      viewModel.doIntent(event);
      expect(viewModel.state.isSubmitting, isTrue);
      expect(fakeUseCase.callCount, equals(1));

      // Second tap while still pending
      viewModel.doIntent(event);
      expect(fakeUseCase.callCount, equals(1));

      // Resolve successfully
      fakeUseCase.completer.complete(
        const ApiSuccessResult(
          data: ReassignmentResultEntity(
            requestId: 'req-1',
            boxId: 'box-123',
            status: 'ReassignmentRequested',
          ),
        ),
      );

      await Future<void>.delayed(Duration.zero);
      expect(viewModel.state.isSuccess, isTrue);
      expect(viewModel.state.result?.requestId, equals('req-1'));

      // Third tap after success is also blocked
      viewModel.doIntent(event);
      expect(fakeUseCase.callCount, equals(1));
    });

    test('closing viewModel during pending request does not throw or emit after close', () async {
      const event = SubmitDriverReassignmentEvent(
        boxId: 'box-123',
        request: ReassignmentRequestEntity(
          reason: ReassignmentReason.trafficAccident,
        ),
      );

      viewModel.doIntent(event);
      expect(viewModel.state.isSubmitting, isTrue);

      await viewModel.close();

      expect(viewModel.isClosed, isTrue);
      fakeUseCase.completer.complete(
        const ApiSuccessResult(
          data: ReassignmentResultEntity(
            requestId: 'req-1',
            boxId: 'box-123',
            status: 'ReassignmentRequested',
          ),
        ),
      );

      await Future<void>.delayed(Duration.zero);
    });

    test('validates required target boxId locally', () async {
      const event = SubmitDriverReassignmentEvent(
        boxId: '   ',
        request: ReassignmentRequestEntity(
          reason: ReassignmentReason.deviceFailure,
        ),
      );

      viewModel.doIntent(event);
      expect(fakeUseCase.callCount, equals(0));
      expect(viewModel.state.isFailed, isTrue);
      expect(viewModel.state.failure?.code, equals('invalid_target'));
    });

    test('validates notes length boundary: 250 characters succeeds, 251 fails locally', () async {
      final validNotes = 'a' * 250;
      final invalidNotes = 'a' * 251;

      // 251 characters -> rejected immediately
      viewModel.doIntent(SubmitDriverReassignmentEvent(
        boxId: 'box-123',
        request: ReassignmentRequestEntity(
          reason: ReassignmentReason.otherOperationalReason,
          notes: invalidNotes,
        ),
      ));
      expect(fakeUseCase.callCount, equals(0));
      expect(viewModel.state.isFailed, isTrue);
      expect(viewModel.state.failure?.code, equals('driver.reassignment.notes_too_long'));

      // 250 characters -> passes to usecase
      viewModel.doIntent(SubmitDriverReassignmentEvent(
        boxId: 'box-123',
        request: ReassignmentRequestEntity(
          reason: ReassignmentReason.otherOperationalReason,
          notes: validNotes,
        ),
      ));
      expect(fakeUseCase.callCount, equals(1));
      expect(viewModel.state.isSubmitting, isTrue);
    });

    test('validates coordinates: incomplete pair fails locally', () async {
      viewModel.doIntent(const SubmitDriverReassignmentEvent(
        boxId: 'box-123',
        request: ReassignmentRequestEntity(
          reason: ReassignmentReason.medicalOrPersonalEmergency,
          latitude: 29.35,
          longitude: null,
        ),
      ));
      expect(fakeUseCase.callCount, equals(0));
      expect(viewModel.state.isFailed, isTrue);
      expect(viewModel.state.failure?.code, equals('Orders.CoordinatesPairRequired'));
    });

    test('validates coordinates: out of range latitude fails locally', () async {
      viewModel.doIntent(const SubmitDriverReassignmentEvent(
        boxId: 'box-123',
        request: ReassignmentRequestEntity(
          reason: ReassignmentReason.medicalOrPersonalEmergency,
          latitude: 95.0,
          longitude: 45.0,
        ),
      ));
      expect(fakeUseCase.callCount, equals(0));
      expect(viewModel.state.isFailed, isTrue);
      expect(viewModel.state.failure?.code, equals('Orders.CoordinatesOutOfRange'));
    });

    test('409 driver.reassignment.request_already_active sets status to blocked and locks further submits', () async {
      const event = SubmitDriverReassignmentEvent(
        boxId: 'box-123',
        request: ReassignmentRequestEntity(
          reason: ReassignmentReason.vehicleBreakdown,
        ),
      );

      viewModel.doIntent(event);
      expect(viewModel.state.isSubmitting, isTrue);

      final conflictFailure = Failure(
        errorMessage: 'Request already active',
        code: 'driver.reassignment.request_already_active',
        exception: const ApiException(
          errorType: ApiErrorType.conflict,
          message: 'Request already active',
          statusCode: 409,
          backendErrorCode: 'driver.reassignment.request_already_active',
        ),
      );
      fakeUseCase.completer.complete(ApiErrorResult(failure: conflictFailure));

      await Future<void>.delayed(Duration.zero);
      expect(viewModel.state.isBlocked, isTrue);
      expect(viewModel.state.isAlreadyActiveConflict, isTrue);

      // Attempting to submit again is blocked
      viewModel.doIntent(event);
      expect(fakeUseCase.callCount, equals(1));
    });

    test('409 driver.reassignment.stop_state_not_allowed sets status to blocked', () async {
      const event = SubmitDriverReassignmentEvent(
        boxId: 'box-123',
        request: ReassignmentRequestEntity(
          reason: ReassignmentReason.vehicleBreakdown,
        ),
      );

      viewModel.doIntent(event);

      final conflictFailure = Failure(
        errorMessage: 'Stop state not allowed',
        code: 'driver.reassignment.stop_state_not_allowed',
        exception: const ApiException(
          errorType: ApiErrorType.conflict,
          message: 'Stop state not allowed',
          statusCode: 409,
          backendErrorCode: 'driver.reassignment.stop_state_not_allowed',
        ),
      );
      fakeUseCase.completer.complete(ApiErrorResult(failure: conflictFailure));

      await Future<void>.delayed(Duration.zero);
      expect(viewModel.state.isBlocked, isTrue);
      expect(viewModel.state.isStopStateNotAllowed, isTrue);
    });

    test('400 bad request sets status to failed and allows retry', () async {
      const event = SubmitDriverReassignmentEvent(
        boxId: 'box-123',
        request: ReassignmentRequestEntity(
          reason: ReassignmentReason.vehicleBreakdown,
        ),
      );

      viewModel.doIntent(event);

      final badRequestFailure = Failure(
        errorMessage: 'Invalid reason',
        code: 'driver.reassignment.reason_invalid',
        exception: const ApiException(
          errorType: ApiErrorType.badRequest,
          message: 'Invalid reason',
          statusCode: 400,
          backendErrorCode: 'driver.reassignment.reason_invalid',
        ),
      );
      fakeUseCase.completer.complete(ApiErrorResult(failure: badRequestFailure));

      await Future<void>.delayed(Duration.zero);
      expect(viewModel.state.isFailed, isTrue);
      expect(viewModel.state.isBlocked, isFalse);

      // Create a fresh completer for retry
      fakeUseCase.completer = Completer();
      viewModel.doIntent(event);
      expect(fakeUseCase.callCount, equals(2));
      expect(viewModel.state.isSubmitting, isTrue);
    });

    test('ResetDriverReassignmentStatusEvent clears failure without resetting form state', () async {
      viewModel.doIntent(const SubmitDriverReassignmentEvent(
        boxId: '   ',
        request: ReassignmentRequestEntity(
          reason: ReassignmentReason.deviceFailure,
        ),
      ));
      expect(viewModel.state.isFailed, isTrue);
      expect(viewModel.state.failure, isNotNull);

      viewModel.doIntent(const ResetDriverReassignmentStatusEvent());
      expect(viewModel.state.status, equals(DriverReassignmentStatus.idle));
      expect(viewModel.state.failure, isNull);
    });
  });
}
