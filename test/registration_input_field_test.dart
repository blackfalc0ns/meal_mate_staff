import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/features/auth/presentation/widgets/registration_input_field.dart';

void main() {
  testWidgets('uses the full available width when there is no prefix', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: RegistrationInputField(label: 'Name', hint: 'Enter name'),
            ),
          ),
        ),
      ),
    );

    final fieldWidth = tester.getSize(find.byType(TextFormField)).width;

    expect(fieldWidth, 360);
  });
}
