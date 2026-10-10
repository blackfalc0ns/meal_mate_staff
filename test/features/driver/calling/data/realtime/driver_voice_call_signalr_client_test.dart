import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:meal_mate_delivery/core/services/token_service.dart';
import 'package:meal_mate_delivery/core/services/voice_device_session_storage.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/models/realtime/voice_call_rtc_payload_dto.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/realtime/driver_voice_call_signalr_client.dart';

class FakeHubConnection implements HubConnection {
  HubConnectionState _state = HubConnectionState.Connected;
  final Map<String, List<Function>> _handlers = {};
  final List<Map<String, dynamic>> invokedMethods = [];

  void setMockState(HubConnectionState s) => _state = s;

  void triggerEvent(String methodName, List<Object?>? args) {
    final list = _handlers[methodName];
    if (list != null) {
      for (final fn in list) {
        fn(args);
      }
    }
  }

  @override
  HubConnectionState get state => _state;

  @override
  void on(String methodName, MethodInvocationFunc newMethod) {
    _handlers.putIfAbsent(methodName, () => []).add(newMethod);
  }

  @override
  void off(String methodName, {MethodInvocationFunc? method}) {
    if (method == null) {
      _handlers.remove(methodName);
    } else {
      _handlers[methodName]?.remove(method);
    }
  }

  @override
  Future<Object?> invoke(String methodName, {List<Object?>? args}) async {
    invokedMethods.add({
      'method': methodName,
      'args': args,
    });
    return null;
  }

  @override
  Future<void> send(String methodName, {List<Object?>? args}) async {
    invokedMethods.add({
      'method': methodName,
      'args': args,
    });
  }

  @override
  Future<void> start() async {
    _state = HubConnectionState.Connected;
  }

  @override
  Future<void> stop() async {
    _state = HubConnectionState.Disconnected;
  }

  @override
  void onclose(ClosedCallback callback) {}

  @override
  void onreconnecting(ReconnectingCallback callback) {}

  ReconnectedCallback? _reconnectedCallback;
  @override
  void onreconnected(ReconnectedCallback callback) {
    _reconnectedCallback = callback;
  }

  void triggerReconnected(String? connectionId) {
    _reconnectedCallback?.call(connectionId: connectionId);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTokenService implements TokenService {
  @override
  Future<String?> getToken() async => 'fake-jwt-token';
  @override
  Future<void> saveToken(String token) async {}
  @override
  Future<void> deleteToken() async {}
  @override
  Future<bool> hasToken() async => true;
  @override
  Future<String?> getRefreshToken() async => 'fake-refresh-token';
  @override
  Future<void> saveRefreshToken(String? token) async {}
  @override
  Future<void> deleteRefreshToken() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSessionStorage implements VoiceDeviceSessionStorage {
  String? sessionId = 'session-abc-123';
  String? controlProof = 'proof-secret-xyz';

  @override
  String? getDeviceSessionId() => sessionId;

  @override
  Future<String?> getControlProof() async => controlProof;

  @override
  bool isSessionValid() => true;

  @override
  DateTime? getExpiresAtUtc() => DateTime.now().add(const Duration(hours: 1));

  @override
  Future<void> clearSession() async {}

  @override
  String getOrCreateInstallationId(String fallback) => 'install-id';

  @override
  String? getFcmDeviceTokenId() => 'fcm-token-id';

  @override
  Future<void> saveFcmDeviceTokenId(String id) async {}

  @override
  Future<void> saveSession({
    required String deviceSessionId,
    required String controlProof,
    required String expiresAtUtc,
  }) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeHubConnection fakeHub;
  late FakeTokenService fakeTokenService;
  late FakeSessionStorage fakeSessionStorage;
  late DriverVoiceCallSignalRClient client;

  setUp(() {
    fakeHub = FakeHubConnection();
    fakeTokenService = FakeTokenService();
    fakeSessionStorage = FakeSessionStorage();
    client = DriverVoiceCallSignalRClient(
      tokenService: fakeTokenService,
      sessionStorage: fakeSessionStorage,
      hubConnection: fakeHub,
    );
  });

  group('DriverVoiceCallSignalRClient Hub Contract Tests', () {
    test('BindDeviceSession passes [deviceSessionId, controlProof]', () async {
      await client.connect();
      await client.bindDeviceSession();

      final bindCalls = fakeHub.invokedMethods.where(
        (m) => m['method'] == 'BindDeviceSession',
      ).toList();

      expect(bindCalls, isNotEmpty);
      final args = bindCalls.last['args'] as List<Object?>;
      expect(args.length, 2, reason: 'BindDeviceSession must take exactly [sessionId, controlProof]');
      expect(args[0], 'session-abc-123');
      expect(args[1], 'proof-secret-xyz');
      expect(client.isBound, isTrue);
    });

    test('SendOffer awaits connection and bind, sending exact 4-argument format', () async {
      await client.sendOffer(
        callId: 'call-99',
        sdp: 'v=0\r\no=mock\r\n',
        messageId: 'msg-uuid-1',
        generation: 0,
      );

      final offerCalls = fakeHub.invokedMethods.where(
        (m) => m['method'] == 'SendOffer',
      ).toList();

      expect(offerCalls, isNotEmpty);
      final args = offerCalls.last['args'] as List<Object?>;
      expect(args.length, 4);
      expect(args[0], 'call-99');
      expect(args[1], {'type': 'offer', 'sdp': 'v=0\r\no=mock\r\n'});
      expect(args[2], 'msg-uuid-1');
      expect(args[3], 0);
    });

    test('rtc:answer unpacks positional 4 arguments and emits VoiceCallRtcOfferAnswerDto', () async {
      await client.connect();

      VoiceCallRtcOfferAnswerDto? received;
      final sub = client.onAnswerReceived.listen((ans) => received = ans);

      fakeHub.triggerEvent('rtc:answer', [
        'call-99',
        {'type': 'answer', 'sdp': 'v=0\r\no=answer\r\n'},
        'msg-ans-1',
        1,
      ]);

      await Future.delayed(Duration.zero);
      expect(received, isNotNull);
      expect(received?.type, 'answer');
      expect(received?.sdp, 'v=0\r\no=answer\r\n');
      expect(received?.callId, 'call-99');
      expect(received?.messageId, 'msg-ans-1');
      expect(received?.generation, 1);

      await sub.cancel();
    });

    test('rtc:ice-candidate unpacks positional 4 arguments and emits VoiceCallRtcCandidateDto', () async {
      await client.connect();

      VoiceCallRtcCandidateDto? received;
      final sub = client.onIceCandidateReceived.listen((cand) => received = cand);

      fakeHub.triggerEvent('rtc:ice-candidate', [
        'call-99',
        {
          'candidate': 'candidate:1 1 UDP 2122252543 192.168.1.1 5000 typ host',
          'sdpMid': '0',
          'sdpMLineIndex': 0,
        },
        'msg-ice-1',
        1,
      ]);

      await Future.delayed(Duration.zero);
      expect(received, isNotNull);
      expect(received?.candidate, contains('candidate:1'));
      expect(received?.sdpMid, '0');
      expect(received?.sdpMLineIndex, 0);
      expect(received?.callId, 'call-99');
      expect(received?.messageId, 'msg-ice-1');
      expect(received?.generation, 1);

      await sub.cancel();
    });

    test('reconnect triggers rebind with session and proof and calls onReconnected', () async {
      await client.connect();
      fakeHub.invokedMethods.clear();

      bool reconnectedCalled = false;
      client.onReconnected = () => reconnectedCalled = true;

      fakeHub.triggerReconnected('new-conn-id');
      await Future.delayed(Duration.zero);

      final bindCalls = fakeHub.invokedMethods.where(
        (m) => m['method'] == 'BindDeviceSession',
      ).toList();

      expect(bindCalls, isNotEmpty);
      expect(bindCalls.last['args'], ['session-abc-123', 'proof-secret-xyz']);
      expect(reconnectedCalled, isTrue);
    });

    test('call:event deduplicates duplicate eventId and drops out-of-order sequence', () async {
      await client.connect();

      final receivedEvents = [];
      final sub = client.onEnvelopeReceived.listen((e) => receivedEvents.add(e));

      // Event 1 (sequence 1)
      fakeHub.triggerEvent('call:event', [
        {
          'eventId': 'ev-1',
          'callId': 'call-99',
          'sequence': 1,
          'eventType': 'StatusChanged',
          'payload': {'status': 'Ringing'},
        }
      ]);

      // Duplicate Event 1
      fakeHub.triggerEvent('call:event', [
        {
          'eventId': 'ev-1',
          'callId': 'call-99',
          'sequence': 1,
          'eventType': 'StatusChanged',
          'payload': {'status': 'Ringing'},
        }
      ]);

      // Out of order Event (sequence 0 <= 1)
      fakeHub.triggerEvent('call:event', [
        {
          'eventId': 'ev-2',
          'callId': 'call-99',
          'sequence': 1,
          'eventType': 'StatusChanged',
          'payload': {'status': 'Created'},
        }
      ]);

      // Next monotonic Event (sequence 2)
      fakeHub.triggerEvent('call:event', [
        {
          'eventId': 'ev-3',
          'callId': 'call-99',
          'sequence': 2,
          'eventType': 'StatusChanged',
          'payload': {'status': 'Accepted'},
        }
      ]);

      await Future.delayed(Duration.zero);
      expect(receivedEvents.length, 2);
      expect(receivedEvents[0].eventId, 'ev-1');
      expect(receivedEvents[1].eventId, 'ev-3');

      await sub.cancel();
    });
  });
}
