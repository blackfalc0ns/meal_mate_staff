import 'dart:async';

import 'src/generated/driver_voice_api.g.dart';
import 'src/native_driver_voice_engine.dart';

export 'src/generated/driver_voice_api.g.dart'
    show
        DriverVoiceCommandStatus,
        DriverVoiceServerCallStatus,
        DriverVoiceMediaState,
        DriverVoiceAudioRoute,
        DriverVoiceInterruptionState,
        DriverVoiceTerminationReason,
        DriverVoiceCommandResult,
        DriverVoiceCallDisplayMetadata,
        DriverVoiceStartOutgoingRequest,
        DriverVoiceCallSnapshot,
        DriverVoiceAccountSession,
        DriverVoiceEngineCapabilities;

abstract class DriverVoiceEngine {
  Stream<DriverVoiceCallSnapshot> get onSnapshotUpdated;
  Stream<DriverVoiceCommandResult> get onCommandAcknowledged;

  Future<DriverVoiceEngineCapabilities> getCapabilities();
  Future<DriverVoiceCallSnapshot?> getCurrentCall();

  Future<DriverVoiceCommandResult> startOutgoing({
    required String tripStopId,
    required String clientRequestId,
    DriverVoiceCallDisplayMetadata? displayMetadata,
  });

  Future<DriverVoiceCommandResult> setMuted(bool muted);
  Future<DriverVoiceCommandResult> selectAudioRoute(DriverVoiceAudioRoute route);
  Future<DriverVoiceCommandResult> hangUp([String? reason]);

  Future<DriverVoiceCommandResult> syncAccountSession(
    DriverVoiceAccountSession session,
  );
  Future<DriverVoiceCommandResult> revokeAccountSession();

  static DriverVoiceEngine get instance => NativeDriverVoiceEngine.instance;
}
