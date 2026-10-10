import 'dart:async';
import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/network/api_results.dart';
import '../../../../../core/services/server_clock.dart';
import '../../domain/entities/delivery_contact_case_entity.dart';
import '../../domain/entities/driver_active_call_entity.dart';
import '../../domain/entities/voice_call_snapshot_entity.dart';
import '../../domain/entities/voice_call_status.dart';
import '../../domain/repo/driver_calling_repository.dart';
import '../../domain/usecase/cancel_voice_call_usecase.dart';
import '../../domain/usecase/check_call_eligibility_usecase.dart';
import '../../domain/usecase/end_voice_call_usecase.dart';
import '../../domain/usecase/get_active_voice_call_usecase.dart';
import '../../domain/usecase/get_delivery_contact_case_usecase.dart';
import '../../domain/usecase/get_voice_call_display_usecase.dart';
import '../../domain/usecase/get_voice_call_snapshot_usecase.dart';
import '../../domain/usecase/hold_delivery_contact_case_usecase.dart';
import '../../domain/usecase/initiate_voice_call_usecase.dart';
import '../../domain/usecase/resume_delivery_contact_case_usecase.dart';
import '../../domain/usecase/reveal_customer_phone_usecase.dart';
import 'driver_calling_event.dart';
import 'driver_calling_state.dart';
import '../../../tracking/presentation/manager/driver_live_location_coordinator.dart';

@injectable
class DriverCallingViewModel extends Cubit<DriverCallingState> {
  DriverCallingViewModel({
    required this.checkCallEligibilityUseCase,
    required this.initiateVoiceCallUseCase,
    required this.cancelVoiceCallUseCase,
    required this.endVoiceCallUseCase,
    required this.getActiveVoiceCallUseCase,
    required this.getVoiceCallSnapshotUseCase,
    required this.getDeliveryContactCaseUseCase,
    required this.holdDeliveryContactCaseUseCase,
    required this.resumeDeliveryContactCaseUseCase,
    required this.revealCustomerPhoneUseCase,
    required this.getVoiceCallDisplayUseCase,
    required this.repository,
    ServerClock? serverClock,
    this.locationCoordinator,
  }) : _serverClock = serverClock ?? ServerClock(), super(const DriverCallingState()) {
    _initSubscriptions();
  }

  final CheckCallEligibilityUseCase checkCallEligibilityUseCase;
  final InitiateVoiceCallUseCase initiateVoiceCallUseCase;
  final CancelVoiceCallUseCase cancelVoiceCallUseCase;
  final EndVoiceCallUseCase endVoiceCallUseCase;
  final GetActiveVoiceCallUseCase getActiveVoiceCallUseCase;
  final GetVoiceCallSnapshotUseCase getVoiceCallSnapshotUseCase;
  final GetDeliveryContactCaseUseCase getDeliveryContactCaseUseCase;
  final HoldDeliveryContactCaseUseCase holdDeliveryContactCaseUseCase;
  final ResumeDeliveryContactCaseUseCase resumeDeliveryContactCaseUseCase;
  final RevealCustomerPhoneUseCase revealCustomerPhoneUseCase;
  final GetVoiceCallDisplayUseCase getVoiceCallDisplayUseCase;
  final DriverCallingRepository repository;
  final ServerClock _serverClock;
  final DriverLiveLocationCoordinator? locationCoordinator;

  StreamSubscription? _snapshotSub;
  StreamSubscription? _statusSub;
  Timer? _durationTimer;

  void _initSubscriptions() {
    _snapshotSub = repository.onSnapshotUpdated.listen((snapshot) {
      doIntent(SnapshotUpdatedEvent(snapshot));
    });

    _statusSub = repository.onStatusChanged.listen((status) {
      doIntent(StatusChangedEvent(status));
    });
  }

  void _startDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isClosed) {
        doIntent(const TickCallDurationEvent());
      }
    });
  }

  void _stopDurationTimer() {
    _durationTimer?.cancel();
    _durationTimer = null;
  }

  void doIntent(DriverCallingEvent event) {
    switch (event) {
      case CheckEligibilityEvent(:final tripStopId):
        unawaited(_onCheckEligibility(tripStopId));
      case InitiateCallEvent():
        unawaited(_onInitiateCall(event));
      case CancelCallEvent(:final callId):
        unawaited(_onCancelCall(callId));
      case EndCallEvent(:final callId):
        unawaited(_onEndCall(callId));
      case ToggleMuteEvent():
        unawaited(_onToggleMute());
      case ToggleSpeakerEvent():
        unawaited(_onToggleSpeaker());
      case HoldCallEvent(:final notes):
        unawaited(_onHoldCall(notes));
      case ResumeCallEvent():
        unawaited(_onResumeCall());
      case RevealPhoneEvent(:final reason):
        unawaited(_onRevealPhone(reason));
      case FetchCallDisplayEvent(:final callId, :final languageCode):
        unawaited(_onFetchCallDisplay(callId, languageCode: languageCode));
      case ClearFeedbackEvent():
        _onClearFeedback();
      case SnapshotUpdatedEvent(:final snapshot):
        _onSnapshotUpdated(snapshot);
      case StatusChangedEvent(:final status):
        _onStatusChanged(status);
      case TickCallDurationEvent():
        _onTickDuration();
    }
  }

  Timer? _deadlineTimer;

  void _onSnapshotUpdated(VoiceCallSnapshotEntity snapshot) {
    if (state.snapshot != null &&
        state.snapshot!.callId == snapshot.callId &&
        snapshot.sequence < state.snapshot!.sequence) {
      return;
    }

    if (snapshot.status == VoiceCallStatus.active && snapshot.connectedAtUtc != null) {
      final nowUtc = _serverClock.nowUtcOrLocal;
      final elapsed = nowUtc.difference(snapshot.connectedAtUtc!).inSeconds;
      final initialDuration = max(0, max(snapshot.durationSeconds ?? 0, elapsed));
      emit(state.copyWith(
        snapshot: snapshot,
        status: VoiceCallStatus.active,
        durationSeconds: initialDuration,
      ));
      _startDurationTimer();
      _cancelRingingDeadlineTimer();
    } else if (snapshot.status.isTerminal) {
      _stopDurationTimer();
      _cancelRingingDeadlineTimer();
      emit(state.copyWith(
        snapshot: snapshot,
        status: snapshot.status,
      ));
    } else if (snapshot.status == VoiceCallStatus.ringing || snapshot.status == VoiceCallStatus.created) {
      _stopDurationTimer();
      emit(state.copyWith(
        snapshot: snapshot,
        status: snapshot.status,
        durationSeconds: 0,
      ));
      _scheduleRingingDeadlineReconciliation(snapshot);
    } else {
      _stopDurationTimer();
      emit(state.copyWith(
        snapshot: snapshot,
        status: snapshot.status,
      ));
    }
  }

  void _scheduleRingingDeadlineReconciliation(VoiceCallSnapshotEntity snapshot) {
    _deadlineTimer?.cancel();
    final deadline = snapshot.deadlineAtUtc;
    if (deadline == null) return;
    final delay = deadline.difference(_serverClock.nowUtcOrLocal);
    if (delay.isNegative) {
      unawaited(_reconcileDeadline(snapshot.callId));
    } else {
      _deadlineTimer = Timer(delay, () {
        unawaited(_reconcileDeadline(snapshot.callId));
      });
    }
  }

  void _cancelRingingDeadlineTimer() {
    _deadlineTimer?.cancel();
    _deadlineTimer = null;
  }

  Future<void> _reconcileDeadline(String callId) async {
    if (state.status != VoiceCallStatus.ringing && state.status != VoiceCallStatus.created) {
      return;
    }
    final res = await getVoiceCallSnapshotUseCase(callId);
    if (res is ApiSuccessResult<VoiceCallSnapshotEntity>) {
      _onSnapshotUpdated(res.data);
    }
  }

  void _onStatusChanged(VoiceCallStatus status) {
    if (status.isTerminal) {
      _stopDurationTimer();
      _cancelRingingDeadlineTimer();
    }
    emit(state.copyWith(status: status));
  }

  void _onTickDuration() {
    emit(state.copyWith(durationSeconds: state.durationSeconds + 1));
  }

  void _onClearFeedback() {
    emit(state.copyWith(clearError: true));
  }

  Future<void> _onCheckEligibility(String tripStopId) async {
    emit(state.copyWith(isCheckingEligibility: true, clearError: true));
    final result = await checkCallEligibilityUseCase(tripStopId);

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(state.copyWith(isCheckingEligibility: false, eligibility: data));
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            isCheckingEligibility: false,
            errorMessage: failure.errorMessage,
          ),
        );
    }

    final caseResult = await getDeliveryContactCaseUseCase(tripStopId);
    if (caseResult is ApiSuccessResult<DeliveryContactCaseEntity>) {
      emit(state.copyWith(contactCase: caseResult.data));
    }
  }

  Future<void> _onInitiateCall(InitiateCallEvent event) async {
    if (state.isInitiating) return;

    // Check active call first if retrying with existing request ID
    if (state.lastClientRequestId != null) {
      final activeResult = await getActiveVoiceCallUseCase();
      if (activeResult
          case ApiSuccessResult<VoiceCallSnapshotEntity?>(
            data: final activeSnapshot?,
          )
          when activeSnapshot.tripStopId == event.tripStopId &&
              !activeSnapshot.status.isTerminal) {
        emit(
          state.copyWith(
            snapshot: activeSnapshot,
            status: activeSnapshot.status,
          ),
        );
        unawaited(_onFetchCallDisplay(activeSnapshot.callId));
        return;
      }
    }

    final clientRequestId =
        state.lastClientRequestId ?? _generateClientRequestId();

    emit(
      state.copyWith(
        isInitiating: true,
        lastClientRequestId: clientRequestId,
        status: VoiceCallStatus.created,
        clearError: true,
        activeCallData: DriverActiveCallEntity(
          customerName: event.customerName ?? 'Customer',
          addressLine: event.addressLine ?? '',
          area: event.area ?? '',
          initialDurationSeconds: 0,
        ),
      ),
    );

    // The voice-call endpoint rejects stale driver locations. Obtain and send
    // a fresh measured GPS fix before attempting initiation.
    if (locationCoordinator != null) {
      final locationSent = await locationCoordinator!.sendCurrentLocationNow();
      if (!locationSent) {
        emit(state.copyWith(
          isInitiating: false,
          errorMessage: 'Unable to refresh your location. Please try again.',
          status: VoiceCallStatus.failed,
        ));
        return;
      }
    }

    final result = await initiateVoiceCallUseCase(
      tripStopId: event.tripStopId,
      clientRequestId: clientRequestId,
    );

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            isInitiating: false,
            snapshot: data,
            status: data.status,
            durationSeconds: 0,
          ),
        );
        // Immediately fetch display info in background without delaying signaling/media
        unawaited(_onFetchCallDisplay(data.callId));

      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            isInitiating: false,
            errorMessage: failure.errorMessage,
            status: VoiceCallStatus.failed,
          ),
        );
    }
  }

  Future<void> _onCancelCall(String? callId) async {
    await _handleHangup(callId: callId, forceCancel: true);
  }

  Future<void> _onEndCall(String? callId) async {
    await _handleHangup(callId: callId, forceCancel: false);
  }

  Future<void> _handleHangup({String? callId, bool forceCancel = false}) async {
    final targetId = callId ?? state.snapshot?.callId;
    if (targetId == null) return;

    final currentStatus = state.status;
    if (currentStatus.isTerminal) {
      _stopDurationTimer();
      _cancelRingingDeadlineTimer();
      await repository.cleanupCall();
      return;
    }

    final isCancel = forceCancel ||
        currentStatus == VoiceCallStatus.created ||
        currentStatus == VoiceCallStatus.ringing;

    final result = isCancel
        ? await cancelVoiceCallUseCase(targetId)
        : await endVoiceCallUseCase(targetId);

    switch (result) {
      case ApiSuccessResult():
        _stopDurationTimer();
        _cancelRingingDeadlineTimer();
        emit(state.copyWith(
          status: isCancel ? VoiceCallStatus.cancelled : VoiceCallStatus.ended,
        ));
      case ApiErrorResult(:final failure):
        final statusCode = failure.exception.statusCode;
        if (statusCode == 409) {
          // 409 Conflict: State changed on server, reconcile with authoritative snapshot
          final res = await getVoiceCallSnapshotUseCase(targetId);
          if (res is ApiSuccessResult<VoiceCallSnapshotEntity>) {
            _onSnapshotUpdated(res.data);
            return;
          }
          final activeRes = await getActiveVoiceCallUseCase();
          if (activeRes is ApiSuccessResult<VoiceCallSnapshotEntity?> && activeRes.data != null) {
            _onSnapshotUpdated(activeRes.data!);
            return;
          }
          _stopDurationTimer();
          _cancelRingingDeadlineTimer();
          emit(state.copyWith(status: VoiceCallStatus.ended));
        } else {
          // Surface recoverable failure; do not pretend call ended
          emit(state.copyWith(errorMessage: failure.errorMessage));
        }
    }
  }

  Future<void> _onToggleMute() async {
    final nextMuted = !state.isMuted;
    emit(state.copyWith(isMuted: nextMuted));
    await repository.toggleMute(nextMuted);
  }

  Future<void> _onToggleSpeaker() async {
    final nextSpeaker = !state.isSpeakerOn;
    emit(state.copyWith(isSpeakerOn: nextSpeaker));
    await repository.toggleSpeaker(nextSpeaker);
  }

  Future<void> _onHoldCall(String notes) async {
    final tripStopId =
        state.snapshot?.tripStopId ?? state.contactCase?.tripStopId;
    if (tripStopId == null) return;

    final firstAttemptId =
        state.contactCase?.firstAttemptCallId ?? state.snapshot?.callId ?? '';

    emit(state.copyWith(isHolding: true, clearError: true));
    final result = await holdDeliveryContactCaseUseCase(
      tripStopId: tripStopId,
      notes: notes,
      firstAttemptCallId: firstAttemptId,
    );

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(state.copyWith(isHolding: false, contactCase: data));
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(isHolding: false, errorMessage: failure.errorMessage),
        );
    }
  }

  Future<void> _onResumeCall() async {
    final tripStopId =
        state.contactCase?.tripStopId ?? state.snapshot?.tripStopId;
    if (tripStopId == null) return;

    emit(state.copyWith(isResuming: true, clearError: true));

    double? lat;
    double? lng;
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      lat = pos.latitude;
      lng = pos.longitude;
    } catch (_) {}

    final result = await resumeDeliveryContactCaseUseCase(
      tripStopId: tripStopId,
      lat: lat,
      lng: lng,
    );

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(
          state.copyWith(
            isResuming: false,
            contactCase: data,
            lastClientRequestId: null,
          ),
        );
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(isResuming: false, errorMessage: failure.errorMessage),
        );
    }
  }

  Future<void> _onRevealPhone(String reason) async {
    final tripStopId =
        state.contactCase?.tripStopId ?? state.snapshot?.tripStopId;
    if (tripStopId == null) return;

    final reqId = _generateClientRequestId();
    emit(state.copyWith(isRevealingPhone: true, clearError: true));

    final result = await revealCustomerPhoneUseCase(
      tripStopId: tripStopId,
      clientRequestId: reqId,
      reason: reason,
    );

    switch (result) {
      case ApiSuccessResult(:final data):
        emit(state.copyWith(isRevealingPhone: false, phoneGrant: data));
        final phone = data.customerPhone.trim();
        if (phone.isNotEmpty) {
          final uri = Uri.parse('tel:$phone');
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
      case ApiErrorResult(:final failure):
        emit(
          state.copyWith(
            isRevealingPhone: false,
            errorMessage: failure.errorMessage,
          ),
        );
    }
  }

  Future<void> _onFetchCallDisplay(
    String callId, {
    String? languageCode,
  }) async {
    emit(state.copyWith(isLoadingDisplay: true));

    final result = await getVoiceCallDisplayUseCase(
      callId,
      languageCode: languageCode,
    );

    switch (result) {
      case ApiSuccessResult(:final data):
        // Ensure this display belongs to the active call before applying
        if (state.snapshot?.callId == null ||
            state.snapshot?.callId == callId) {
          emit(state.copyWith(displayData: data, isLoadingDisplay: false));
        }
      case ApiErrorResult():
        // Display failure does NOT abort the ongoing call
        emit(state.copyWith(isLoadingDisplay: false));
    }
  }

  String _generateClientRequestId() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  @override
  Future<void> close() async {
    _durationTimer?.cancel();
    _deadlineTimer?.cancel();
    await _snapshotSub?.cancel();
    await _statusSub?.cancel();
    return super.close();
  }
}
