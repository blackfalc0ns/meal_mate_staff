import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/delivery_contact_case_entity.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/ice_server_config_entity.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/phone_grant_entity.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/voice_call_display_entity.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/voice_call_eligibility_entity.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/voice_call_snapshot_entity.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/voice_call_status.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/voice_device_session_entity.dart';
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
  final _snapshotController = StreamController<VoiceCallSnapshotEntity>.broadcast();
  final _statusController = StreamController<VoiceCallStatus>.broadcast();

  @override
  Stream<VoiceCallSnapshotEntity> get onSnapshotUpdated => _snapshotController.stream;

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
  Future<void> cleanupCall() async {
    cleanupCallCount++;
  }

  @override
  Future<ApiResult<VoiceCallSnapshotEntity>> getCallSnapshot(String callId) async {
    return getSnapshotResult;
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

  tearDown(() {
    viewModel.close();
  });

  group('DriverCallingViewModel Duration & Hangup routing', () {
    test('does not start timer on Ringing, Accepted, or local Connecting status', () async {
      repo.emitStatus(VoiceCallStatus.ringing);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(viewModel.state.durationSeconds, 0);

      repo.emitStatus(VoiceCallStatus.accepted);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(viewModel.state.durationSeconds, 0);

      repo.emitStatus(VoiceCallStatus.connecting);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(viewModel.state.durationSeconds, 0);
    });

    test('starts timer only after authoritative Active snapshot with connectedAtUtc', () async {
      final connectedTime = DateTime.now().toUtc().subtract(const Duration(seconds: 5));
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
    });

    test('hangup routes Created/Ringing to /cancel', () async {
      final ringingSnapshot = VoiceCallSnapshotEntity(
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

      repo.endCallResult = ApiErrorResult(
        failure: Failure.fromException(
          DioException(
            requestOptions: RequestOptions(path: '/api/v2/voice-calls/call-1/end'),
            response: Response(
              statusCode: 409,
              requestOptions: RequestOptions(path: '/api/v2/voice-calls/call-1/end'),
            ),
          ),
        ),
      );

      viewModel.doIntent(const EndCallEvent());
      await Future.delayed(Duration.zero);

      expect(repo.endCallCount, 1);
      expect(viewModel.state.status, VoiceCallStatus.ended);
    });
  });
}
