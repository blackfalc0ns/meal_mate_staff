import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/helpers/validators.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';

void main() {
  group('Validations Unit Tests (without context fallback)', () {
    test('validateRequired works without context', () {
      expect(Validations.validateRequired(null, ''), 'This field is required');
      expect(Validations.validateRequired(null, 'valid text'), isNull);
    });

    test('validatePhoneNumber works without context', () {
      expect(
        Validations.validatePhoneNumber(null, ''),
        'Phone number is required',
      );
      expect(
        Validations.validatePhoneNumber(null, '123'),
        'Phone number is not valid',
      );
      expect(Validations.validatePhoneNumber(null, '+96598765432'), isNull);
    });

    test('validatePassword works without context', () {
      expect(Validations.validatePassword(null, ''), 'Password is required');
      expect(
        Validations.validatePassword(null, 'weak'),
        'Password must include 8 characters, a number, uppercase letter, and symbol',
      );
      expect(Validations.validatePassword(null, 'P@ssw0rd123'), isNull);
    });

    test('validateConfirmPassword works without context', () {
      expect(
        Validations.validateConfirmPassword(null, 'pass', ''),
        'Confirm password is required',
      );
      expect(
        Validations.validateConfirmPassword(null, 'pass1', 'pass2'),
        'Passwords do not match',
      );
      expect(Validations.validateConfirmPassword(null, 'pass', 'pass'), isNull);
    });

    test('validateEmail works without context', () {
      expect(Validations.validateEmail(null, ''), 'Email is required');
      expect(Validations.validateEmail(null, 'invalid'), 'Email is not valid');
      expect(Validations.validateEmail(null, 'driver@mealmate.com'), isNull);
    });

    test(
      'optional email accepts empty values and validates non-empty values',
      () {
        expect(Validations.validateOptionalEmail(null, ''), isNull);
        expect(
          Validations.validateOptionalEmail(null, 'driver@example.com'),
          isNull,
        );
        expect(
          Validations.validateOptionalEmail(null, 'not-an-email'),
          isNotNull,
        );
      },
    );

    test('national ID accepts only 10 to 14 digits', () {
      expect(Validations.validateNationalId(null, '1234567890'), isNull);
      expect(Validations.validateNationalId(null, '12345678901234'), isNull);
      expect(Validations.validateNationalId(null, '123456789'), isNotNull);
      expect(
        Validations.validateNationalId(null, '123456789012345'),
        isNotNull,
      );
      expect(Validations.validateNationalId(null, '123456789A'), isNotNull);
    });

    test('identity expiry must be a future date', () {
      expect(Validations.validateFutureDate(null, '2099-01-01'), isNull);
      expect(Validations.validateFutureDate(null, '2000-01-01'), isNotNull);
      expect(Validations.validateFutureDate(null, ''), isNotNull);
    });

    test('future date rejects noon on the local calendar date today', () {
      final now = DateTime.now();
      final noonToday = DateTime(
        now.year,
        now.month,
        now.day,
        12,
      ).toIso8601String();

      expect(Validations.validateFutureDate(null, noonToday), isNotNull);
    });

    test('manufacturing year accepts only 1990 through next year', () {
      expect(
        Validations.validateManufactureYear(null, '1989', currentYear: 2026),
        isNotNull,
      );
      expect(
        Validations.validateManufactureYear(null, '1990', currentYear: 2026),
        isNull,
      );
      expect(
        Validations.validateManufactureYear(null, '2027', currentYear: 2026),
        isNull,
      );
      expect(
        Validations.validateManufactureYear(null, '2028', currentYear: 2026),
        isNotNull,
      );
    });

    test('optional future date accepts blank but rejects today and past', () {
      final today = DateTime.now();
      final todayIso = DateTime(
        today.year,
        today.month,
        today.day,
      ).toIso8601String();

      expect(Validations.validateOptionalFutureDate(null, ''), isNull);
      expect(Validations.validateOptionalFutureDate(null, todayIso), isNotNull);
      expect(
        Validations.validateOptionalFutureDate(null, '2000-01-01'),
        isNotNull,
      );
      expect(
        Validations.validateOptionalFutureDate(null, '2099-01-01'),
        isNull,
      );
    });

    test('validOtp works without context', () {
      expect(Validations.validOtp(null, ''), 'Verification code is required');
      expect(Validations.validOtp(null, '12'), 'Verification code is invalid');
      expect(Validations.validOtp(null, '123456'), isNull);
    });
  });

  group('Validations Localization Tests (Arabic & English)', () {
    Widget buildTestApp({required Locale locale, required Widget child}) {
      return MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );
    }

    testWidgets('returns Arabic error messages when locale is Arabic', (
      tester,
    ) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('ar'),
          child: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        Validations.validateRequired(capturedContext, ''),
        'هذا الحقل مطلوب',
      );
      expect(
        Validations.validatePhoneNumber(capturedContext, ''),
        'رقم الهاتف مطلوب',
      );
      expect(
        Validations.validatePhoneNumber(capturedContext, '123'),
        'رقم الهاتف غير صالح',
      );
      expect(
        Validations.validatePassword(capturedContext, ''),
        'كلمة المرور مطلوبة',
      );
      expect(
        Validations.validatePassword(capturedContext, 'weak'),
        'يجب أن تحتوي كلمة المرور على 8 خانات، ورقم، وحرف كبير، ورمز',
      );
      expect(
        Validations.validateConfirmPassword(capturedContext, 'pass1', 'pass2'),
        'كلمتا المرور غير متطابقتين',
      );
      expect(Validations.validOtp(capturedContext, ''), 'رمز التحقق مطلوب');
      expect(
        Validations.validOtp(capturedContext, '12'),
        'رمز التحقق غير صالح',
      );
      expect(
        Validations.validateCivilId(capturedContext, ''),
        'الرقم المدني مطلوب',
      );

      // Test context extensions
      expect(capturedContext.validateRequired(''), 'هذا الحقل مطلوب');
      expect(capturedContext.validatePhoneNumber(''), 'رقم الهاتف مطلوب');
    });

    testWidgets('returns English error messages when locale is English', (
      tester,
    ) async {
      late BuildContext capturedContext;

      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('en'),
          child: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        Validations.validateRequired(capturedContext, ''),
        'This field is required',
      );
      expect(
        Validations.validatePhoneNumber(capturedContext, ''),
        'Phone number is required',
      );
      expect(
        Validations.validatePhoneNumber(capturedContext, '123'),
        'Phone number is not valid',
      );
      expect(
        Validations.validatePassword(capturedContext, ''),
        'Password is required',
      );
      expect(
        Validations.validateConfirmPassword(capturedContext, 'pass1', 'pass2'),
        'Passwords do not match',
      );
      expect(
        Validations.validOtp(capturedContext, ''),
        'Verification code is required',
      );
      expect(
        Validations.validOtp(capturedContext, '12'),
        'Verification code is invalid',
      );

      // Test context extensions
      expect(capturedContext.validateRequired(''), 'This field is required');
      expect(
        capturedContext.validatePhoneNumber(''),
        'Phone number is required',
      );
    });
  });
}
