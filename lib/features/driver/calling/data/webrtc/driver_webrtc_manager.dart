import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math';

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
    _currentCallId = callId;
    _currentGeneration = generation;
    _hasRemoteDescription = false;
    _queuedRemoteCandidates.clear();

    await cleanup();
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

    // 2. Create Peer Connection
    _peerConnection = await createPeerConnection(configuration);

    // 3. Create audio track and add it before creating the offer
    final mediaConstraints = {
      'audio': {
        'echoCancellation': true,
        'noiseSuppression': true,
        'autoGainControl': true,
      },
      'video': false,
    };

    _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
    final audioTracks = _localStream?.getAudioTracks() ?? [];
    if (audioTracks.isEmpty) {
      _diag('Session', 'No local audio track acquired', callId: callId, gen: generation);
      throw StateError('No local audio tracks available for call $callId');
    }

    for (final track in audioTracks) {
      await _peerConnection!.addTrack(track, _localStream!);
      _diag('Session', 'Added local audio track: id=${track.id}, enabled=${track.enabled}', callId: callId, gen: generation);
    }

    // 4. Record remote audio-track arrival
    _peerConnection!.onTrack = (RTCTrackEvent event) {
      _diag('Track', 'Remote track arrived: kind=${event.track.kind}, id=${event.track.id}, enabled=${event.track.enabled}', callId: _currentCallId, gen: _currentGeneration);
    };

    // 5. Handle ICE candidates generated locally
    _peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
      if (candidate.candidate == null || candidate.candidate!.trim().isEmpty) {
        return;
      }
      final msgId = _generateUuidV4();
      _diag('SendIce', 'Sending local candidate (len: ${candidate.candidate!.length})', callId: callId, gen: _currentGeneration);
      unawaited(signalRClient.sendIceCandidate(
        callId: callId,
        candidate: candidate.candidate!,
        sdpMid: candidate.sdpMid,
        sdpMLineIndex: candidate.sdpMLineIndex,
        messageId: msgId,
        generation: _currentGeneration,
      ));
    };

    // 6. Handle connection state changes (Do not mark server Active from local ICE alone)
    _peerConnection!.onConnectionState = (RTCPeerConnectionState state) {
      _diag('ConnectionState', 'WebRTC peer connection state: $state', callId: _currentCallId, gen: _currentGeneration);
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateConnected) {
        _localMediaConnectedController.add(true);
        unawaited(logRtpStats());
      } else if (state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected) {
        _diag('ConnectionState', 'WebRTC peer connection failed or disconnected', callId: _currentCallId, gen: _currentGeneration);
      }
    };

    _peerConnection!.onIceConnectionState = (RTCIceConnectionState state) {
      _diag('IceState', 'WebRTC ICE connection state: $state', callId: _currentCallId, gen: _currentGeneration);
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

    final description = await _peerConnection!.createOffer(offerConstraints);
    await _peerConnection!.setLocalDescription(description);

    final msgId = _generateUuidV4();
    _diag('SendOffer', 'Local description set, sending offer (sdpLen: ${description.sdp?.length})', callId: callId, gen: _currentGeneration);
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

    if (answerDto.callId != null &&
        answerDto.callId!.isNotEmpty &&
        answerDto.callId != _currentCallId) {
      _diag('RtcAnswer', 'Ignoring answer for foreign callId: ${answerDto.callId} != $_currentCallId', callId: _currentCallId, gen: _currentGeneration);
      return;
    }

    if (answerDto.generation < _currentGeneration) {
      _diag('RtcAnswer', 'Ignoring stale answer generation: ${answerDto.generation} < $_currentGeneration', callId: _currentCallId, gen: _currentGeneration);
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

    if (iceDto.callId != null &&
        iceDto.callId!.isNotEmpty &&
        iceDto.callId != _currentCallId) {
      return;
    }

    if (iceDto.generation < _currentGeneration) {
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
      _diag('Cleanup', 'Error cleaning up WebRTC: $e');
    }
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
