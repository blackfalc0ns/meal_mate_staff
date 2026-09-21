import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/config/theme/spacing.dart';
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

  testWidgets(
    'renders prefix calendar icon on the right in RTL with no picker arrow',
    (tester) async {
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
    },
  );

  testWidgets(
    'renders picker arrow when showPickerArrow is true or default with no prefix',
    (tester) async {
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
    },
  );

  testWidgets('picker field triggers onTap cleanly without gaining text focus', (tester) async {
    bool tapped = false;
    final focusNode = FocusNode();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 360,
              child: RegistrationInputField(
                label: 'تاريخ انتهاء الهوية',
                hint: 'اختر تاريخ انتهاء الهوية',
                isPicker: true,
                focusNode: focusNode,
                onTap: () {
                  tapped = true;
                },
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(TextFormField));
    await tester.pump();

    expect(tapped, isTrue);
    expect(focusNode.hasFocus, isFalse);
  });

  group('RegistrationInputField height tests', () {
    testWidgets('scenario 1: plain text field keeps 40px input container on error', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: Form(
                  key: formKey,
                  child: RegistrationInputField(
                    label: 'الاسم',
                    hint: 'أدخل الاسم',
                    validator: (v) => 'هذا الحقل مطلوب',
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final heightBefore = tester.getSize(find.byType(TextFormField)).height;
      expect(heightBefore, Spacing.registrationFieldInputHeight);

      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      final heightAfter = tester.getSize(find.byType(TextFormField)).height;
      expect(heightAfter, greaterThan(Spacing.registrationFieldInputHeight));
      expect(find.text('هذا الحقل مطلوب'), findsOneWidget);
    });

    testWidgets('scenario 2: field with prefixIcon keeps 40px input container on error', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: Form(
                  key: formKey,
                  child: RegistrationInputField(
                    label: 'تاريخ الميلاد',
                    hint: 'اختر تاريخ الميلاد',
                    prefixIcon: Icons.calendar_month_rounded,
                    showPickerArrow: false,
                    isPicker: true,
                    validator: (v) => 'هذا الحقل مطلوب',
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final heightBefore = tester.getSize(find.byType(TextFormField)).height;
      expect(heightBefore, Spacing.registrationFieldInputHeight);

      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      final heightAfter = tester.getSize(find.byType(TextFormField)).height;
      expect(heightAfter, greaterThan(Spacing.registrationFieldInputHeight));
      expect(find.text('هذا الحقل مطلوب'), findsOneWidget);
    });

    testWidgets('scenario 3: field with picker arrow keeps 40px input container on error', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: Form(
                  key: formKey,
                  child: RegistrationInputField(
                    label: 'الجنسية',
                    hint: 'اختر الجنسية',
                    isPicker: true,
                    validator: (v) => 'هذا الحقل مطلوب',
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final heightBefore = tester.getSize(find.byType(TextFormField)).height;
      expect(heightBefore, Spacing.registrationFieldInputHeight);

      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      final heightAfter = tester.getSize(find.byType(TextFormField)).height;
      expect(heightAfter, greaterThan(Spacing.registrationFieldInputHeight));
      expect(find.text('هذا الحقل مطلوب'), findsOneWidget);
    });

    testWidgets('scenario 4: field with suffixIcon keeps 40px input container on error', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: Form(
                  key: formKey,
                  child: RegistrationInputField(
                    label: 'كلمة المرور',
                    hint: 'أدخل كلمة المرور',
                    suffixIcon: Icons.visibility,
                    validator: (v) => 'هذا الحقل مطلوب',
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final heightBefore = tester.getSize(find.byType(TextFormField)).height;
      expect(heightBefore, Spacing.registrationFieldInputHeight);

      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      final heightAfter = tester.getSize(find.byType(TextFormField)).height;
      expect(heightAfter, greaterThan(Spacing.registrationFieldInputHeight));
      expect(find.text('هذا الحقل مطلوب'), findsOneWidget);
    });

    testWidgets('scenario 5: field with prefix stays aligned at top on error', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 360,
                child: Form(
                  key: formKey,
                  child: RegistrationInputField(
                    label: 'رقم الهاتف',
                    hint: 'أدخل رقم الهاتف',
                    prefix: '+965',
                    validator: (v) => 'هذا الحقل مطلوب',
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final prefixBoxFinder = find.byWidgetPredicate(
        (w) =>
            w is SizedBox &&
            w.height == Spacing.registrationFieldInputHeight &&
            w.width == Spacing.xxxl * 2,
      );
      final prefixTopBefore = tester.getTopLeft(prefixBoxFinder).dy;
      final fieldTopBefore = tester.getTopLeft(find.byType(TextFormField)).dy;
      expect(prefixTopBefore, equals(fieldTopBefore));

      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      final prefixTopAfter = tester.getTopLeft(prefixBoxFinder).dy;
      final fieldTopAfter = tester.getTopLeft(find.byType(TextFormField)).dy;
      expect(prefixTopAfter, equals(fieldTopAfter));
    });
  });
}
