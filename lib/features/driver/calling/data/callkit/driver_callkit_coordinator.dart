import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class DriverCallKitCoordinator {
  DriverCallKitCoordinator();

  final _actionController = StreamController<String>.broadcast();
  Stream<String> get onCallKitAction => _actionController.stream;

  StreamSubscription<CallEvent?>? _eventSubscription;
  String? _activeCallId;

  void initialize() {
    unawaited(_eventSubscription?.cancel());
    _eventSubscription = FlutterCallkitIncoming.onEvent.listen((event) {
      if (event == null) return;
      _log('CallKit event received: ${event.eventName}');
      switch (event) {
        case CallEventActionCallDecline() ||
             CallEventActionCallEnded() ||
             CallEventActionCallTimeout():
          _actionController.add('end');
        case CallEventActionCallToggleMute():
          _actionController.add('mute');
        default:
          break;
      }
    });
  }

  Future<void> startOutgoingCall({
    required String callId,
    required String customerName,
    String? handle,
  }) async {
    _activeCallId = callId;
    final params = CallKitParams(
      id: callId,
      nameCaller: customerName,
      appName: 'MealMate Driver',
      avatar: 'assets/images/driver/avatar.png',
      handle: handle ?? customerName,
      type: 0, // audio call
      duration: 30000,
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
  }

  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    await _actionController.close();
  }

  void _log(String message) {
    developer.log('[DriverCallKit] $message');
  }
}
