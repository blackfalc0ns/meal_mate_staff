import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_webrtc/flutter_webrtc.dart';

import 'package:injectable/injectable.dart';

import '../../domain/entities/ice_server_config_entity.dart';
import '../../domain/entities/voice_call_status.dart';
import '../models/realtime/voice_call_rtc_payload_dto.dart';
import '../realtime/driver_voice_call_signalr_client.dart';

@lazySingleton
class DriverWebRtcManager {
  DriverWebRtcManager({
    required this.signalRClient,
  });

  final DriverVoiceCallSignalRClient signalRClient;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  String? _currentCallId;
  String? get currentCallId => _currentCallId;
  int _currentGeneration = 0;

  final List<RTCIceCandidate> _queuedRemoteCandidates = [];
  bool _hasRemoteDescription = false;
  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  final _mediaStateController = StreamController<VoiceCallStatus>.broadcast();
  Stream<VoiceCallStatus> get onMediaStateChanged =>
      _mediaStateController.stream;

  StreamSubscription<VoiceCallRtcOfferAnswerDto>? _answerSub;
  StreamSubscription<VoiceCallRtcCandidateDto>? _iceSub;

  void initializeSubscriptions() {
    unawaited(_answerSub?.cancel());
    _answerSub = signalRClient.onAnswerReceived.listen((answerDto) {
      unawaited(_handleRemoteAnswer(answerDto));
    });

    unawaited(_iceSub?.cancel());
    _iceSub = signalRClient.onIceCandidateReceived.listen((iceDto) {
      unawaited(_handleRemoteCandidate(iceDto));
    });
  }

  Future<void> startOfferSession({
    required String callId,
    required List<IceServerConfigEntity> iceServers,
    int generation = 0,
  }) async {
    _currentCallId = callId;
    _currentGeneration = generation;
    _hasRemoteDescription = false;
    _queuedRemoteCandidates.clear();

    await cleanup();
    initializeSubscriptions();

    _mediaStateController.add(VoiceCallStatus.connecting);

    // 1. Get user audio media
    final mediaConstraints = {
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': false,
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);

    // 2. Configure ICE servers
    final rtcIceServers = iceServers.map((s) => s.toMap()).toList();
    if (rtcIceServers.isEmpty) {
      rtcIceServers.add({
        'urls': ['stun:stun.l.google.com:19302'],
      });
    }

    final configuration = {
      'iceServers': rtcIceServers,
      'sdpSemantics': 'unified-plan',
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
    };

    // 3. Create Peer Connection
    _peerConnection = await createPeerConnection(configuration);

    // 4. Add audio tracks to Peer Connection
    for (final track in _localStream!.getAudioTracks()) {
      await _peerConnection!.addTrack(track, _localStream!);
    }

    // 5. Handle ICE candidates generated locally
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate == null || candidate.candidate!.trim().isEmpty) {
        return;
      }
      final msgId = _generateUuid();
      unawaited(signalRClient.sendIceCandidate(
        callId: callId,
        candidate: candidate.candidate!,
        sdpMid: candidate.sdpMid,
        sdpMLineIndex: candidate.sdpMLineIndex,
        messageId: msgId,
        generation: _currentGeneration,
      ));
    };

    // 6. Handle connection state changes
    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      _log('WebRTC Connection state: $state');
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _mediaStateController.add(VoiceCallStatus.active);
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state ==
              RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        _log('WebRTC connection failed or disconnected');
      }
    };

    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      _log('WebRTC ICE Connection state: $state');
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        _mediaStateController.add(VoiceCallStatus.active);
      }
    };

    // 7. Create Offer
    final offerConstraints = {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': false,
      },
      'optional': [],
    };

    final description = await _peerConnection!.createOffer(offerConstraints);
    await _peerConnection!.setLocalDescription(description);

    final msgId = _generateUuid();
    await signalRClient.sendOffer(
      callId: callId,
      sdp: description.sdp ?? '',
      messageId: msgId,
      generation: _currentGeneration,
    );
  }

  Future<void> _handleRemoteAnswer(VoiceCallRtcOfferAnswerDto answerDto) async {
    final pc = _peerConnection;
    if (pc == null) return;

    try {
      _log('Setting remote description from answer');
      final description = RTCSessionDescription(answerDto.sdp, answerDto.type);
      await pc.setRemoteDescription(description);
      _hasRemoteDescription = true;

      // Drain queued ICE candidates
      for (final candidate in _queuedRemoteCandidates) {
        try {
          await pc.addCandidate(candidate);
        } catch (e) {
          _log('Error adding queued candidate: $e');
        }
      }
      _queuedRemoteCandidates.clear();
    } catch (e) {
      _log('Error setting remote answer: $e');
    }
  }

  Future<void> _handleRemoteCandidate(VoiceCallRtcCandidateDto iceDto) async {
    final pc = _peerConnection;
    if (pc == null) return;

    final candidate = RTCIceCandidate(
      iceDto.candidate,
      iceDto.sdpMid,
      iceDto.sdpMLineIndex,
    );

    if (!_hasRemoteDescription) {
      _log('Queuing early remote ICE candidate');
      _queuedRemoteCandidates.add(candidate);
      return;
    }

    try {
      await pc.addCandidate(candidate);
    } catch (e) {
      _log('Error adding remote candidate: $e');
    }
  }

  Future<void> toggleMute(bool muted) async {
    if (_localStream == null) return;
    for (final track in _localStream!.getAudioTracks()) {
      track.enabled = !muted;
    }
  }

  Future<void> toggleSpeaker(bool enabled) async {
    try {
      await Helper.setSpeakerphoneOn(enabled);
    } catch (e) {
      _log('Failed to toggle speakerphone: $e');
    }
  }

  String _generateUuid() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }

  Future<void> cleanup() async {
    try {
      unawaited(_answerSub?.cancel());
      unawaited(_iceSub?.cancel());

      if (_localStream != null) {
        for (final track in _localStream!.getTracks()) {
          track.stop();
        }
        await _localStream?.dispose();
        _localStream = null;
      }

      if (_peerConnection != null) {
        await _peerConnection?.close();
        await _peerConnection?.dispose();
        _peerConnection = null;
      }

      _hasRemoteDescription = false;
      _queuedRemoteCandidates.clear();
      _currentCallId = null;
    } catch (e) {
      _log('Error cleaning up WebRTC: $e');
    }
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await cleanup();
    await _mediaStateController.close();
  }

  void _log(String message) {
    developer.log('[DriverWebRTC] $message');
  }
}
