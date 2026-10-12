import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/errors/api_exception.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/voice_call_display_entity.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/voice_call_eligibility_entity.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/voice_call_snapshot_entity.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/voice_call_status.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/repo/driver_calling_repository.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/cancel_voice_call_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/check_call_eligibility_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/end_voice_call_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/get_active_voice_call_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/get_delivery_contact_case_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/get_voice_call_display_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/get_voice_call_snapshot_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/hold_delivery_contact_case_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/initiate_voice_call_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/resume_delivery_contact_case_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/usecase/reveal_customer_phone_usecase.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/manager/driver_calling_event.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/manager/driver_calling_view_model.dart';

class FakeDriverCallingRepository implements DriverCallingRepository {
  final _snapshotController =
      StreamController<VoiceCallSnapshotEntity>.broadcast();
  final _statusController = StreamController<VoiceCallStatus>.broadcast();

  @override
  Stream<VoiceCallSnapshotEntity> get onSnapshotUpdated =>
      _snapshotController.stream;

  @override
  Stream<VoiceCallStatus> get onStatusChanged => _statusController.stream;

  void emitSnapshot(VoiceCallSnapshotEntity s) => _snapshotController.add(s);
  void emitStatus(VoiceCallStatus s) => _statusController.add(s);

  int cancelCallCount = 0;
  int endCallCount = 0;
  int cleanupCallCount = 0;

  ApiResult<void> cancelCallResult = const ApiSuccessResult(data: null);
  ApiResult<void> endCallResult = const ApiSuccessResult(data: null);
  ApiResult<VoiceCallSnapshotEntity> getSnapshotResult = const ApiSuccessResult(
    data: VoiceCallSnapshotEntity(
      callId: 'call-1',
      tripStopId: 'stop-1',
      protocolVersion: 2,
      sequence: 1,
      status: VoiceCallStatus.ended,
    ),
  );

  @override
  Future<ApiResult<void>> cancelCall(String callId) async {
    cancelCallCount++;
    return cancelCallResult;
  }

  @override
  Future<ApiResult<void>> endCall(String callId) async {
    endCallCount++;
    return endCallResult;
  }

  @override
  Future<void> cleanupCall([String? targetCallId]) async {
    cleanupCallCount++;
  }

  int getSnapshotCount = 0;

  @override
  Future<ApiResult<VoiceCallSnapshotEntity>> getCallSnapshot(
    String callId,
  ) async {
    getSnapshotCount++;
    return getSnapshotResult;
  }

  int initiateCallCount = 0;
  String? lastInitiateClientRequestId;
  ApiResult<VoiceCallSnapshotEntity> initiateCallResult =
      const ApiSuccessResult(
        data: VoiceCallSnapshotEntity(
          callId: 'call-init-1',
          tripStopId: 'stop-1',
          protocolVersion: 2,
          sequence: 1,
          status: VoiceCallStatus.ringing,
        ),
      );

  @override
  Future<ApiResult<VoiceCallSnapshotEntity>> initiateCall({
    required String tripStopId,
    required String clientRequestId,
  }) async {
    initiateCallCount++;
    lastInitiateClientRequestId = clientRequestId;
    return initiateCallResult;
  }

  ApiResult<VoiceCallSnapshotEntity?> getActiveCallResult =
      const ApiSuccessResult(data: null);

  @override
  Future<ApiResult<VoiceCallSnapshotEntity?>> getActiveCall() async {
    return getActiveCallResult;
  }

  @override
  Future<ApiResult<VoiceCallDisplayEntity>> getCallDisplay(
    String callId, {
    String? languageCode,
  }) async {
    return const ApiSuccessResult(
      data: VoiceCallDisplayEntity(callId: 'call-1', tripStopId: 'stop-1'),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeDriverCallingRepository repo;
  late DriverCallingViewModel viewModel;

  setUp(() {
    repo = FakeDriverCallingRepository();
    viewModel = DriverCallingViewModel(
      checkCallEligibilityUseCase: CheckCallEligibilityUseCase(repo),
      initiateVoiceCallUseCase: InitiateVoiceCallUseCase(repo),
      cancelVoiceCallUseCase: CancelVoiceCallUseCase(repo),
      endVoiceCallUseCase: EndVoiceCallUseCase(repo),
      getActiveVoiceCallUseCase: GetActiveVoiceCallUseCase(repo),
      getVoiceCallSnapshotUseCase: GetVoiceCallSnapshotUseCase(repo),
      getDeliveryContactCaseUseCase: GetDeliveryContactCaseUseCase(repo),
      holdDeliveryContactCaseUseCase: HoldDeliveryContactCaseUseCase(repo),
      resumeDeliveryContactCaseUseCase: ResumeDeliveryContactCaseUseCase(repo),
      revealCustomerPhoneUseCase: RevealCustomerPhoneUseCase(repo),
      getVoiceCallDisplayUseCase: GetVoiceCallDisplayUseCase(repo),
      repository: repo,
    );
  });

  tearDown(() async {
    await viewModel.close();
  });

  group('DriverCallingViewModel Duration & Hangup routing', () {
    test(
      'does not start timer on Ringing, Accepted, or local Connecting status',
      () async {
        repo.emitStatus(VoiceCallStatus.ringing);
        await Future.delayed(const Duration(milliseconds: 50));
        expect(viewModel.state.durationSeconds, 0);

        repo.emitStatus(VoiceCallStatus.accepted);
        await Future.delayed(const Duration(milliseconds: 50));
        expect(viewModel.state.durationSeconds, 0);

        repo.emitStatus(VoiceCallStatus.connecting);
        await Future.delayed(const Duration(milliseconds: 50));
        expect(viewModel.state.durationSeconds, 0);
      },
    );

    test(
      'starts timer only after authoritative Active snapshot with connectedAtUtc',
      () async {
        final connectedTime = DateTime.now().toUtc().subtract(
          const Duration(seconds: 5),
        );
        final activeSnapshot = VoiceCallSnapshotEntity(
          callId: 'call-1',
          tripStopId: 'stop-1',
          protocolVersion: 2,
          sequence: 2,
          status: VoiceCallStatus.active,
          connectedAtUtc: connectedTime,
          durationSeconds: 5,
        );

        repo.emitSnapshot(activeSnapshot);
        await Future.delayed(const Duration(milliseconds: 50));

        expect(viewModel.state.status, VoiceCallStatus.active);
        expect(viewModel.state.durationSeconds, greaterThanOrEqualTo(5));
      },
    );

    test('hangup routes Created/Ringing to /cancel', () async {
      const ringingSnapshot = VoiceCallSnapshotEntity(
        callId: 'call-1',
        tripStopId: 'stop-1',
        protocolVersion: 2,
        sequence: 1,
        status: VoiceCallStatus.ringing,
      );
      repo.emitSnapshot(ringingSnapshot);
      await Future.delayed(Duration.zero);

      viewModel.doIntent(const EndCallEvent());
      await Future.delayed(Duration.zero);

      expect(repo.cancelCallCount, 1);
      expect(repo.endCallCount, 0);
      expect(viewModel.state.status, VoiceCallStatus.cancelled);
    });

    test('hangup routes Accepted/Connecting/Active to /end', () async {
      final activeSnapshot = VoiceCallSnapshotEntity(
        callId: 'call-1',
        tripStopId: 'stop-1',
        protocolVersion: 2,
        sequence: 2,
        status: VoiceCallStatus.active,
        connectedAtUtc: DateTime.now().toUtc(),
      );
      repo.emitSnapshot(activeSnapshot);
      await Future.delayed(Duration.zero);

      viewModel.doIntent(const EndCallEvent());
      await Future.delayed(Duration.zero);

      expect(repo.endCallCount, 1);
      expect(repo.cancelCallCount, 0);
      expect(viewModel.state.status, VoiceCallStatus.ended);
    });

    test('409 Conflict reconciles with snapshot from server', () async {
      final activeSnapshot = VoiceCallSnapshotEntity(
        callId: 'call-1',
        tripStopId: 'stop-1',
        protocolVersion: 2,
        sequence: 2,
        status: VoiceCallStatus.active,
        connectedAtUtc: DateTime.now().toUtc(),
      );
      repo.emitSnapshot(activeSnapshot);
      await Future.delayed(Duration.zero);

      repo.getSnapshotResult = const ApiSuccessResult(
        data: VoiceCallSnapshotEntity(
          callId: 'call-1',
          tripStopId: 'stop-1',
          protocolVersion: 2,
          sequence: 3,
          status: VoiceCallStatus.ended,
        ),
      );

      repo.endCallResult = ApiErrorResult(
        failure: Failure.fromException(
          const ApiException(
            errorType: ApiErrorType.conflict,
            message: 'Conflict',
            statusCode: 409,
          ),
        ),
      );

      viewModel.doIntent(const EndCallEvent());
      await Future.delayed(Duration.zero);

      expect(repo.endCallCount, 1);
      expect(viewModel.state.status, VoiceCallStatus.ended);
    });

    test('Ended call retried in the same VM gets a new requestId', () async {
      // First initiate attempt
      viewModel.doIntent(const InitiateCallEvent(tripStopId: 'stop-1'));
      await Future.delayed(Duration.zero);

      final firstRequestId = repo.lastInitiateClientRequestId;
      expect(firstRequestId, isNotNull);

      // Call reaches terminal state (Ended)
      repo.emitSnapshot(
        const VoiceCallSnapshotEntity(
          callId: 'call-init-1',
          tripStopId: 'stop-1',
          protocolVersion: 2,
          sequence: 2,
          status: VoiceCallStatus.ended,
        ),
      );
      await Future.delayed(Duration.zero);
      expect(viewModel.state.status, VoiceCallStatus.ended);

      // Second independent initiate attempt in same VM
      viewModel.doIntent(const InitiateCallEvent(tripStopId: 'stop-1'));
      await Future.delayed(Duration.zero);

      final secondRequestId = repo.lastInitiateClientRequestId;
      expect(secondRequestId, isNotNull);
      expect(
        secondRequestId,
        isNot(equals(firstRequestId)),
        reason:
            'New independent attempt after terminal must generate a fresh requestId',
      );
    });

    test(
      'Accepted state stops ring timeout checks and cancels deadline timer',
      () async {
        // Initiate call which enters ringing with future deadline
        viewModel.doIntent(const InitiateCallEvent(tripStopId: 'stop-1'));
        await Future.delayed(Duration.zero);

        final ringingSnapshot = VoiceCallSnapshotEntity(
          callId: 'call-init-1',
          tripStopId: 'stop-1',
          protocolVersion: 2,
          sequence: 1,
          status: VoiceCallStatus.ringing,
          deadlineAtUtc: DateTime.now().toUtc().add(
            const Duration(seconds: 30),
          ),
        );
        repo.emitSnapshot(ringingSnapshot);
        await Future.delayed(Duration.zero);

        // Now customer answers -> Accepted status
        const acceptedSnapshot = VoiceCallSnapshotEntity(
          callId: 'call-init-1',
          tripStopId: 'stop-1',
          protocolVersion: 2,
          sequence: 2,
          status: VoiceCallStatus.accepted,
        );
        repo.emitSnapshot(acceptedSnapshot);
        await Future.delayed(Duration.zero);

        expect(viewModel.state.status, VoiceCallStatus.accepted);
      },
    );

    test(
      'Repeated expired Ringing responses issue one bounded reconciliation at a time',
      () async {
        repo.getSnapshotResult = const ApiSuccessResult(
          data: VoiceCallSnapshotEntity(
            callId: 'call-ringing-1',
            tripStopId: 'stop-1',
            protocolVersion: 2,
            sequence: 2,
            status: VoiceCallStatus.ringing,
          ),
        );

        final expiredSnapshot = VoiceCallSnapshotEntity(
          callId: 'call-ringing-1',
          tripStopId: 'stop-1',
          protocolVersion: 2,
          sequence: 1,
          status: VoiceCallStatus.ringing,
          deadlineAtUtc: DateTime.now().toUtc().subtract(
            const Duration(seconds: 1),
          ),
        );

        // Emit expired snapshot
        repo.emitSnapshot(expiredSnapshot);
        await Future.delayed(Duration.zero);

        expect(repo.getSnapshotCount, lessThanOrEqualTo(1));
      },
    );

    test(
      'Ambiguous timeout reconciles active snapshot before reusing original requestId',
      () async {
        // First initiate with clientRequestId
        viewModel.doIntent(const InitiateCallEvent(tripStopId: 'stop-1'));
        await Future.delayed(Duration.zero);
        final initialReqId = repo.lastInitiateClientRequestId;
        expect(initialReqId, isNotNull);

        // Suppose active call exists on server with the same tripStopId
        const activeSnapshot = VoiceCallSnapshotEntity(
          callId: 'call-existing-active',
          tripStopId: 'stop-1',
          protocolVersion: 2,
          sequence: 3,
          status: VoiceCallStatus.ringing,
        );
        repo.getActiveCallResult = const ApiSuccessResult(data: activeSnapshot);

        // Retry initiate before terminal state
        final initialInitiateCount = repo.initiateCallCount;
        viewModel.doIntent(const InitiateCallEvent(tripStopId: 'stop-1'));
        await Future.delayed(Duration.zero);

        // Does not call initiateCall again because active call was found and adopted
        expect(repo.initiateCallCount, initialInitiateCount);
        expect(viewModel.state.snapshot?.callId, 'call-existing-active');
      },
    );

    test(
      'No initiate occurs with empty tripStopId or disallowed eligibility',
      () async {
        final initialCount = repo.initiateCallCount;

        // Empty tripStopId
        viewModel.doIntent(const InitiateCallEvent(tripStopId: '   '));
        await Future.delayed(Duration.zero);
        expect(viewModel.state.errorMessage, 'Invalid trip stop ID');
        expect(repo.initiateCallCount, initialCount);

        // Disallowed eligibility
        viewModel.emit(
          viewModel.state.copyWith(
            clearError: true,
            eligibility: const VoiceCallEligibilityEntity(
              canInitiate: false,
              reasonCode: 'CallNotEligible',
            ),
          ),
        );
        viewModel.doIntent(const InitiateCallEvent(tripStopId: 'stop-1'));
        await Future.delayed(Duration.zero);
        expect(viewModel.state.errorMessage, 'CallNotEligible');
        expect(repo.initiateCallCount, initialCount);
      },
    );
  });
}
