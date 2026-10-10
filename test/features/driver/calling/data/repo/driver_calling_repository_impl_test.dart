import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/services/voice_device_session_storage.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/callkit/driver_callkit_coordinator.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/data_source/driver_calling_remote_data_source.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/models/realtime/voice_call_envelope_dto.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/models/response/ice_servers_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/models/response/voice_call_snapshot_response_dto.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/realtime/driver_voice_call_signalr_client.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/repo/driver_calling_repository_impl.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/webrtc/driver_webrtc_manager.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/ice_server_config_entity.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/voice_call_status.dart';

class FakeTimer implements Timer {
  FakeTimer(this.duration, this.callback);

  final Duration duration;
  final void Function(Timer timer) callback;
  bool isCancelled = false;

  void fire() {
    if (!isCancelled) {
      callback(this);
    }
  }

  @override
  void cancel() {
    isCancelled = true;
  }

  @override
  bool get isActive => !isCancelled;

  @override
  int get tick => 1;
}

class FakeRemoteDataSource implements DriverCallingRemoteDataSource {
  final List<String> heartbeatCalls = [];
  Completer<void>? heartbeatCompleter;

  @override
  Future<void> sendHeartbeat(String callId) async {
    heartbeatCalls.add(callId);
    if (heartbeatCompleter != null) {
      await heartbeatCompleter!.future;
    }
  }

  final List<String> cancelledCalls = [];
  final List<String> endedCalls = [];
  VoiceCallSnapshotResponseDto? snapshotToReturn;
  int reportConnectingCalls = 0;
  int reportConnectedCalls = 0;
  bool failNextConnecting = false;

  @override
  Future<void> cancelCall(String callId) async {
    cancelledCalls.add(callId);
  }

  @override
  Future<void> endCall(String callId) async {
    endedCalls.add(callId);
  }

  @override
  Future<VoiceCallSnapshotResponseDto> getCallSnapshot(String callId) async {
    return snapshotToReturn ??
        VoiceCallSnapshotResponseDto(
          callId: callId,
          tripStopId: 'trip-1',
          protocolVersion: 2,
          sequence: 1,
          status: 'Accepted',
        );
  }

  @override
  Future<VoiceCallSnapshotResponseDto?> getActiveCall() async => snapshotToReturn;

  @override
  Future<IceServersResponseDto> getIceServers(String callId) async {
    return const IceServersResponseDto(
      iceServers: [
        IceServerDto(urls: ['stun:stun.l.google.com:19302']),
      ],
    );
  }

  @override
  Future<void> reportConnecting(String callId) async {
    reportConnectingCalls++;
    if (failNextConnecting) {
      failNextConnecting = false;
      throw Exception('Network error');
    }
  }

  @override
  Future<void> reportConnected(String callId) async {
    reportConnectedCalls++;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSignalRClient implements DriverVoiceCallSignalRClient {
  final _envelopeController = StreamController<VoiceCallEnvelopeDto>.broadcast();

  @override
  Stream<VoiceCallEnvelopeDto> get onEnvelopeReceived => _envelopeController.stream;

  @override
  VoidCallback? onReconnected;

  void emitEnvelope(VoiceCallEnvelopeDto dto) {
    _envelopeController.add(dto);
  }

  @override
  void resetSequenceAndDedupe() {}

  @override
  Future<void> disconnect() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeWebRtcManager implements DriverWebRtcManager {
  // ignore: close_sinks
  final _mediaStateController = StreamController<VoiceCallStatus>.broadcast();
  // ignore: close_sinks
  final _localMediaController = StreamController<bool>.broadcast();
  int startOfferSessionCount = 0;
  final List<String> startedCallIds = [];

  @override
  Stream<VoiceCallStatus> get onMediaStateChanged => _mediaStateController.stream;

  @override
  Stream<bool> get onLocalMediaConnected => _localMediaController.stream;

  void triggerLocalMediaConnected(bool connected) {
    _localMediaController.add(connected);
  }

  @override
  Future<void> startOfferSession({
    required String callId,
    required List<IceServerConfigEntity> iceServers,
    int generation = 0,
  }) async {
    startOfferSessionCount++;
    startedCallIds.add(callId);
  }

  @override
  Future<void> cleanup() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeCallKitCoordinator implements DriverCallKitCoordinator {
  final _actionController = StreamController<String>.broadcast();
  final List<Map<String, dynamic>> startedCalls = [];
  final List<String?> endedCalls = [];
  final List<String> connectedCalls = [];

  @override
  Stream<String> get onCallKitAction => _actionController.stream;

  void triggerAction(String action) {
    _actionController.add(action);
  }

  @override
  void initialize() {}

  @override
  Future<void> startOutgoingCall({
    required String callId,
    required String customerName,
    required Duration ringTimeout,
    String? handle,
  }) async {
    startedCalls.add({
      'callId': callId,
      'customerName': customerName,
      'ringTimeout': ringTimeout,
      'handle': handle,
    });
  }

  @override
  Future<void> setCallConnected(String callId) async {
    connectedCalls.add(callId);
  }

  @override
  Future<void> endCall(String? callId) async {
    endedCalls.add(callId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSessionStorage implements VoiceDeviceSessionStorage {
  @override
  bool isSessionValid() => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeRemoteDataSource fakeRemote;
  late FakeSignalRClient fakeSignalR;
  late FakeWebRtcManager fakeWebRtc;
  late FakeCallKitCoordinator fakeCallKit;
  late FakeSessionStorage fakeStorage;
  late List<FakeTimer> createdTimers;
  late DriverCallingRepositoryImpl repository;

  setUp(() {
    fakeRemote = FakeRemoteDataSource();
    fakeSignalR = FakeSignalRClient();
    fakeWebRtc = FakeWebRtcManager();
    fakeCallKit = FakeCallKitCoordinator();
    fakeStorage = FakeSessionStorage();
    createdTimers = [];

    repository = DriverCallingRepositoryImpl(
      remoteDataSource: fakeRemote,
      signalRClient: fakeSignalR,
      webrtcManager: fakeWebRtc,
      callKitCoordinator: fakeCallKit,
      sessionStorage: fakeStorage,
      heartbeatTimerFactory: (duration, callback) {
        final t = FakeTimer(duration, callback);
        createdTimers.add(t);
        return t;
      },
    );
  });

  group('DriverCallingRepositoryImpl Heartbeat Tests', () {
    test('starts 10s heartbeat timer on accepted snapshot', () async {
      fakeSignalR.emitEnvelope(
        const VoiceCallEnvelopeDto(
          protocolVersion: 2,
          occurredAtUtc: '2026-10-10T07:30:00Z',
          eventId: 'ev-1',
          callId: 'call-100',
          sequence: 1,
          eventType: 'StatusChanged',
          payload: {
            'callId': 'call-100',
            'status': 'Accepted',
            'sequence': 1,
          },
        ),
      );

      await Future.delayed(Duration.zero);
      expect(createdTimers.length, 1);
      expect(createdTimers.first.duration, const Duration(seconds: 10));

      // Tick fires
      createdTimers.first.fire();
      await Future.delayed(Duration.zero);
      expect(fakeRemote.heartbeatCalls, ['call-100']);
    });

    test('duplicate snapshot does not create second heartbeat timer', () async {
      fakeSignalR.emitEnvelope(
        const VoiceCallEnvelopeDto(
          protocolVersion: 2,
          occurredAtUtc: '2026-10-10T07:30:00Z',
          eventId: 'ev-1',
          callId: 'call-100',
          sequence: 1,
          eventType: 'StatusChanged',
          payload: {
            'callId': 'call-100',
            'status': 'Accepted',
            'sequence': 1,
          },
        ),
      );
      await Future.delayed(Duration.zero);

      fakeSignalR.emitEnvelope(
        const VoiceCallEnvelopeDto(
          protocolVersion: 2,
          occurredAtUtc: '2026-10-10T07:30:00Z',
          eventId: 'ev-2',
          callId: 'call-100',
          sequence: 2,
          eventType: 'StatusChanged',
          payload: {
            'callId': 'call-100',
            'status': 'Accepted',
            'sequence': 2,
          },
        ),
      );
      await Future.delayed(Duration.zero);

      expect(createdTimers.length, 1);
    });

    test('skips tick when previous heartbeat request is still in flight', () async {
      fakeSignalR.emitEnvelope(
        const VoiceCallEnvelopeDto(
          protocolVersion: 2,
          occurredAtUtc: '2026-10-10T07:30:00Z',
          eventId: 'ev-1',
          callId: 'call-100',
          sequence: 1,
          eventType: 'StatusChanged',
          payload: {
            'callId': 'call-100',
            'status': 'Accepted',
            'sequence': 1,
          },
        ),
      );
      await Future.delayed(Duration.zero);

      fakeRemote.heartbeatCompleter = Completer<void>();
      createdTimers.first.fire(); // Start request 1 (in-flight)

      // Fire second tick while request 1 is still in flight
      createdTimers.first.fire();
      expect(fakeRemote.heartbeatCalls.length, 1);

      // Finish request 1
      fakeRemote.heartbeatCompleter!.complete();
      await Future.delayed(Duration.zero);

      // Fire third tick after request 1 finished
      fakeRemote.heartbeatCompleter = null;
      createdTimers.first.fire();
      await Future.delayed(Duration.zero);
      expect(fakeRemote.heartbeatCalls.length, 2);
    });

    test('cleanupCall stops heartbeat timer', () async {
      fakeSignalR.emitEnvelope(
        const VoiceCallEnvelopeDto(
          protocolVersion: 2,
          occurredAtUtc: '2026-10-10T07:30:00Z',
          eventId: 'ev-1',
          callId: 'call-100',
          sequence: 1,
          eventType: 'StatusChanged',
          payload: {
            'callId': 'call-100',
            'status': 'Accepted',
            'sequence': 1,
          },
        ),
      );
      await Future.delayed(Duration.zero);
      expect(createdTimers.first.isCancelled, isFalse);

      await repository.cleanupCall();
      expect(createdTimers.first.isCancelled, isTrue);
    });

    test('stale callback drops tick when active callId changed', () async {
      fakeSignalR.emitEnvelope(
        const VoiceCallEnvelopeDto(
          protocolVersion: 2,
          occurredAtUtc: '2026-10-10T07:30:00Z',
          eventId: 'ev-1',
          callId: 'call-100',
          sequence: 1,
          eventType: 'StatusChanged',
          payload: {
            'callId': 'call-100',
            'status': 'Accepted',
            'sequence': 1,
          },
        ),
      );
      await Future.delayed(Duration.zero);
      final timer1 = createdTimers.first;

      await repository.cleanupCall();

      // Fire old timer
      timer1.fire();
      await Future.delayed(Duration.zero);
      expect(fakeRemote.heartbeatCalls, isEmpty);
    });
  });

  group('DriverCallingRepositoryImpl CallKit & Deadline Tests', () {
    test('timeout arriving after Accepted status does NOT cancel or end call', () async {
      fakeSignalR.emitEnvelope(
        const VoiceCallEnvelopeDto(
          protocolVersion: 2,
          occurredAtUtc: '2026-10-10T07:30:00Z',
          eventId: 'ev-1',
          callId: 'call-200',
          sequence: 1,
          eventType: 'StatusChanged',
          payload: {
            'callId': 'call-200',
            'status': 'Accepted',
            'sequence': 1,
          },
        ),
      );
      await Future.delayed(Duration.zero);

      fakeRemote.snapshotToReturn = const VoiceCallSnapshotResponseDto(
        callId: 'call-200',
        tripStopId: 'trip-1',
        protocolVersion: 2,
        sequence: 1,
        status: 'Accepted',
      );

      // CallKit fires timeout
      fakeCallKit.triggerAction('timeout');
      await Future.delayed(Duration.zero);

      expect(fakeRemote.cancelledCalls, isEmpty);
      expect(fakeRemote.endedCalls, isEmpty);
    });

    test('timeout arriving while status is Ringing cancels call', () async {
      fakeSignalR.emitEnvelope(
        const VoiceCallEnvelopeDto(
          protocolVersion: 2,
          occurredAtUtc: '2026-10-10T07:30:00Z',
          eventId: 'ev-1',
          callId: 'call-201',
          sequence: 1,
          eventType: 'StatusChanged',
          payload: {
            'callId': 'call-201',
            'status': 'Ringing',
            'sequence': 1,
          },
        ),
      );
      await Future.delayed(Duration.zero);

      fakeRemote.snapshotToReturn = const VoiceCallSnapshotResponseDto(
        callId: 'call-201',
        tripStopId: 'trip-1',
        protocolVersion: 2,
        sequence: 1,
        status: 'Ringing',
      );

      // CallKit fires timeout
      fakeCallKit.triggerAction('timeout');
      await Future.delayed(Duration.zero);

      expect(fakeRemote.cancelledCalls, ['call-201']);
    });

    test('user end action while Active ends call once', () async {
      fakeSignalR.emitEnvelope(
        const VoiceCallEnvelopeDto(
          protocolVersion: 2,
          occurredAtUtc: '2026-10-10T07:30:00Z',
          eventId: 'ev-1',
          callId: 'call-202',
          sequence: 1,
          eventType: 'StatusChanged',
          payload: {
            'callId': 'call-202',
            'status': 'Active',
            'connectedAtUtc': '2026-10-10T07:31:00Z',
            'sequence': 1,
          },
        ),
      );
      await Future.delayed(Duration.zero);

      // Active snapshot also triggers CallKit setCallConnected
      expect(fakeCallKit.connectedCalls, ['call-202']);

      fakeCallKit.triggerAction('end');
      await Future.delayed(Duration.zero);

      expect(fakeRemote.endedCalls, ['call-202']);
    });
  });

  group('DriverCallingRepositoryImpl WebRTC Guards & Reporting Retries', () {
    test('duplicate Accepted snapshot does not start second offer session', () async {
      fakeSignalR.emitEnvelope(
        const VoiceCallEnvelopeDto(
          protocolVersion: 2,
          occurredAtUtc: '2026-10-10T07:30:00Z',
          eventId: 'ev-1',
          callId: 'call-301',
          sequence: 1,
          eventType: 'StatusChanged',
          payload: {
            'callId': 'call-301',
            'status': 'Accepted',
            'sequence': 1,
          },
        ),
      );
      await Future.delayed(Duration.zero);
      expect(fakeWebRtc.startOfferSessionCount, 1);

      // Duplicate Accepted snapshot
      fakeSignalR.emitEnvelope(
        const VoiceCallEnvelopeDto(
          protocolVersion: 2,
          occurredAtUtc: '2026-10-10T07:30:00Z',
          eventId: 'ev-2',
          callId: 'call-301',
          sequence: 2,
          eventType: 'StatusChanged',
          payload: {
            'callId': 'call-301',
            'status': 'Accepted',
            'sequence': 2,
          },
        ),
      );
      await Future.delayed(Duration.zero);

      expect(fakeWebRtc.startOfferSessionCount, 1);
    });

    test('reconnect does not start parallel offer session when offer already started', () async {
      fakeSignalR.emitEnvelope(
        const VoiceCallEnvelopeDto(
          protocolVersion: 2,
          occurredAtUtc: '2026-10-10T07:30:00Z',
          eventId: 'ev-1',
          callId: 'call-302',
          sequence: 1,
          eventType: 'StatusChanged',
          payload: {
            'callId': 'call-302',
            'status': 'Accepted',
            'sequence': 1,
          },
        ),
      );
      await Future.delayed(Duration.zero);
      expect(fakeWebRtc.startOfferSessionCount, 1);

      fakeRemote.snapshotToReturn = const VoiceCallSnapshotResponseDto(
        callId: 'call-302',
        tripStopId: 'trip-1',
        protocolVersion: 2,
        sequence: 2,
        status: 'Accepted',
      );

      // Reconnect triggers reconcile
      fakeSignalR.onReconnected?.call();
      await Future.delayed(Duration.zero);

      expect(fakeWebRtc.startOfferSessionCount, 1);
    });

    test('multiple local media connected events do not report connected twice', () async {
      fakeSignalR.emitEnvelope(
        const VoiceCallEnvelopeDto(
          protocolVersion: 2,
          occurredAtUtc: '2026-10-10T07:30:00Z',
          eventId: 'ev-1',
          callId: 'call-303',
          sequence: 1,
          eventType: 'StatusChanged',
          payload: {
            'callId': 'call-303',
            'status': 'Accepted',
            'sequence': 1,
          },
        ),
      );
      await Future.delayed(Duration.zero);

      fakeWebRtc.triggerLocalMediaConnected(true);
      await Future.delayed(Duration.zero);

      fakeWebRtc.triggerLocalMediaConnected(true);
      await Future.delayed(Duration.zero);

      expect(fakeRemote.reportConnectedCalls, 1);
    });

    test('cleanupCall allows a new clean call to start offer session', () async {
      fakeSignalR.emitEnvelope(
        const VoiceCallEnvelopeDto(
          protocolVersion: 2,
          occurredAtUtc: '2026-10-10T07:30:00Z',
          eventId: 'ev-1',
          callId: 'call-304',
          sequence: 1,
          eventType: 'StatusChanged',
          payload: {
            'callId': 'call-304',
            'status': 'Accepted',
            'sequence': 1,
          },
        ),
      );
      await Future.delayed(Duration.zero);
      expect(fakeWebRtc.startOfferSessionCount, 1);

      await repository.cleanupCall();

      fakeSignalR.emitEnvelope(
        const VoiceCallEnvelopeDto(
          protocolVersion: 2,
          occurredAtUtc: '2026-10-10T07:30:00Z',
          eventId: 'ev-2',
          callId: 'call-305',
          sequence: 1,
          eventType: 'StatusChanged',
          payload: {
            'callId': 'call-305',
            'status': 'Accepted',
            'sequence': 1,
          },
        ),
      );
      await Future.delayed(Duration.zero);
      expect(fakeWebRtc.startOfferSessionCount, 2);
    });
  });
}
