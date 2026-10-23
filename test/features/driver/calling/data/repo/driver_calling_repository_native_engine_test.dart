import 'dart:async';

import 'package:driver_voice_engine/driver_voice_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/services/server_clock.dart';
import 'package:meal_mate_delivery/core/services/token_service.dart';
import 'package:meal_mate_delivery/core/services/voice_device_session_storage.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/callkit/driver_callkit_coordinator.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/data_source/driver_calling_remote_data_source.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/realtime/driver_voice_call_signalr_client.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/repo/driver_calling_repository_impl.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/webrtc/driver_webrtc_manager.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/voice_call_status.dart';

class FakeVoiceEngine implements DriverVoiceEngine {
  // ignore: close_sinks
  final _snapshotCtrl = StreamController<DriverVoiceCallSnapshot>.broadcast();
  // ignore: close_sinks
  final _cmdCtrl = StreamController<DriverVoiceCommandResult>.broadcast();

  DriverVoiceCallSnapshot? currentSnapshot;
  DriverVoiceAccountSession? lastSyncedSession;
  bool sessionRevoked = false;
  String? lastStartTripStopId;
  String? lastStartClientRequestId;
  bool? lastMutedValue;
  DriverVoiceAudioRoute? lastSelectedRoute;
  String? lastHangUpReason;

  DriverVoiceCommandStatus startOutgoingStatus =
      DriverVoiceCommandStatus.success;
  String? startOutgoingError;

  @override
  Stream<DriverVoiceCallSnapshot> get onSnapshotUpdated => _snapshotCtrl.stream;

  @override
  Stream<DriverVoiceCommandResult> get onCommandAcknowledged => _cmdCtrl.stream;

  void emitSnapshot(DriverVoiceCallSnapshot snapshot) {
    currentSnapshot = snapshot;
    _snapshotCtrl.add(snapshot);
  }

  @override
  Future<DriverVoiceEngineCapabilities> getCapabilities() async {
    return DriverVoiceEngineCapabilities(
      supportsTelecom: true,
      supportsCallKit: false,
      supportsProximity: true,
      supportsBluetoothRouting: true,
    );
  }

  @override
  Future<DriverVoiceCallSnapshot?> getCurrentCall() async => currentSnapshot;

  @override
  Future<DriverVoiceCommandResult> startOutgoing({
    required String tripStopId,
    required String clientRequestId,
    DriverVoiceCallDisplayMetadata? displayMetadata,
  }) async {
    lastStartTripStopId = tripStopId;
    lastStartClientRequestId = clientRequestId;

    if (startOutgoingStatus != DriverVoiceCommandStatus.success) {
      return DriverVoiceCommandResult(
        operationId: 'op-err',
        status: startOutgoingStatus,
        errorMessage: startOutgoingError ?? 'Native initiation failed',
      );
    }

    currentSnapshot = DriverVoiceCallSnapshot(
      schemaVersion: 2,
      engineInstanceId: 'inst-1',
      localRevision: 1,
      operationId: 'op-1',
      callId: 'call-native-1',
      tripStopId: tripStopId,
      serverSequence: 1,
      generation: 1,
      serverStatus: DriverVoiceServerCallStatus.created,
      mediaState: DriverVoiceMediaState.idle,
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

    return DriverVoiceCommandResult(
      operationId: 'op-1',
      status: DriverVoiceCommandStatus.success,
    );
  }

  @override
  Future<DriverVoiceCommandResult> setMuted(bool muted) async {
    lastMutedValue = muted;
    return DriverVoiceCommandResult(
      operationId: 'op-mute',
      status: DriverVoiceCommandStatus.success,
    );
  }

  @override
  Future<DriverVoiceCommandResult> selectAudioRoute(
    DriverVoiceAudioRoute route,
  ) async {
    lastSelectedRoute = route;
    return DriverVoiceCommandResult(
      operationId: 'op-route',
      status: DriverVoiceCommandStatus.success,
    );
  }

  @override
  Future<DriverVoiceCommandResult> hangUp([String? reason]) async {
    lastHangUpReason = reason;
    return DriverVoiceCommandResult(
      operationId: 'op-hangup',
      status: DriverVoiceCommandStatus.success,
    );
  }

  @override
  Future<DriverVoiceCommandResult> syncAccountSession(
    DriverVoiceAccountSession session,
  ) async {
    lastSyncedSession = session;
    return DriverVoiceCommandResult(
      operationId: 'op-sync',
      status: DriverVoiceCommandStatus.success,
    );
  }

  @override
  Future<DriverVoiceCommandResult> revokeAccountSession() async {
    sessionRevoked = true;
    return DriverVoiceCommandResult(
      operationId: 'op-revoke',
      status: DriverVoiceCommandStatus.success,
    );
  }
}

class FakeRemoteDataSource implements DriverCallingRemoteDataSource {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSignalRClient implements DriverVoiceCallSignalRClient {
  bool didConnect = false;
  bool didDisconnect = false;

  @override
  Future<void> connect() async => didConnect = true;

  @override
  Future<void> disconnect() async => didDisconnect = true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeWebRtcManager implements DriverWebRtcManager {
  bool offerStarted = false;

  @override
  Future<void> startOfferSession({
    required String callId,
    required List<dynamic> iceServers,
    int generation = 0,
  }) async {
    offerStarted = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCallKitCoordinator implements DriverCallKitCoordinator {
  bool initialized = false;

  @override
  void initialize() {
    initialized = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSessionStorage implements VoiceDeviceSessionStorage {
  @override
  bool isSessionValid() => true;

  @override
  String? getDeviceSessionId() => 'session-123';

  @override
  Future<String?> getControlProof() async => 'proof-456';

  @override
  String? getFcmDeviceTokenId() => 'fcm-token-789';

  @override
  String getOrCreateInstallationId(String fallback) => 'install-id-123';

  @override
  Future<void> clearSession() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTokenService implements TokenService {
  @override
  Future<String?> getToken() async => 'jwt-test-token';

  @override
  Future<String?> getRefreshToken() async => 'refresh-test-token';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late DriverCallingRepositoryImpl repository;
  late FakeVoiceEngine fakeEngine;
  late FakeRemoteDataSource fakeRemote;
  late FakeSignalRClient fakeSignalR;
  late FakeWebRtcManager fakeWebRtc;
  late FakeCallKitCoordinator fakeCallKit;
  late FakeSessionStorage fakeStorage;
  late FakeTokenService fakeTokenService;

  setUp(() {
    fakeEngine = FakeVoiceEngine();
    fakeRemote = FakeRemoteDataSource();
    fakeSignalR = FakeSignalRClient();
    fakeWebRtc = FakeWebRtcManager();
    fakeCallKit = FakeCallKitCoordinator();
    fakeStorage = FakeSessionStorage();
    fakeTokenService = FakeTokenService();

    repository = DriverCallingRepositoryImpl(
      remoteDataSource: fakeRemote,
      signalRClient: fakeSignalR,
      webrtcManager: fakeWebRtc,
      callKitCoordinator: fakeCallKit,
      sessionStorage: fakeStorage,
      tokenService: fakeTokenService,
      driverVoiceEngine: fakeEngine,
      useNativeEngine: true,
      serverClock: ServerClock(),
    );
  });

  group('DriverCallingRepositoryImpl with Native Engine', () {
    test('does NOT initialize legacy CallKit when useNativeEngine is true', () {
      expect(fakeCallKit.initialized, isFalse);
    });

    test('initiateCall syncs account session and starts native call', () async {
      final result = await repository.initiateCall(
        tripStopId: 'stop-42',
        clientRequestId: 'req-42',
      );

      expect(result, isA<ApiSuccessResult>());
      final snapshot = (result as ApiSuccessResult).data;
      expect(snapshot.callId, 'call-native-1');
      expect(snapshot.tripStopId, 'stop-42');
      expect(snapshot.status, VoiceCallStatus.created);

      // Verify token & session sync
      expect(fakeEngine.lastSyncedSession, isNotNull);
      expect(fakeEngine.lastSyncedSession!.accessToken, 'jwt-test-token');
      expect(fakeEngine.lastSyncedSession!.refreshToken, 'refresh-test-token');
      expect(
        fakeEngine.lastSyncedSession!.fcmDeviceTokenId,
        'fcm-token-789',
      );
      expect(
        fakeEngine.lastSyncedSession!.installationId,
        'install-id-123',
      );

      // Verify single owner: Dart WebRTC & Dart SignalR did NOT start
      expect(fakeWebRtc.offerStarted, isFalse);
      expect(fakeSignalR.didConnect, isFalse);
    });

    test('initiateCall reports error when native startOutgoing fails', () async {
      fakeEngine.startOutgoingStatus =
          DriverVoiceCommandStatus.preparationFailed;
      fakeEngine.startOutgoingError = 'Simulated native error';

      final result = await repository.initiateCall(
        tripStopId: 'stop-err',
        clientRequestId: 'req-err',
      );

      expect(result, isA<ApiErrorResult>());
    });

    test('toggleMute delegates directly to DriverVoiceEngine', () async {
      await repository.toggleMute(true);
      expect(fakeEngine.lastMutedValue, isTrue);

      await repository.toggleMute(false);
      expect(fakeEngine.lastMutedValue, isFalse);
    });

    test('toggleSpeaker delegates route selection to DriverVoiceEngine', () async {
      await repository.toggleSpeaker(true);
      expect(fakeEngine.lastSelectedRoute, DriverVoiceAudioRoute.speaker);

      await repository.toggleSpeaker(false);
      expect(fakeEngine.lastSelectedRoute, DriverVoiceAudioRoute.earpiece);
    });

    test('cancelCall delegates hangUp("cancelled") to DriverVoiceEngine', () async {
      final result = await repository.cancelCall('call-native-1');
      expect(result, isA<ApiSuccessResult>());
      expect(fakeEngine.lastHangUpReason, 'cancelled');
    });

    test('endCall delegates hangUp("ended") to DriverVoiceEngine', () async {
      final result = await repository.endCall('call-native-1');
      expect(result, isA<ApiSuccessResult>());
      expect(fakeEngine.lastHangUpReason, 'ended');
    });

    test('cleanupCall delegates hangUp("cleanup") to DriverVoiceEngine', () async {
      await repository.cleanupCall('call-native-1');
      expect(fakeEngine.lastHangUpReason, 'cleanup');
    });

    test('revokeVoiceDevice revokes account session on DriverVoiceEngine', () async {
      await repository.revokeVoiceDevice();
      expect(fakeEngine.sessionRevoked, isTrue);
    });

    test('onSnapshotUpdated emits mapped entity and preserves monotonic sequence', () async {
      final snapshots = <dynamic>[];
      final statuses = <VoiceCallStatus>[];

      repository.onSnapshotUpdated.listen(snapshots.add);
      repository.onStatusChanged.listen(statuses.add);

      // Emit Ringing snapshot
      fakeEngine.emitSnapshot(
        DriverVoiceCallSnapshot(
          schemaVersion: 2,
          engineInstanceId: 'inst-1',
          localRevision: 2,
          operationId: 'op-1',
          callId: 'call-native-1',
          tripStopId: 'stop-42',
          serverSequence: 2,
          generation: 1,
          serverStatus: DriverVoiceServerCallStatus.ringing,
          mediaState: DriverVoiceMediaState.idle,
          muted: false,
          audioRoute: DriverVoiceAudioRoute.earpiece,
          availableRoutes: [DriverVoiceAudioRoute.earpiece],
          interruptionState: DriverVoiceInterruptionState.none,
          terminationReason: DriverVoiceTerminationReason.none,
          serverEndPending: false,
        ),
      );

      await pumpEventQueue();
      expect(snapshots.length, 1);
      expect(statuses.last, VoiceCallStatus.ringing);

      // Emit Active snapshot
      fakeEngine.emitSnapshot(
        DriverVoiceCallSnapshot(
          schemaVersion: 2,
          engineInstanceId: 'inst-1',
          localRevision: 3,
          operationId: 'op-1',
          callId: 'call-native-1',
          tripStopId: 'stop-42',
          serverSequence: 3,
          generation: 1,
          serverStatus: DriverVoiceServerCallStatus.active,
          mediaState: DriverVoiceMediaState.connected,
          connectedAtUtc: '2026-10-22T20:00:00Z',
          muted: false,
          audioRoute: DriverVoiceAudioRoute.earpiece,
          availableRoutes: [DriverVoiceAudioRoute.earpiece],
          interruptionState: DriverVoiceInterruptionState.none,
          terminationReason: DriverVoiceTerminationReason.none,
          serverEndPending: false,
        ),
      );

      await pumpEventQueue();
      expect(snapshots.length, 2);
      expect(statuses.last, VoiceCallStatus.active);

      // Verify single owner: Dart WebRTC offer was NEVER started by Dart
      expect(fakeWebRtc.offerStarted, isFalse);
    });
  });
}
