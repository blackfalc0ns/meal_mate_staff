import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/generated/driver_voice_api.g.dart',
    dartTestOut: 'test/test_api.g.dart',
    kotlinOut:
        'android/src/main/kotlin/com/mealmate/driver_voice_engine/DriverVoiceApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.mealmate.driver_voice_engine'),
    swiftOut:
        'ios/driver_voice_engine/Sources/driver_voice_engine/DriverVoiceApi.g.swift',
    swiftOptions: SwiftOptions(),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
enum DriverVoiceCommandStatus {
  success,
  permissionDenied,
  permanentlyDenied,
  busy,
  unauthenticated,
  preparationFailed,
  transportUnavailable,
  ambiguousInitiation,
  serverRejected,
}

enum DriverVoiceServerCallStatus {
  idle,
  created,
  ringing,
  accepted,
  connecting,
  active,
  rejected,
  cancelled,
  missed,
  failed,
  ended,
  busy,
  unknown,
}

enum DriverVoiceMediaState {
  idle,
  preparing,
  connecting,
  connected,
  reconnecting,
  disconnected,
  failed,
}

enum DriverVoiceAudioRoute {
  systemDefault,
  earpiece,
  speaker,
  bluetooth,
  wiredHeadset,
}

enum DriverVoiceInterruptionState {
  none,
  interrupted,
  resuming,
}

enum DriverVoiceTerminationReason {
  none,
  localHangup,
  remoteHangup,
  rejected,
  noAnswer,
  cancelled,
  missed,
  networkFailure,
  authFailure,
  timeout,
  error,
}

class DriverVoiceCommandResult {
  DriverVoiceCommandResult({
    required this.status,
    this.errorMessage,
    this.operationId,
  });

  final DriverVoiceCommandStatus status;
  final String? errorMessage;
  final String? operationId;
}

class DriverVoiceCallDisplayMetadata {
  DriverVoiceCallDisplayMetadata({
    required this.customerName,
    this.orderCode,
    this.deliveryAddress,
    this.deliveryZone,
    this.mealSummary,
  });

  final String customerName;
  final String? orderCode;
  final String? deliveryAddress;
  final String? deliveryZone;
  final String? mealSummary;
}

class DriverVoiceStartOutgoingRequest {
  DriverVoiceStartOutgoingRequest({
    required this.tripStopId,
    required this.clientRequestId,
    this.displayMetadata,
  });

  final String tripStopId;
  final String clientRequestId;
  final DriverVoiceCallDisplayMetadata? displayMetadata;
}

class DriverVoiceCallSnapshot {
  DriverVoiceCallSnapshot({
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
}

class DriverVoiceAccountSession {
  DriverVoiceAccountSession({
    required this.accessToken,
    this.refreshToken,
    required this.userId,
    required this.baseUrl,
    required this.hubUrl,
    required this.installationId,
    this.fcmDeviceTokenId,
    this.apnsVoipToken,
    required this.platform,
  });

  final String accessToken;
  final String? refreshToken;
  final String userId;
  final String baseUrl;
  final String hubUrl;
  final String installationId;
  final String? fcmDeviceTokenId;
  final String? apnsVoipToken;
  final String platform;
}

class DriverVoiceEngineCapabilities {
  DriverVoiceEngineCapabilities({
    required this.supportsTelecom,
    required this.supportsCallKit,
    required this.supportsProximity,
    required this.supportsBluetoothRouting,
  });

  final bool supportsTelecom;
  final bool supportsCallKit;
  final bool supportsProximity;
  final bool supportsBluetoothRouting;
}

@HostApi()
abstract class DriverVoiceHostApi {
  DriverVoiceEngineCapabilities getCapabilities();

  DriverVoiceCallSnapshot? getCurrentCall();

  @async
  DriverVoiceCommandResult startOutgoing(DriverVoiceStartOutgoingRequest request);

  @async
  DriverVoiceCommandResult setMuted(bool muted);

  @async
  DriverVoiceCommandResult selectAudioRoute(DriverVoiceAudioRoute route);

  @async
  DriverVoiceCommandResult hangUp(String? reason);

  @async
  DriverVoiceCommandResult syncAccountSession(DriverVoiceAccountSession session);

  @async
  DriverVoiceCommandResult revokeAccountSession();
}

@FlutterApi()
abstract class DriverVoiceFlutterApi {
  void onSnapshotUpdated(DriverVoiceCallSnapshot snapshot);
  void onCommandAcknowledged(DriverVoiceCommandResult result);
}
