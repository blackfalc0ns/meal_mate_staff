import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/voice_call_status.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/driver_return_to_call_bar.dart';

void main() {
  group('DriverReturnToCallBar', () {
    testWidgets('renders shrink widget when call is terminal', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DriverReturnToCallBar(
              callId: 'call-1',
              status: VoiceCallStatus.ended,
              customerName: 'Customer Jane',
            ),
          ),
        ),
      );

      expect(find.byType(InkWell), findsNothing);
      expect(find.text('Customer Jane'), findsNothing);
    });

    testWidgets('renders ringing status when call is ringing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DriverReturnToCallBar(
              callId: 'call-1',
              status: VoiceCallStatus.ringing,
              customerName: 'Customer Jane',
            ),
          ),
        ),
      );

      expect(find.text('Customer Jane'), findsOneWidget);
      expect(find.text('Ringing...'), findsOneWidget);
      expect(find.byIcon(Icons.phone_in_talk), findsOneWidget);
    });

    testWidgets('renders duration when call is active', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DriverReturnToCallBar(
              callId: 'call-1',
              status: VoiceCallStatus.active,
              customerName: 'Customer Jane',
              durationSeconds: 125, // 02:05
            ),
          ),
        ),
      );

      expect(find.text('Customer Jane'), findsOneWidget);
      expect(find.text('02:05'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DriverReturnToCallBar(
              callId: 'call-1',
              status: VoiceCallStatus.active,
              customerName: 'Customer Jane',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
