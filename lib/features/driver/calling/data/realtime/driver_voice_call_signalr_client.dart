import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:signalr_netcore/signalr_client.dart';

import '../../../../../core/network/network_constants.dart';
import '../../../../../core/services/token_service.dart';
import '../../../../../core/services/voice_device_session_storage.dart';
import '../models/realtime/voice_call_envelope_dto.dart';
import '../models/realtime/voice_call_rtc_payload_dto.dart';

@lazySingleton
class DriverVoiceCallSignalRClient {
  DriverVoiceCallSignalRClient({
    required this.tokenService,
    required this.sessionStorage,
    HubConnection? hubConnection,
  }) : _providedHubConnection = hubConnection;

  final TokenService tokenService;
  final VoiceDeviceSessionStorage sessionStorage;
  final HubConnection? _providedHubConnection;

  HubConnection? _hubConnection;
  String? _builtWithToken;
  bool _isDisposed = false;
  bool _isConnecting = false;
  bool _isBound = false;
  String? _boundSessionId;

  final _processedEventIds = <String>{};
  int _lastCommittedSequence = -1;

  final _envelopeController =
      StreamController<VoiceCallEnvelopeDto>.broadcast();
  final _offerController =
      StreamController<VoiceCallRtcOfferAnswerDto>.broadcast();
  final _answerController =
      StreamController<VoiceCallRtcOfferAnswerDto>.broadcast();
  final _iceController =
      StreamController<VoiceCallRtcCandidateDto>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();
  final _boundController = StreamController<bool>.broadcast();

  Stream<VoiceCallEnvelopeDto> get onEnvelopeReceived =>
      _envelopeController.stream;
  Stream<VoiceCallRtcOfferAnswerDto> get onOfferReceived =>
      _offerController.stream;
  Stream<VoiceCallRtcOfferAnswerDto> get onAnswerReceived =>
      _answerController.stream;
  Stream<VoiceCallRtcCandidateDto> get onIceCandidateReceived =>
      _iceController.stream;
  Stream<bool> get onConnectionStatusChanged =>
      _connectionStatusController.stream;
  Stream<bool> get onBoundChanged => _boundController.stream;

  VoidCallback? onReconnected;

  bool get isConnected =>
      _hubConnection?.state == HubConnectionState.Connected;
  bool get isBound => _isBound;
  String? get boundSessionId => _boundSessionId;

  Future<void> connect() async {
    if (_isDisposed) return;
    if (isConnected && _isBound) return;
    if (_isConnecting) return;
    _isConnecting = true;

    try {
      final token = await tokenService.getToken();
      if (token == null || token.trim().isEmpty) {
        _diag('Connect', 'No auth token available for voice SignalR hub');
        return;
      }

      await _initHub(token);
      if (_hubConnection?.state == HubConnectionState.Disconnected) {
        await _hubConnection?.start();
        _diag('Connect', 'Voice Hub connection started successfully (state: ${_hubConnection?.state})');
        _connectionStatusController.add(true);
        await bindDeviceSession();
      } else if (isConnected && !_isBound) {
        await bindDeviceSession();
      }
    } catch (e) {
      _diag('Connect', 'Failed to connect Voice SignalR hub: $e');
      _connectionStatusController.add(false);
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> _initHub(String token) async {
    if (_hubConnection != null && _builtWithToken == token) return;

    if (_hubConnection != null && _builtWithToken != token) {
      try {
        await _hubConnection?.stop();
      } catch (_) {}
      _hubConnection = null;
    }

    _builtWithToken = token;

    if (_providedHubConnection != null) {
      _hubConnection = _providedHubConnection;
    } else {
      const fullUrl = '${NetworkConstants.baseUrl}${EndPoints.voiceCallsV2Hub}';
      final httpOptions = HttpConnectionOptions(
        accessTokenFactory: () async => token,
      );

      _hubConnection = HubConnectionBuilder()
          .withUrl(fullUrl, options: httpOptions)
          .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000, 15000])
          .build();
    }

    _registerLifecycleCallbacks();
    _registerEventHandlers();
  }

  void _registerLifecycleCallbacks() {
    final hub = _hubConnection;
    if (hub == null) return;

    hub.onclose(({Exception? error}) {
      if (_isDisposed) return;
      _diag('Lifecycle', 'Voice Hub onclose: $error');
      _isBound = false;
      _boundController.add(false);
      _connectionStatusController.add(false);
    });

    hub.onreconnecting(({Exception? error}) {
      if (_isDisposed) return;
      _diag('Lifecycle', 'Voice Hub onreconnecting: $error');
      _isBound = false;
      _boundController.add(false);
      _connectionStatusController.add(false);
    });

    hub.onreconnected(({String? connectionId}) async {
      if (_isDisposed) return;
      _diag('Lifecycle', 'Voice Hub onreconnected (connectionId: $connectionId)');
      _connectionStatusController.add(true);
      _isBound = false;
      _boundController.add(false);
      await bindDeviceSession();
      onReconnected?.call();
    });
  }

  void _registerEventHandlers() {
    final hub = _hubConnection;
    if (hub == null) return;

    hub.on('bound', (arguments) {
      _diag('Bound', 'bound confirmation received from server');
      _isBound = true;
      _boundController.add(true);
    });

    final eventNames = ['call:event', 'OnCallEvent', 'CallEvent'];
    for (final name in eventNames) {
      hub.on(name, _handleCallEvent);
    }

    final offerNames = ['rtc:offer', 'OnOffer', 'Offer'];
    for (final name in offerNames) {
      hub.on(name, _handleRtcOffer);
    }

    final answerNames = ['rtc:answer', 'OnAnswer', 'Answer'];
    for (final name in answerNames) {
      hub.on(name, _handleRtcAnswer);
    }

    final iceNames = ['rtc:ice-candidate', 'OnIceCandidate', 'IceCandidate', 'rtc:ice'];
    for (final name in iceNames) {
      hub.on(name, _handleRtcIce);
    }
  }

  void _handleCallEvent(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    try {
      final raw = args.first;
      final Map<String, dynamic> map = _extractMap(raw);
      if (map.isEmpty) return;

      final envelope = VoiceCallEnvelopeDto.fromJson(map);

      // Event deduplication by eventId
      if (envelope.eventId.isNotEmpty) {
        if (_processedEventIds.contains(envelope.eventId)) {
          _diag('CallEvent', 'Dropping duplicate voice event: ${envelope.eventId}', callId: envelope.callId);
          return;
        }
        _processedEventIds.add(envelope.eventId);
        if (_processedEventIds.length > 500) {
          _processedEventIds.clear();
        }
      }

      // Check sequence monotonicity if provided
      if (envelope.sequence > 0 && envelope.sequence <= _lastCommittedSequence) {
        _diag('CallEvent', 'Ignoring out-of-order sequence: ${envelope.sequence} <= $_lastCommittedSequence', callId: envelope.callId, seq: envelope.sequence);
        return;
      }
      if (envelope.sequence > 0) {
        _lastCommittedSequence = envelope.sequence;
      }

      final payloadStatus = envelope.payload?['status']?.toString();
      _diag('CallEvent', 'Processed event type: ${envelope.eventType}, payload status: $payloadStatus', callId: envelope.callId, seq: envelope.sequence);

      _envelopeController.add(envelope);
    } catch (e) {
      _diag('CallEvent', 'Error parsing voice call event: $e');
    }
  }

  void _handleRtcOffer(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    try {
      String callId = '';
      Map<String, dynamic> payload = {};
      String messageId = '';
      int generation = 0;

      if (args.length >= 4) {
        callId = args[0]?.toString() ?? '';
        payload = _extractMap(args[1]);
        messageId = args[2]?.toString() ?? '';
        generation = (args[3] as num?)?.toInt() ?? 0;
      } else {
        payload = _extractMap(args.first);
        callId = payload['callId']?.toString() ?? '';
        messageId = payload['messageId']?.toString() ?? '';
        generation = (payload['generation'] as num?)?.toInt() ?? 0;
      }

      final sdp = payload['sdp']?.toString() ?? '';
      final type = payload['type']?.toString() ?? 'offer';
      if (sdp.isNotEmpty) {
        final dto = VoiceCallRtcOfferAnswerDto(
          type: type,
          sdp: sdp,
          callId: callId,
          messageId: messageId,
          generation: generation,
        );
        _diag('RtcOffer', 'Received offer (type: $type, sdpLen: ${sdp.length})', callId: callId, gen: generation);
        _offerController.add(dto);
      }
    } catch (e) {
      _diag('RtcOffer', 'Error parsing rtc:offer: $e');
    }
  }

  void _handleRtcAnswer(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    try {
      String callId = '';
      Map<String, dynamic> payload = {};
      String messageId = '';
      int generation = 0;

      if (args.length >= 4) {
        callId = args[0]?.toString() ?? '';
        payload = _extractMap(args[1]);
        messageId = args[2]?.toString() ?? '';
        generation = (args[3] as num?)?.toInt() ?? 0;
      } else {
        payload = _extractMap(args.first);
        callId = payload['callId']?.toString() ?? '';
        messageId = payload['messageId']?.toString() ?? '';
        generation = (payload['generation'] as num?)?.toInt() ?? 0;
      }

      final sdp = payload['sdp']?.toString() ?? '';
      final type = payload['type']?.toString() ?? 'answer';
      if (sdp.isNotEmpty) {
        final dto = VoiceCallRtcOfferAnswerDto(
          type: type,
          sdp: sdp,
          callId: callId,
          messageId: messageId,
          generation: generation,
        );
        _diag('RtcAnswer', 'Received answer (type: $type, sdpLen: ${sdp.length})', callId: callId, gen: generation);
        _answerController.add(dto);
      }
    } catch (e) {
      _diag('RtcAnswer', 'Error parsing rtc:answer: $e');
    }
  }

  void _handleRtcIce(List<Object?>? args) {
    if (args == null || args.isEmpty) return;
    try {
      String callId = '';
      Map<String, dynamic> payload = {};
      String messageId = '';
      int generation = 0;

      if (args.length >= 4) {
        callId = args[0]?.toString() ?? '';
        payload = _extractMap(args[1]);
        messageId = args[2]?.toString() ?? '';
        generation = (args[3] as num?)?.toInt() ?? 0;
      } else {
        payload = _extractMap(args.first);
        callId = payload['callId']?.toString() ?? '';
        messageId = payload['messageId']?.toString() ?? '';
        generation = (payload['generation'] as num?)?.toInt() ?? 0;
      }

      final candidate = VoiceCallRtcCandidateDto.fromJson(
        payload,
        callId: callId.isNotEmpty ? callId : null,
        messageId: messageId.isNotEmpty ? messageId : null,
        generation: generation,
      );
      if (candidate.candidate.isNotEmpty) {
        _diag('RtcIce', 'Received candidate (len: ${candidate.candidate.length})', callId: callId, gen: generation);
        _iceController.add(candidate);
      }
    } catch (e) {
      _diag('RtcIce', 'Error parsing rtc:ice-candidate: $e');
    }
  }

  Map<String, dynamic> _extractMap(Object? raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) {
      return raw.map((k, v) => MapEntry(k.toString(), v));
    }
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map) {
          return decoded.map((k, v) => MapEntry(k.toString(), v));
        }
      } catch (_) {}
    }
    return {};
  }

  Future<void> bindDeviceSession() async {
    final sessionId = sessionStorage.getDeviceSessionId();
    if (sessionId == null || sessionId.isEmpty) {
      _diag('Bind', 'Cannot bind: deviceSessionId is empty');
      return;
    }
    final controlProof = await sessionStorage.getControlProof();
    if (controlProof == null || controlProof.isEmpty) {
      _diag('Bind', 'Cannot bind: controlProof is empty');
      return;
    }
    if (!isConnected) {
      _diag('Bind', 'Cannot bind: SignalR not connected');
      return;
    }

    try {
      _diag('Bind', 'Invoking BindDeviceSession with sessionId: $sessionId');
      await _hubConnection?.invoke(
        'BindDeviceSession',
        args: [sessionId, controlProof],
      );
      _isBound = true;
      _boundSessionId = sessionId;
      _boundController.add(true);
      _diag('Bind', 'BindDeviceSession succeeded');
    } catch (e) {
      _isBound = false;
      _boundController.add(false);
      _diag('Bind', 'BindDeviceSession failed: $e');
      rethrow;
    }
  }

  Future<void> ensureConnectedAndBound() async {
    if (!isConnected) {
      await connect();
    }
    if (isConnected && !_isBound) {
      await bindDeviceSession();
    }
  }

  Future<void> sendOffer({
    required String callId,
    required String sdp,
    required String messageId,
    int generation = 0,
  }) async {
    await ensureConnectedAndBound();
    if (!isConnected || !_isBound) {
      throw StateError('Cannot send offer: SignalR not connected or bound');
    }

    final sdpBytes = utf8.encode(sdp).length;
    if (sdpBytes > 65536) {
      _diag('SendOffer', 'SDP offer exceeds 65536 bytes limit ($sdpBytes bytes)', callId: callId, gen: generation);
      throw ArgumentError('SDP offer exceeds 65536 bytes limit');
    }

    final payload = {
      'type': 'offer',
      'sdp': sdp,
    };
    _diag('SendOffer', 'Invoking SendOffer (sdpBytes: $sdpBytes)', callId: callId, gen: generation);
    await _hubConnection?.invoke(
      'SendOffer',
      args: [callId, payload, messageId, generation],
    );
  }

  Future<void> sendAnswer({
    required String callId,
    required String sdp,
    required String messageId,
    int generation = 0,
  }) async {
    await ensureConnectedAndBound();
    if (!isConnected || !_isBound) {
      throw StateError('Cannot send answer: SignalR not connected or bound');
    }

    final sdpBytes = utf8.encode(sdp).length;
    if (sdpBytes > 65536) {
      _diag('SendAnswer', 'SDP answer exceeds 65536 bytes limit ($sdpBytes bytes)', callId: callId, gen: generation);
      throw ArgumentError('SDP answer exceeds 65536 bytes limit');
    }

    final payload = {
      'type': 'answer',
      'sdp': sdp,
    };
    _diag('SendAnswer', 'Invoking SendAnswer (sdpBytes: $sdpBytes)', callId: callId, gen: generation);
    await _hubConnection?.invoke(
      'SendAnswer',
      args: [callId, payload, messageId, generation],
    );
  }

  Future<void> sendIceCandidate({
    required String callId,
    required String candidate,
    String? sdpMid,
    int? sdpMLineIndex,
    String? usernameFragment,
    required String messageId,
    int generation = 0,
  }) async {
    await ensureConnectedAndBound();
    if (!isConnected || !_isBound) {
      _diag('SendIceCandidate', 'Dropped candidate: hub not connected or bound', callId: callId, gen: generation);
      return;
    }
    if (candidate.trim().isEmpty) return;

    final candidateBytes = utf8.encode(candidate).length;
    if (candidateBytes > 4096) {
      _diag('SendIceCandidate', 'ICE candidate exceeds 4096 bytes limit ($candidateBytes bytes)', callId: callId, gen: generation);
      return;
    }

    final payload = {
      'candidate': candidate,
      'sdpMid': ?sdpMid,
      'sdpMLineIndex': ?sdpMLineIndex,
      'usernameFragment': ?usernameFragment,
    };

    try {
      _diag('SendIceCandidate', 'Invoking SendIceCandidate (bytes: $candidateBytes)', callId: callId, gen: generation);
      await _hubConnection?.invoke(
        'SendIceCandidate',
        args: [callId, payload, messageId, generation],
      );
    } catch (e) {
      _diag('SendIceCandidate', 'Failed to send ICE candidate: $e', callId: callId, gen: generation);
    }
  }

  void resetSequenceAndDedupe() {
    _lastCommittedSequence = -1;
    _processedEventIds.clear();
  }

  Future<void> disconnect() async {
    _isBound = false;
    _boundSessionId = null;
    if (_hubConnection != null) {
      try {
        await _hubConnection?.stop();
      } catch (_) {}
    }
    _boundController.add(false);
    _connectionStatusController.add(false);
  }

  Future<void> dispose() async {
    _isDisposed = true;
    await disconnect();
    await _envelopeController.close();
    await _offerController.close();
    await _answerController.close();
    await _iceController.close();
    await _connectionStatusController.close();
    await _boundController.close();
  }

  void _diag(String action, String details, {String? callId, int? seq, int? gen}) {
    final c = callId != null && callId.isNotEmpty ? '[$callId]' : '[no-call]';
    final g = gen != null ? '[gen:$gen]' : '';
    final s = seq != null ? '[seq:$seq]' : '';
    developer.log('[VoiceDiag]$c$g$s $action: $details');
  }
}
