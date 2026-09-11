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

  testWidgets('renders prefix calendar icon on the right in RTL with no picker arrow', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: RegistrationInputField(
                  label: 'تاريخ الميلاد',
                  hint: 'اختر تاريخ الميلاد',
                  isPicker: true,
                  prefixIcon: Icons.calendar_month_rounded,
                  showPickerArrow: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsNothing);

    // In RTL, prefixIcon should be on the right side (start)
    final iconBox = tester.getRect(find.byIcon(Icons.calendar_month_rounded));
    final fieldBox = tester.getRect(find.byType(TextFormField));

    expect(iconBox.center.dx, greaterThan(fieldBox.center.dx));
  });

  testWidgets('renders picker arrow when showPickerArrow is true or default with no prefix', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: RegistrationInputField(
                  label: 'الجنسية',
                  hint: 'اختر الجنسية',
                  isPicker: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.keyboard_arrow_down_rounded), findsOneWidget);
  });
}
