import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/ice_server_config_entity.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/models/realtime/voice_call_rtc_payload_dto.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/realtime/driver_voice_call_signalr_client.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/webrtc/driver_webrtc_manager.dart';

class FakePeerConnection implements RTCPeerConnection {
  final List<RTCSessionDescription> remoteDescriptionsSet = [];
  final List<RTCIceCandidate> candidatesAdded = [];
  bool isClosed = false;

  void Function(RTCIceCandidate candidate)? onIceCandidateCallback;
  void Function(RTCPeerConnectionState state)? onConnectionStateCallback;
  void Function(RTCIceConnectionState state)? onIceConnectionStateCallback;
  void Function(RTCTrackEvent event)? onTrackCallback;

  @override
  set onIceCandidate(Function(RTCIceCandidate candidate)? handler) {
    onIceCandidateCallback = handler;
  }

  @override
  set onConnectionState(Function(RTCPeerConnectionState state)? handler) {
    onConnectionStateCallback = handler;
  }

  @override
  set onIceConnectionState(Function(RTCIceConnectionState state)? handler) {
    onIceConnectionStateCallback = handler;
  }

  @override
  set onTrack(Function(RTCTrackEvent event)? handler) {
    onTrackCallback = handler;
  }

  @override
  Future<RTCRtpSender> addTrack(MediaStreamTrack track, [MediaStream? stream]) async {
    return FakeRTCRtpSender();
  }

  @override
  Future<RTCSessionDescription> createOffer([Map<String, dynamic>? constraints]) async {
    return RTCSessionDescription('v=0\r\no=local-offer\r\n', 'offer');
  }

  @override
  Future<void> setLocalDescription(RTCSessionDescription description) async {}

  @override
  Future<void> setRemoteDescription(RTCSessionDescription description) async {
    remoteDescriptionsSet.add(description);
  }

  @override
  Future<void> addCandidate(RTCIceCandidate candidate) async {
    candidatesAdded.add(candidate);
  }

  @override
  Future<void> close() async {
    isClosed = true;
  }

  @override
  Future<void> dispose() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeMediaStreamTrack implements MediaStreamTrack {
  @override
  String get id => 'audio-track-1';
  @override
  String get kind => 'audio';
  @override
  bool enabled = true;
  @override
  Future<bool> stop() async => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeMediaStream implements MediaStream {
  final List<MediaStreamTrack> _tracks = [FakeMediaStreamTrack()];

  @override
  List<MediaStreamTrack> getAudioTracks() => _tracks;

  @override
  List<MediaStreamTrack> getTracks() => _tracks;

  @override
  Future<void> dispose() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeRTCRtpSender implements RTCRtpSender {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSignalRClient implements DriverVoiceCallSignalRClient {
  final _answerController = StreamController<VoiceCallRtcOfferAnswerDto>.broadcast();
  final _iceController = StreamController<VoiceCallRtcCandidateDto>.broadcast();
  final List<Map<String, dynamic>> sentOffers = [];
  final List<Map<String, dynamic>> sentCandidates = [];

  @override
  Stream<VoiceCallRtcOfferAnswerDto> get onAnswerReceived => _answerController.stream;

  @override
  Stream<VoiceCallRtcCandidateDto> get onIceCandidateReceived => _iceController.stream;

  void emitAnswer(VoiceCallRtcOfferAnswerDto dto) {
    _answerController.add(dto);
  }

  void emitIceCandidate(VoiceCallRtcCandidateDto dto) {
    _iceController.add(dto);
  }

  @override
  Future<void> sendOffer({
    required String callId,
    required String sdp,
    required String messageId,
    int generation = 0,
  }) async {
    sentOffers.add({
      'callId': callId,
      'sdp': sdp,
      'messageId': messageId,
      'generation': generation,
    });
  }

  @override
  Future<void> sendIceCandidate({
    required String callId,
    required String candidate,
    String? sdpMid,
    int? sdpMLineIndex,
    String? usernameFragment,
    required String messageId,
    int generation = 0,
  }) async {
    sentCandidates.add({
      'callId': callId,
      'candidate': candidate,
      'sdpMid': sdpMid,
      'sdpMLineIndex': sdpMLineIndex,
      'usernameFragment': usernameFragment,
      'messageId': messageId,
      'generation': generation,
    });
  }

  @override
  Future<void> dispose() async {
    await _answerController.close();
    await _iceController.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late FakeSignalRClient fakeSignalR;
  late FakePeerConnection fakePc;
  late FakeMediaStream fakeStream;
  late DriverWebRtcManager manager;

  final iceServers = [
    const IceServerConfigEntity(urls: ['stun:stun.l.google.com:19302']),
  ];

  setUp(() {
    fakeSignalR = FakeSignalRClient();
    fakePc = FakePeerConnection();
    fakeStream = FakeMediaStream();
    manager = DriverWebRtcManager(
      signalRClient: fakeSignalR,
      peerConnectionFactory: (config) async => fakePc,
      userMediaFactory: (constraints) async => fakeStream,
    );
  });

  tearDown(() async {
    fakeSignalR.dispose();
  });

  group('DriverWebRtcManager Lifecycle and Filtering', () {
    test('startOfferSession cleans up previous session and sets new callId and generation', () async {
      await manager.startOfferSession(
        callId: 'call-1',
        iceServers: iceServers,
        generation: 1,
      );
      expect(manager.currentCallId, 'call-1');

      // Start a second session on a fresh manager
      final fakePc2 = FakePeerConnection();
      final manager2 = DriverWebRtcManager(
        signalRClient: fakeSignalR,
        peerConnectionFactory: (config) async => fakePc2,
        userMediaFactory: (constraints) async => fakeStream,
      );

      await manager2.startOfferSession(
        callId: 'call-2',
        iceServers: iceServers,
        generation: 2,
      );

      expect(manager2.currentCallId, 'call-2');
    });

    test('ignores remote answer for foreign callId', () async {
      await manager.startOfferSession(
        callId: 'call-1',
        iceServers: iceServers,
        generation: 1,
      );

      fakeSignalR.emitAnswer(
        const VoiceCallRtcOfferAnswerDto(
          type: 'answer',
          sdp: 'v=0\r\no=foreign-ans\r\n',
          callId: 'call-other',
          generation: 1,
        ),
      );

      await Future.delayed(Duration.zero);
      expect(fakePc.remoteDescriptionsSet, isEmpty);
    });

    test('ignores remote answer with older or mismatched generation', () async {
      await manager.startOfferSession(
        callId: 'call-1',
        iceServers: iceServers,
        generation: 2,
      );

      fakeSignalR.emitAnswer(
        const VoiceCallRtcOfferAnswerDto(
          type: 'answer',
          sdp: 'v=0\r\no=stale-ans\r\n',
          callId: 'call-1',
          generation: 1, // older than 2
        ),
      );

      await Future.delayed(Duration.zero);
      expect(fakePc.remoteDescriptionsSet, isEmpty);
    });

    test('accepts remote answer with matching callId and generation', () async {
      await manager.startOfferSession(
        callId: 'call-1',
        iceServers: iceServers,
        generation: 2,
      );

      fakeSignalR.emitAnswer(
        const VoiceCallRtcOfferAnswerDto(
          type: 'answer',
          sdp: 'v=0\r\no=valid-ans\r\n',
          callId: 'call-1',
          generation: 2,
        ),
      );

      await Future.delayed(Duration.zero);
      expect(fakePc.remoteDescriptionsSet.length, 1);
      expect(fakePc.remoteDescriptionsSet.first.sdp, 'v=0\r\no=valid-ans\r\n');
    });

    test('queues early remote candidate and applies it after answer description arrives', () async {
      await manager.startOfferSession(
        callId: 'call-1',
        iceServers: iceServers,
        generation: 1,
      );

      // Early candidate before answer
      fakeSignalR.emitIceCandidate(
        const VoiceCallRtcCandidateDto(
          candidate: 'candidate:early 1 UDP 2122252543 192.168.1.1 5000 typ host',
          callId: 'call-1',
          generation: 1,
        ),
      );

      await Future.delayed(Duration.zero);
      expect(fakePc.candidatesAdded, isEmpty);

      // Now answer arrives
      fakeSignalR.emitAnswer(
        const VoiceCallRtcOfferAnswerDto(
          type: 'answer',
          sdp: 'v=0\r\no=valid-ans\r\n',
          callId: 'call-1',
          generation: 1,
        ),
      );

      await Future.delayed(Duration.zero);
      expect(fakePc.remoteDescriptionsSet.length, 1);
      expect(fakePc.candidatesAdded.length, 1);
      expect(fakePc.candidatesAdded.first.candidate, contains('candidate:early'));
    });

    test('ignores candidate with mismatched generation', () async {
      await manager.startOfferSession(
        callId: 'call-1',
        iceServers: iceServers,
        generation: 2,
      );

      fakeSignalR.emitIceCandidate(
        const VoiceCallRtcCandidateDto(
          candidate: 'candidate:stale 1 UDP 2122252543 192.168.1.1 5000 typ host',
          callId: 'call-1',
          generation: 1,
        ),
      );

      await Future.delayed(Duration.zero);
      expect(fakePc.candidatesAdded, isEmpty);
    });
  });
}
