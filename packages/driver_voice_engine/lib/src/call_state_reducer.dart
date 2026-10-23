import 'generated/driver_voice_api.g.dart';

class CallStateSnapshot {
  const CallStateSnapshot({
    required this.schemaVersion,
    required this.engineInstanceId,
    required this.localRevision,
    required this.operationId,
    this.callId,
    required this.tripStopId,
    required this.serverSequence,
    required this.generation,
    required this.serverStatus,
    required this.mediaState,
    this.connectedAtUtc,
    this.deadlineAtUtc,
    required this.muted,
    required this.audioRoute,
    required this.availableRoutes,
    required this.interruptionState,
    required this.terminationReason,
    required this.serverEndPending,
  });

  final int schemaVersion;
  final String engineInstanceId;
  final int localRevision;
  final String operationId;
  final String? callId;
  final String tripStopId;
  final int serverSequence;
  final int generation;
  final DriverVoiceServerCallStatus serverStatus;
  final DriverVoiceMediaState mediaState;
  final String? connectedAtUtc;
  final String? deadlineAtUtc;
  final bool muted;
  final DriverVoiceAudioRoute audioRoute;
  final List<DriverVoiceAudioRoute> availableRoutes;
  final DriverVoiceInterruptionState interruptionState;
  final DriverVoiceTerminationReason terminationReason;
  final bool serverEndPending;

  bool get isTerminal =>
      serverStatus == DriverVoiceServerCallStatus.ended ||
      serverStatus == DriverVoiceServerCallStatus.cancelled ||
      serverStatus == DriverVoiceServerCallStatus.rejected ||
      serverStatus == DriverVoiceServerCallStatus.missed ||
      serverStatus == DriverVoiceServerCallStatus.failed ||
      serverStatus == DriverVoiceServerCallStatus.busy ||
      terminationReason != DriverVoiceTerminationReason.none;

  CallStateSnapshot copyWith({
    int? schemaVersion,
    String? engineInstanceId,
    int? localRevision,
    String? operationId,
    String? callId,
    String? tripStopId,
    int? serverSequence,
    int? generation,
    DriverVoiceServerCallStatus? serverStatus,
    DriverVoiceMediaState? mediaState,
    String? connectedAtUtc,
    String? deadlineAtUtc,
    bool? muted,
    DriverVoiceAudioRoute? audioRoute,
    List<DriverVoiceAudioRoute>? availableRoutes,
    DriverVoiceInterruptionState? interruptionState,
    DriverVoiceTerminationReason? terminationReason,
    bool? serverEndPending,
  }) {
    return CallStateSnapshot(
      schemaVersion: schemaVersion ?? this.schemaVersion,
      engineInstanceId: engineInstanceId ?? this.engineInstanceId,
      localRevision: localRevision ?? this.localRevision,
      operationId: operationId ?? this.operationId,
      callId: callId ?? this.callId,
      tripStopId: tripStopId ?? this.tripStopId,
      serverSequence: serverSequence ?? this.serverSequence,
      generation: generation ?? this.generation,
      serverStatus: serverStatus ?? this.serverStatus,
      mediaState: mediaState ?? this.mediaState,
      connectedAtUtc: connectedAtUtc ?? this.connectedAtUtc,
      deadlineAtUtc: deadlineAtUtc ?? this.deadlineAtUtc,
      muted: muted ?? this.muted,
      audioRoute: audioRoute ?? this.audioRoute,
      availableRoutes: availableRoutes ?? this.availableRoutes,
      interruptionState: interruptionState ?? this.interruptionState,
      terminationReason: terminationReason ?? this.terminationReason,
      serverEndPending: serverEndPending ?? this.serverEndPending,
    );
  }

  DriverVoiceCallSnapshot toPigeonSnapshot() {
    return DriverVoiceCallSnapshot(
      schemaVersion: schemaVersion,
      engineInstanceId: engineInstanceId,
      localRevision: localRevision,
      operationId: operationId,
      callId: callId,
      tripStopId: tripStopId,
      serverSequence: serverSequence,
      generation: generation,
      serverStatus: serverStatus,
      mediaState: mediaState,
      connectedAtUtc: connectedAtUtc,
      deadlineAtUtc: deadlineAtUtc,
      muted: muted,
      audioRoute: audioRoute,
      availableRoutes: availableRoutes,
      interruptionState: interruptionState,
      terminationReason: terminationReason,
      serverEndPending: serverEndPending,
    );
  }
}

class CallStateReducer {
  CallStateReducer({required this.engineInstanceId});

  final String engineInstanceId;
  final Set<String> _processedEventIds = {};
  int _currentRevision = 0;

  CallStateSnapshot createInitial({
    required String operationId,
    required String tripStopId,
    String? callId,
  }) {
    _currentRevision++;
    return CallStateSnapshot(
      schemaVersion: 1,
      engineInstanceId: engineInstanceId,
      localRevision: _currentRevision,
      operationId: operationId,
      callId: callId,
      tripStopId: tripStopId,
      serverSequence: 0,
      generation: 0,
      serverStatus: DriverVoiceServerCallStatus.created,
      mediaState: DriverVoiceMediaState.preparing,
      connectedAtUtc: null,
      deadlineAtUtc: null,
      muted: false,
      audioRoute: DriverVoiceAudioRoute.earpiece,
      availableRoutes: [
        DriverVoiceAudioRoute.earpiece,
        DriverVoiceAudioRoute.speaker,
      ],
      interruptionState: DriverVoiceInterruptionState.none,
      terminationReason: DriverVoiceTerminationReason.none,
      serverEndPending: false,
    );
  }

  CallStateSnapshot? onServerEvent({
    required CallStateSnapshot current,
    required String eventId,
    required int sequence,
    required DriverVoiceServerCallStatus newStatus,
    String? connectedAtUtc,
    String? deadlineAtUtc,
  }) {
    // 1. Deduplication by eventId
    if (eventId.isNotEmpty) {
      if (_processedEventIds.contains(eventId)) {
        return null; // duplicate event dropped
      }
      _processedEventIds.add(eventId);
    }

    // 2. Terminal state guard: If already terminal, reject non-terminal server events
    if (current.isTerminal && !_isStatusTerminal(newStatus)) {
      return null;
    }

    // 3. Monotonic sequence check
    if (sequence > 0 && sequence <= current.serverSequence) {
      // Out of order or stale event dropped
      return null;
    }

    _currentRevision++;

    var updatedMediaState = current.mediaState;
    var updatedTerminationReason = current.terminationReason;
    var serverEndPending = current.serverEndPending;

    if (newStatus == DriverVoiceServerCallStatus.active) {
      if (current.mediaState == DriverVoiceMediaState.connecting ||
          current.mediaState == DriverVoiceMediaState.preparing) {
        updatedMediaState = DriverVoiceMediaState.connected;
      }
    } else if (_isStatusTerminal(newStatus)) {
      updatedMediaState = DriverVoiceMediaState.disconnected;
      serverEndPending = false;
      if (updatedTerminationReason == DriverVoiceTerminationReason.none) {
        updatedTerminationReason = _mapStatusToTerminationReason(newStatus);
      }
    }

    return current.copyWith(
      localRevision: _currentRevision,
      serverSequence: sequence > 0 ? sequence : current.serverSequence,
      serverStatus: newStatus,
      mediaState: updatedMediaState,
      connectedAtUtc: connectedAtUtc ?? current.connectedAtUtc,
      deadlineAtUtc: deadlineAtUtc ?? current.deadlineAtUtc,
      terminationReason: updatedTerminationReason,
      serverEndPending: serverEndPending,
    );
  }

  CallStateSnapshot? onRemoteAnswer({
    required CallStateSnapshot current,
    required int generation,
  }) {
    if (current.isTerminal) return null;
    if (generation < current.generation) {
      // Discard old-generation answer
      return null;
    }

    _currentRevision++;
    return current.copyWith(
      localRevision: _currentRevision,
      generation: generation,
      mediaState: DriverVoiceMediaState.connecting,
    );
  }

  bool isIceCandidateAllowed({
    required CallStateSnapshot current,
    required int generation,
  }) {
    if (current.isTerminal) return false;
    if (generation < current.generation) return false;
    return true;
  }

  CallStateSnapshot onUserHangUp({
    required CallStateSnapshot current,
    DriverVoiceTerminationReason reason = DriverVoiceTerminationReason.localHangup,
  }) {
    // Idempotent: if already terminal, return unchanged
    if (current.isTerminal && current.terminationReason != DriverVoiceTerminationReason.none) {
      return current;
    }

    _currentRevision++;
    return current.copyWith(
      localRevision: _currentRevision,
      mediaState: DriverVoiceMediaState.disconnected,
      terminationReason: reason,
      serverEndPending: true,
      serverStatus: current.serverStatus == DriverVoiceServerCallStatus.created ||
              current.serverStatus == DriverVoiceServerCallStatus.ringing
          ? DriverVoiceServerCallStatus.cancelled
          : DriverVoiceServerCallStatus.ended,
    );
  }

  CallStateSnapshot onServerEndAcknowledged({
    required CallStateSnapshot current,
  }) {
    _currentRevision++;
    return current.copyWith(
      localRevision: _currentRevision,
      serverEndPending: false,
    );
  }

  CallStateSnapshot onMuteChanged({
    required CallStateSnapshot current,
    required bool muted,
  }) {
    if (current.muted == muted) return current;
    _currentRevision++;
    return current.copyWith(
      localRevision: _currentRevision,
      muted: muted,
    );
  }

  CallStateSnapshot onAudioRouteChanged({
    required CallStateSnapshot current,
    required DriverVoiceAudioRoute route,
    List<DriverVoiceAudioRoute>? availableRoutes,
  }) {
    if (current.audioRoute == route && availableRoutes == null) return current;
    _currentRevision++;
    return current.copyWith(
      localRevision: _currentRevision,
      audioRoute: route,
      availableRoutes: availableRoutes ?? current.availableRoutes,
    );
  }

  static bool _isStatusTerminal(DriverVoiceServerCallStatus status) {
    return status == DriverVoiceServerCallStatus.ended ||
        status == DriverVoiceServerCallStatus.cancelled ||
        status == DriverVoiceServerCallStatus.rejected ||
        status == DriverVoiceServerCallStatus.missed ||
        status == DriverVoiceServerCallStatus.failed ||
        status == DriverVoiceServerCallStatus.busy;
  }

  static DriverVoiceTerminationReason _mapStatusToTerminationReason(
    DriverVoiceServerCallStatus status,
  ) {
    switch (status) {
      case DriverVoiceServerCallStatus.cancelled:
        return DriverVoiceTerminationReason.cancelled;
      case DriverVoiceServerCallStatus.rejected:
        return DriverVoiceTerminationReason.rejected;
      case DriverVoiceServerCallStatus.missed:
        return DriverVoiceTerminationReason.missed;
      case DriverVoiceServerCallStatus.ended:
        return DriverVoiceTerminationReason.remoteHangup;
      case DriverVoiceServerCallStatus.failed:
        return DriverVoiceTerminationReason.networkFailure;
      default:
        return DriverVoiceTerminationReason.none;
    }
  }
}
