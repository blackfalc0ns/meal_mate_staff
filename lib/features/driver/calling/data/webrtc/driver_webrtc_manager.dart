import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/ice_server_config_entity.dart';
import '../../domain/entities/voice_call_status.dart';
import '../models/realtime/voice_call_rtc_payload_dto.dart';
import '../realtime/driver_voice_call_signalr_client.dart';

typedef PeerConnectionFactory = Future<RTCPeerConnection> Function(Map<String, dynamic> configuration);
typedef UserMediaFactory = Future<MediaStream> Function(Map<String, dynamic> mediaConstraints);

@lazySingleton
class DriverWebRtcManager {
  DriverWebRtcManager({
    required this.signalRClient,
    PeerConnectionFactory? peerConnectionFactory,
    UserMediaFactory? userMediaFactory,
  })  : _peerConnectionFactory = peerConnectionFactory ?? createPeerConnection,
        _userMediaFactory = userMediaFactory ?? ((constraints) => navigator.mediaDevices.getUserMedia(constraints));

  final DriverVoiceCallSignalRClient signalRClient;
  final PeerConnectionFactory _peerConnectionFactory;
  final UserMediaFactory _userMediaFactory;

  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  String? _currentCallId;
  String? get currentCallId => _currentCallId;
  int _currentGeneration = 0;
  int _lifecycleToken = 0;

  final List<RTCIceCandidate> _queuedRemoteCandidates = [];
  bool _hasRemoteDescription = false;
  bool _isDisposed = false;
  bool get isDisposed => _isDisposed;

  final _mediaStateController = StreamController<VoiceCallStatus>.broadcast();
  Stream<VoiceCallStatus> get onMediaStateChanged =>
      _mediaStateController.stream;

  final _localMediaConnectedController = StreamController<bool>.broadcast();
  Stream<bool> get onLocalMediaConnected =>
      _localMediaConnectedController.stream;

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
    await cleanup();
    final lifecycleToken = _lifecycleToken;
    _currentCallId = callId;
    _currentGeneration = generation;
    _hasRemoteDescription = false;
    _queuedRemoteCandidates.clear();
    initializeSubscriptions();

    _mediaStateController.add(VoiceCallStatus.connecting);

    // 1. Require a successful per-call ice-servers response
    if (iceServers.isEmpty) {
      _diag('Session', 'Failed to start WebRTC: ICE servers list is empty', callId: callId, gen: generation);
      throw StateError('Cannot start WebRTC session: No ICE servers provided for call $callId');
    }

    final rtcIceServers = iceServers.map((s) => s.toMap()).toList();
    _diag('Session', 'Configured ${rtcIceServers.length} ICE server(s)', callId: callId, gen: generation);

    final configuration = {
      'iceServers': rtcIceServers,
      'sdpSemantics': 'unified-plan',
      'bundlePolicy': 'max-bundle',
      'rtcpMuxPolicy': 'require',
    };

    final sessionCallId = callId;
    final sessionGeneration = generation;

    // 2. Create Peer Connection
    final pc = await _peerConnectionFactory(configuration);
    if (!_isCurrentSession(callId, generation, lifecycleToken)) {
      await pc.close();
      await pc.dispose();
      return;
    }
    _peerConnection = pc;

    // 3. Create audio track and add it before creating the offer
    final mediaConstraints = {
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': false,
    };

    final localStream = await _userMediaFactory(mediaConstraints);
    if (!_isCurrentSession(callId, generation, lifecycleToken)) {
      for (final track in localStream.getTracks()) { track.stop(); }
      await localStream.dispose();
      await pc.close();
      await pc.dispose();
      return;
    }
    _localStream = localStream;
    final audioTracks = localStream.getAudioTracks();
    if (audioTracks.isEmpty) {
      _diag('Session', 'No local audio track acquired', callId: callId, gen: generation);
      throw StateError('No local audio tracks available for call $callId');
    }

    for (final track in audioTracks) {
      await pc.addTrack(track, localStream);
      if (!_isCurrentSession(callId, generation, lifecycleToken)) {
        for (final staleTrack in localStream.getTracks()) { staleTrack.stop(); }
        await localStream.dispose();
        await pc.close();
        await pc.dispose();
        return;
      }
      _diag('Session', 'Added local audio track: id=${track.id}, enabled=${track.enabled}', callId: callId, gen: generation);
    }

    // 4. Record remote audio-track arrival
    pc.onTrack = (RTCTrackEvent event) {
      if (_currentCallId != sessionCallId || _currentGeneration != sessionGeneration || _peerConnection != pc) {
        return;
      }
      _diag('Track', 'Remote track arrived: kind=${event.track.kind}, id=${event.track.id}, enabled=${event.track.enabled}', callId: sessionCallId, gen: sessionGeneration);
    };

    // 5. Handle ICE candidates generated locally
    pc.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate == null || candidate.candidate!.trim().isEmpty) {
        return;
      }
      if (_currentCallId != sessionCallId || _currentGeneration != sessionGeneration || _peerConnection != pc) {
        _diag('SendIce', 'Dropping stale ICE candidate: session changed', callId: sessionCallId, gen: sessionGeneration);
        return;
      }
      final msgId = _generateUuidV4();
      _diag('SendIce', 'Sending local candidate (len: ${candidate.candidate!.length})', callId: sessionCallId, gen: sessionGeneration);
      unawaited(signalRClient.sendIceCandidate(
        callId: sessionCallId,
        candidate: candidate.candidate!,
        sdpMid: candidate.sdpMid,
        sdpMLineIndex: candidate.sdpMLineIndex,
        messageId: msgId,
        generation: sessionGeneration,
      ));
    };

    // 6. Handle connection state changes (Do not mark server Active from local ICE alone)
    pc.onConnectionState = (RTCPeerConnectionState state) {
      if (_currentCallId != sessionCallId || _currentGeneration != sessionGeneration || _peerConnection != pc) {
        return;
      }
      _diag('ConnectionState', 'WebRTC peer connection state: $state', callId: sessionCallId, gen: sessionGeneration);
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _localMediaConnectedController.add(true);
        unawaited(logRtpStats());
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        _diag('ConnectionState', 'WebRTC peer connection failed or disconnected', callId: sessionCallId, gen: sessionGeneration);
      }
    };

    pc.onIceConnectionState = (RTCIceConnectionState state) {
      if (_currentCallId != sessionCallId || _currentGeneration != sessionGeneration || _peerConnection != pc) {
        return;
      }
      _diag('IceState', 'WebRTC ICE connection state: $state', callId: sessionCallId, gen: sessionGeneration);
      if (state == RTCIceConnectionState.RTCIceConnectionStateConnected ||
          state == RTCIceConnectionState.RTCIceConnectionStateCompleted) {
        _localMediaConnectedController.add(true);
        unawaited(logRtpStats());
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

    final description = await pc.createOffer(offerConstraints);
    if (!_isCurrentSession(callId, generation, lifecycleToken)) return;
    await pc.setLocalDescription(description);
    if (!_isCurrentSession(callId, generation, lifecycleToken)) return;

    final msgId = _generateUuidV4();
    _diag('SendOffer', 'Local description set, sending offer (sdpLen: ${description.sdp?.length})', callId: sessionCallId, gen: sessionGeneration);
    await signalRClient.sendOffer(
      callId: sessionCallId,
      sdp: description.sdp ?? '',
      messageId: msgId,
      generation: sessionGeneration,
    );
  }

  Future<void> _handleRemoteAnswer(VoiceCallRtcOfferAnswerDto answerDto) async {
    final pc = _peerConnection;
    if (pc == null) return;

    if (_currentCallId == null ||
        (answerDto.callId != null &&
            answerDto.callId!.isNotEmpty &&
            answerDto.callId != _currentCallId)) {
      _diag('RtcAnswer', 'Ignoring answer for foreign callId: ${answerDto.callId} != $_currentCallId', callId: _currentCallId, gen: _currentGeneration);
      return;
    }

    if (answerDto.generation != _currentGeneration) {
      _diag('RtcAnswer', 'Ignoring stale or mismatched answer generation: ${answerDto.generation} != $_currentGeneration', callId: _currentCallId, gen: _currentGeneration);
      return;
    }

    try {
      _diag('RtcAnswer', 'Setting remote description from answer (sdpLen: ${answerDto.sdp.length})', callId: _currentCallId, gen: _currentGeneration);
      final description = RTCSessionDescription(answerDto.sdp, answerDto.type);
      await pc.setRemoteDescription(description);
      _hasRemoteDescription = true;

      // Drain queued early ICE candidates
      for (final candidate in _queuedRemoteCandidates) {
        try {
          await pc.addCandidate(candidate);
        } catch (e) {
          _diag('RtcIce', 'Error applying queued candidate: $e', callId: _currentCallId, gen: _currentGeneration);
        }
      }
      _queuedRemoteCandidates.clear();
    } catch (e) {
      _diag('RtcAnswer', 'Error setting remote answer description: $e', callId: _currentCallId, gen: _currentGeneration);
    }
  }

  Future<void> _handleRemoteCandidate(VoiceCallRtcCandidateDto iceDto) async {
    final pc = _peerConnection;
    if (pc == null) return;

    if (_currentCallId == null ||
        (iceDto.callId != null &&
            iceDto.callId!.isNotEmpty &&
            iceDto.callId != _currentCallId)) {
      return;
    }

    if (iceDto.generation != _currentGeneration) {
      return;
    }

    if (iceDto.candidate.trim().isEmpty) {
      return;
    }

    final candidate = RTCIceCandidate(
      iceDto.candidate,
      iceDto.sdpMid,
      iceDto.sdpMLineIndex,
    );

    if (!_hasRemoteDescription) {
      _diag('RtcIce', 'Queuing early remote ICE candidate', callId: _currentCallId, gen: _currentGeneration);
      _queuedRemoteCandidates.add(candidate);
      return;
    }

    try {
      await pc.addCandidate(candidate);
    } catch (e) {
      _diag('RtcIce', 'Error adding remote ICE candidate: $e', callId: _currentCallId, gen: _currentGeneration);
    }
  }

  Future<void> logRtpStats() async {
    final pc = _peerConnection;
    if (pc == null) return;
    try {
      final stats = await pc.getStats();
      for (final report in stats) {
        if (report.type == 'inbound-rtp' || report.type == 'outbound-rtp') {
          _diag('RTP', '${report.type}: bytesSent=${report.values['bytesSent']}, bytesReceived=${report.values['bytesReceived']}, packetsSent=${report.values['packetsSent']}, packetsReceived=${report.values['packetsReceived']}', callId: _currentCallId, gen: _currentGeneration);
        }
      }
    } catch (_) {}
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
      _diag('AudioRoute', 'Failed to toggle speakerphone: $e', callId: _currentCallId, gen: _currentGeneration);
    }
  }

  String _generateUuidV4() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  Future<void> cleanup() async {
    _lifecycleToken++;
    try {
      unawaited(_answerSub?.cancel());
      _answerSub = null;
      unawaited(_iceSub?.cancel());
      _iceSub = null;

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
      _currentGeneration = 0;
    } catch (e) {
      _diag('Cleanup', 'Error cleaning up WebRTC: $e');
    }
  }

  bool _isCurrentSession(String callId, int generation, int token) {
    return !_isDisposed &&
        _lifecycleToken == token &&
        _currentCallId == callId &&
        _currentGeneration == generation;
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await cleanup();
    await _mediaStateController.close();
    await _localMediaConnectedController.close();
  }

  void _diag(String action, String details, {String? callId, int? gen}) {
    final c = callId != null && callId.isNotEmpty ? '[$callId]' : '[no-call]';
    final g = gen != null ? '[gen:$gen]' : '';
    developer.log('[VoiceDiag]$c$g $action: $details');
  }
}
