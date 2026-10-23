import 'package:flutter_test/flutter_test.dart';
import 'package:driver_voice_engine/driver_voice_engine.dart';
import 'package:driver_voice_engine/src/native_driver_voice_engine.dart';

class MockDriverVoiceHostBridge implements DriverVoiceHostBridge {
  DriverVoiceCallSnapshot? currentCallSnapshot;
  DriverVoiceCommandResult commandResult = DriverVoiceCommandResult(
    status: DriverVoiceCommandStatus.success,
  );
  DriverVoiceStartOutgoingRequest? lastStartOutgoingRequest;
  bool? lastMuted;
  DriverVoiceAudioRoute? lastAudioRoute;
  String? lastHangUpReason;
  DriverVoiceAccountSession? lastSyncedSession;
  bool revokeCalled = false;

  @override
  Future<DriverVoiceEngineCapabilities> getCapabilities() async {
    return DriverVoiceEngineCapabilities(
      supportsTelecom: true,
      supportsCallKit: true,
      supportsProximity: true,
      supportsBluetoothRouting: true,
    );
  }

  @override
  Future<DriverVoiceCallSnapshot?> getCurrentCall() async => currentCallSnapshot;

  @override
  Future<DriverVoiceCommandResult> startOutgoing(
    DriverVoiceStartOutgoingRequest request,
  ) async {
    lastStartOutgoingRequest = request;
    return commandResult;
  }

  @override
  Future<DriverVoiceCommandResult> setMuted(bool muted) async {
    lastMuted = muted;
    return commandResult;
  }

  @override
  Future<DriverVoiceCommandResult> selectAudioRoute(
    DriverVoiceAudioRoute route,
  ) async {
    lastAudioRoute = route;
    return commandResult;
  }

  @override
  Future<DriverVoiceCommandResult> hangUp(String? reason) async {
    lastHangUpReason = reason;
    return commandResult;
  }

  @override
  Future<DriverVoiceCommandResult> syncAccountSession(
    DriverVoiceAccountSession session,
  ) async {
    lastSyncedSession = session;
    return commandResult;
  }

  @override
  Future<DriverVoiceCommandResult> revokeAccountSession() async {
    revokeCalled = true;
    return commandResult;
  }
}

DriverVoiceCallSnapshot createSnapshot({
  required String engineInstanceId,
  required int localRevision,
  String? callId = 'call-123',
  DriverVoiceServerCallStatus serverStatus = DriverVoiceServerCallStatus.active,
  DriverVoiceMediaState mediaState = DriverVoiceMediaState.connected,
  bool muted = false,
  DriverVoiceAudioRoute route = DriverVoiceAudioRoute.earpiece,
}) {
  return DriverVoiceCallSnapshot(
    schemaVersion: 1,
    engineInstanceId: engineInstanceId,
    localRevision: localRevision,
    operationId: 'op-1',
    callId: callId,
    tripStopId: 'stop-abc',
    serverSequence: 1,
    generation: 0,
    serverStatus: serverStatus,
    mediaState: mediaState,
    connectedAtUtc: '2026-10-22T20:00:00Z',
    deadlineAtUtc: null,
    muted: muted,
    audioRoute: route,
    availableRoutes: [
      DriverVoiceAudioRoute.earpiece,
      DriverVoiceAudioRoute.speaker,
    ],
    interruptionState: DriverVoiceInterruptionState.none,
    terminationReason: DriverVoiceTerminationReason.none,
    serverEndPending: false,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NativeDriverVoiceEngine', () {
    late MockDriverVoiceHostBridge mockHostBridge;
    late NativeDriverVoiceEngine engine;

    setUp(() {
      mockHostBridge = MockDriverVoiceHostBridge();
      engine = NativeDriverVoiceEngine(hostBridge: mockHostBridge);
    });

    tearDown(() {
      engine.dispose();
    });

    test('getCapabilities returns host capabilities', () async {
      final caps = await engine.getCapabilities();
      expect(caps.supportsTelecom, isTrue);
      expect(caps.supportsCallKit, isTrue);
      expect(caps.supportsProximity, isTrue);
    });

    test('startOutgoing passes parameters through host bridge', () async {
      final res = await engine.startOutgoing(
        tripStopId: 'stop-101',
        clientRequestId: 'req-202',
        displayMetadata: DriverVoiceCallDisplayMetadata(
          customerName: 'Customer Jane',
          orderCode: 'MM-999',
        ),
      );

      expect(res.status, DriverVoiceCommandStatus.success);
      expect(mockHostBridge.lastStartOutgoingRequest?.tripStopId, 'stop-101');
      expect(mockHostBridge.lastStartOutgoingRequest?.clientRequestId, 'req-202');
      expect(
        mockHostBridge.lastStartOutgoingRequest?.displayMetadata?.customerName,
        'Customer Jane',
      );
    });

    test('setMuted, selectAudioRoute, hangUp pass correctly', () async {
      await engine.setMuted(true);
      expect(mockHostBridge.lastMuted, isTrue);

      await engine.selectAudioRoute(DriverVoiceAudioRoute.speaker);
      expect(mockHostBridge.lastAudioRoute, DriverVoiceAudioRoute.speaker);

      await engine.hangUp('driver_cancelled');
      expect(mockHostBridge.lastHangUpReason, 'driver_cancelled');
    });

    test('syncAccountSession and revokeAccountSession pass correctly', () async {
      final session = DriverVoiceAccountSession(
        accessToken: 'jwt-token',
        userId: 'driver-1',
        baseUrl: 'https://maelmate.runasp.net',
        hubUrl: 'https://maelmate.runasp.net/hubs/voice-call-v2',
        installationId: 'install-1',
        platform: 'android',
      );

      await engine.syncAccountSession(session);
      expect(mockHostBridge.lastSyncedSession?.accessToken, 'jwt-token');

      await engine.revokeAccountSession();
      expect(mockHostBridge.revokeCalled, isTrue);
    });

    test('Snapshot revision ordering: drops older revisions from same engine instance', () async {
      final snapshotsEmitted = <DriverVoiceCallSnapshot>[];
      final sub = engine.onSnapshotUpdated.listen(snapshotsEmitted.add);

      final snapRev1 = createSnapshot(engineInstanceId: 'inst-A', localRevision: 1);
      final snapRev3 = createSnapshot(engineInstanceId: 'inst-A', localRevision: 3);
      final snapRev2 = createSnapshot(engineInstanceId: 'inst-A', localRevision: 2); // Older, must be dropped

      engine.handleSnapshotUpdated(snapRev1);
      engine.handleSnapshotUpdated(snapRev3);
      engine.handleSnapshotUpdated(snapRev2);

      await pumpEventQueue();

      expect(snapshotsEmitted.length, 2);
      expect(snapshotsEmitted[0].localRevision, 1);
      expect(snapshotsEmitted[1].localRevision, 3);

      await sub.cancel();
    });

    test('Snapshot engineInstance change resyncs even if localRevision is lower', () async {
      final snapshotsEmitted = <DriverVoiceCallSnapshot>[];
      final sub = engine.onSnapshotUpdated.listen(snapshotsEmitted.add);

      final snapA = createSnapshot(engineInstanceId: 'inst-A', localRevision: 10);
      final snapB = createSnapshot(engineInstanceId: 'inst-B', localRevision: 1); // New engine instance

      engine.handleSnapshotUpdated(snapA);
      engine.handleSnapshotUpdated(snapB);

      await pumpEventQueue();

      expect(snapshotsEmitted.length, 2);
      expect(snapshotsEmitted[0].engineInstanceId, 'inst-A');
      expect(snapshotsEmitted[0].localRevision, 10);
      expect(snapshotsEmitted[1].engineInstanceId, 'inst-B');
      expect(snapshotsEmitted[1].localRevision, 1);

      await sub.cancel();
    });

    test('command acknowledged event is broadcast on onCommandAcknowledged', () async {
      final acksEmitted = <DriverVoiceCommandResult>[];
      final sub = engine.onCommandAcknowledged.listen(acksEmitted.add);

      final ack = DriverVoiceCommandResult(
        status: DriverVoiceCommandStatus.success,
        operationId: 'op-99',
      );

      engine.handleCommandAcknowledged(ack);
      await pumpEventQueue();

      expect(acksEmitted.length, 1);
      expect(acksEmitted.first.operationId, 'op-99');

      await sub.cancel();
    });
  });
}
