import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/driver_call_avatar.dart';

void main() {
  group('DriverCallAvatar', () {
    testWidgets('renders avatar silhouette and phone badge', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: DriverCallAvatar(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DriverCallAvatar), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byIcon(Icons.phone_rounded), findsOneWidget);
    });
  });
}
