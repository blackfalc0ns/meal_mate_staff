import 'package:flutter_test/flutter_test.dart';
import 'package:driver_voice_engine/driver_voice_engine.dart';
import 'package:driver_voice_engine/src/call_state_reducer.dart';

void main() {
  group('CallStateReducer race and edge cases', () {
    late CallStateReducer reducer;

    setUp(() {
      reducer = CallStateReducer(engineInstanceId: 'inst-123');
    });

    test('Initial snapshot has expected default fields and revision 1', () {
      final initial = reducer.createInitial(
        operationId: 'op-1',
        tripStopId: 'stop-1',
        callId: 'call-1',
      );

      expect(initial.schemaVersion, 1);
      expect(initial.engineInstanceId, 'inst-123');
      expect(initial.localRevision, 1);
      expect(initial.serverStatus, DriverVoiceServerCallStatus.created);
      expect(initial.mediaState, DriverVoiceMediaState.preparing);
      expect(initial.isTerminal, isFalse);
    });

    test('Duplicate events with same eventId are dropped', () {
      final initial = reducer.createInitial(
        operationId: 'op-1',
        tripStopId: 'stop-1',
        callId: 'call-1',
      );

      final next1 = reducer.onServerEvent(
        current: initial,
        eventId: 'evt-100',
        sequence: 1,
        newStatus: DriverVoiceServerCallStatus.ringing,
      );
      expect(next1, isNotNull);
      expect(next1!.serverStatus, DriverVoiceServerCallStatus.ringing);
      expect(next1.localRevision, 2);

      // Same eventId again -> must return null
      final duplicate = reducer.onServerEvent(
        current: next1,
        eventId: 'evt-100',
        sequence: 1,
        newStatus: DriverVoiceServerCallStatus.ringing,
      );
      expect(duplicate, isNull);
    });

    test('Reversed or stale sequence is dropped', () {
      final initial = reducer.createInitial(
        operationId: 'op-1',
        tripStopId: 'stop-1',
        callId: 'call-1',
      );

      final step1 = reducer.onServerEvent(
        current: initial,
        eventId: 'evt-1',
        sequence: 5,
        newStatus: DriverVoiceServerCallStatus.ringing,
      );
      expect(step1, isNotNull);
      expect(step1!.serverSequence, 5);

      // Stale event with sequence 4 arrives later -> must be dropped
      final stale = reducer.onServerEvent(
        current: step1,
        eventId: 'evt-2',
        sequence: 4,
        newStatus: DriverVoiceServerCallStatus.accepted,
      );
      expect(stale, isNull);
    });

    test('End-during-start transitions to cancelled with serverEndPending = true', () {
      final initial = reducer.createInitial(
        operationId: 'op-1',
        tripStopId: 'stop-1',
        callId: 'call-1',
      );

      final hungUp = reducer.onUserHangUp(current: initial);
      expect(hungUp.isTerminal, isTrue);
      expect(hungUp.serverStatus, DriverVoiceServerCallStatus.cancelled);
      expect(hungUp.mediaState, DriverVoiceMediaState.disconnected);
      expect(hungUp.serverEndPending, isTrue);
      expect(hungUp.terminationReason, DriverVoiceTerminationReason.localHangup);

      // Acknowledging server end clears serverEndPending
      final acked = reducer.onServerEndAcknowledged(current: hungUp);
      expect(acked.serverEndPending, isFalse);
    });

    test('Terminal-then-active: late active event is dropped when call is already terminal', () {
      final initial = reducer.createInitial(
        operationId: 'op-1',
        tripStopId: 'stop-1',
        callId: 'call-1',
      );

      final ended = reducer.onServerEvent(
        current: initial,
        eventId: 'evt-end',
        sequence: 2,
        newStatus: DriverVoiceServerCallStatus.ended,
      );
      expect(ended, isNotNull);
      expect(ended!.isTerminal, isTrue);

      // Late active event arrives
      final lateActive = reducer.onServerEvent(
        current: ended,
        eventId: 'evt-late-active',
        sequence: 3,
        newStatus: DriverVoiceServerCallStatus.active,
      );
      expect(lateActive, isNull);
    });

    test('Old-generation Answer and ICE are rejected', () {
      final initial = reducer.createInitial(
        operationId: 'op-1',
        tripStopId: 'stop-1',
        callId: 'call-1',
      );

      final ansGen1 = reducer.onRemoteAnswer(current: initial, generation: 1);
      expect(ansGen1, isNotNull);
      expect(ansGen1!.generation, 1);

      // Old answer for gen 0 -> must be null
      final oldAns = reducer.onRemoteAnswer(current: ansGen1, generation: 0);
      expect(oldAns, isNull);

      // ICE candidate for gen 0 -> must not be allowed
      expect(reducer.isIceCandidateAllowed(current: ansGen1, generation: 0), isFalse);
      // ICE candidate for gen 1 -> allowed
      expect(reducer.isIceCandidateAllowed(current: ansGen1, generation: 1), isTrue);
    });

    test('Repeated hangup is idempotent', () {
      final initial = reducer.createInitial(
        operationId: 'op-1',
        tripStopId: 'stop-1',
        callId: 'call-1',
      );

      final hungUp1 = reducer.onUserHangUp(current: initial);
      final hungUp2 = reducer.onUserHangUp(current: hungUp1);

      expect(hungUp2.localRevision, hungUp1.localRevision);
      expect(hungUp2.terminationReason, hungUp1.terminationReason);
    });

    test('Mute and audio route change increment localRevision without changing serverSequence', () {
      final initial = reducer.createInitial(
        operationId: 'op-1',
        tripStopId: 'stop-1',
        callId: 'call-1',
      );

      final muted = reducer.onMuteChanged(current: initial, muted: true);
      expect(muted.muted, isTrue);
      expect(muted.localRevision, initial.localRevision + 1);
      expect(muted.serverSequence, initial.serverSequence);

      final speaker = reducer.onAudioRouteChanged(
        current: muted,
        route: DriverVoiceAudioRoute.speaker,
      );
      expect(speaker.audioRoute, DriverVoiceAudioRoute.speaker);
      expect(speaker.localRevision, muted.localRevision + 1);
      expect(speaker.serverSequence, initial.serverSequence);
    });
  });
}
