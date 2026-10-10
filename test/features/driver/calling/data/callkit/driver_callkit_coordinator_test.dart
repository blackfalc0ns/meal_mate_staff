import 'dart:async';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/calling/data/callkit/driver_callkit_coordinator.dart';

void main() {
  late StreamController<CallEvent?> eventController;
  late DriverCallKitCoordinator coordinator;

  setUp(() {
    eventController = StreamController<CallEvent?>.broadcast();
    coordinator = DriverCallKitCoordinator(
      eventStream: eventController.stream,
    );
    coordinator.initialize();
  });

  tearDown(() async {
    await coordinator.dispose();
    await eventController.close();
  });

  group('DriverCallKitCoordinator Event & Suppression Tests', () {
    test('emits "end" on user decline or ended event', () async {
      final actions = <String>[];
      final sub = coordinator.onCallKitAction.listen(actions.add);

      eventController.add(
        const CallEventActionCallEnded(
          CallKitParams(id: 'call-1'),
        ),
      );

      await Future.delayed(Duration.zero);
      expect(actions, ['end']);

      await sub.cancel();
    });

    test('emits "timeout" on CallTimeout event', () async {
      final actions = <String>[];
      final sub = coordinator.onCallKitAction.listen(actions.add);

      eventController.add(
        const CallEventActionCallTimeout(
          'call-1',
        ),
      );

      await Future.delayed(Duration.zero);
      expect(actions, ['timeout']);

      await sub.cancel();
    });

    test('suppresses action for callId closed programmatically', () async {
      final actions = <String>[];
      final sub = coordinator.onCallKitAction.listen(actions.add);

      // Start outgoing call
      await coordinator.startOutgoingCall(
        callId: 'call-1',
        customerName: 'Customer',
        ringTimeout: const Duration(seconds: 30),
      );

      // Programmatic endCall
      await coordinator.endCall('call-1');

      // Native event arrives for call-1 as a result of programmatic close
      eventController.add(
        const CallEventActionCallEnded(
          CallKitParams(id: 'call-1'),
        ),
      );

      await Future.delayed(Duration.zero);
      expect(actions, isEmpty);

      await sub.cancel();
    });
  });
}
