import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DriverCallKitCoordinator {
  DriverCallKitCoordinator({
    Stream<CallEvent?>? eventStream,
  }) : _providedEventStream = eventStream;

  final Stream<CallEvent?>? _providedEventStream;
  final _actionController = StreamController<String>.broadcast();
  Stream<String> get onCallKitAction => _actionController.stream;

  StreamSubscription<CallEvent?>? _eventSubscription;
  String? _activeCallId;
  final Set<String> _suppressedCallIds = <String>{};

  void initialize() {
    unawaited(_eventSubscription?.cancel());
    final stream = _providedEventStream ?? FlutterCallkitIncoming.onEvent;
    _eventSubscription = stream.listen((event) {
      if (event == null) return;
      _log('CallKit event received: ${event.eventName}');

      final eventCallId = _extractCallId(event) ?? _activeCallId;
      if (eventCallId != null && _suppressedCallIds.contains(eventCallId)) {
        _log('Ignoring CallKit action for programmatically closed callId: $eventCallId');
        return;
      }

      switch (event) {
        case CallEventActionCallDecline() ||
             CallEventActionCallEnded():
          _actionController.add('end');
        case CallEventActionCallTimeout():
          _actionController.add('timeout');
        case CallEventActionCallToggleMute():
          _actionController.add('mute');
        default:
          break;
      }
    });
  }

  String? _extractCallId(CallEvent event) {
    try {
      final dynamic dyn = event;
      final callKitParams = dyn.callKitParams;
      if (callKitParams != null) {
        if (callKitParams is CallKitParams) return callKitParams.id;
        if (callKitParams is Map) return (callKitParams['id'] ?? callKitParams['callId'])?.toString();
      }
      final params = dyn.params;
      if (params != null) {
        if (params is CallKitParams) return params.id;
        if (params is Map) return (params['id'] ?? params['callId'])?.toString();
      }
      final id = dyn.id ?? dyn.callId;
      if (id != null) return id.toString();
      final body = dyn.body;
      if (body != null) {
        if (body is Map) return (body['id'] ?? body['callId'])?.toString();
        if (body is String) return body;
      }
    } catch (_) {}
    return null;
  }

  Future<void> startOutgoingCall({
    required String callId,
    required String customerName,
    required Duration ringTimeout,
    String? handle,
  }) async {
    _activeCallId = callId;
    _suppressedCallIds.remove(callId);

    final durationMs = ringTimeout.inMilliseconds > 0 ? ringTimeout.inMilliseconds : 30000;
    final params = CallKitParams(
      id: callId,
      nameCaller: customerName,
      appName: 'MealMate Driver',
      avatar: 'assets/images/driver/avatar.png',
      handle: handle ?? customerName,
      type: 0, // audio call
      duration: durationMs,
      extra: <String, dynamic>{'callId': callId},
      headers: <String, dynamic>{'apiKey': 'mealmate'},
      android: const AndroidParams(
        isCustomNotification: true,
        isShowLogo: false,
        ringtonePath: 'system_ringtone_default',
        backgroundColor: '#095550',
        actionColor: '#4CAF50',
        textColor: '#FFFFFF',
        incomingCallNotificationChannelName: 'Voice Calls',
        missedCallNotificationChannelName: 'Missed Calls',
      ),
      ios: const IOSParams(
        iconName: 'CallKitLogo',
        handleType: 'generic',
        supportsVideo: false,
        maximumCallGroups: 1,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'voiceChat',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: false,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: 'system_ringtone_default',
      ),
    );

    try {
      await FlutterCallkitIncoming.startCall(params);
    } catch (e) {
      _log('Failed to start CallKit outgoing call: $e');
    }
  }

  Future<void> setCallConnected(String callId) async {
    try {
      await FlutterCallkitIncoming.setCallConnected(callId);
    } catch (e) {
      _log('Failed to set CallKit call connected: $e');
    }
  }

  Future<void> endCall(String? callId) async {
    final targetId = callId ?? _activeCallId;
    if (targetId != null) {
      _suppressedCallIds.add(targetId);
      try {
        await FlutterCallkitIncoming.endCall(targetId);
      } catch (e) {
        _log('Failed to end CallKit call: $e');
      }
    }
    try {
      await FlutterCallkitIncoming.endAllCalls();
    } catch (_) {}
    _activeCallId = null;
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (targetId != null) {
        _suppressedCallIds.remove(targetId);
      }
    });
  }

  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    await _actionController.close();
  }

  void _log(String message) {
    developer.log('[DriverCallKit] $message');
  }
}
