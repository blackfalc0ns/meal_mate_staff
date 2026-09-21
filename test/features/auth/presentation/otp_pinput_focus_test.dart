import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/auth/domain/auth_verification_target.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';
import 'package:meal_mate_delivery/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
  });

  testWidgets(
    'OtpVerificationScreen maintains focus when keyboard opens (viewInsets change)',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          locale: Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: OtpVerificationScreen.phone(
            target: AuthVerificationTarget(
              value: '+96599777222',
              imageAsset: AppAssets.authPhoneOtp,
            ),
            role: UserRole.operations,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Pinput
      final pinputFinder = find.byType(Pinput);
      expect(pinputFinder, findsOneWidget);

      await tester.tap(pinputFinder);
      await tester.pump();

      final editableTextFinder = find.byType(EditableText);
      expect(editableTextFinder, findsOneWidget);
      var editableText = tester.widget<EditableText>(editableTextFinder);
      expect(editableText.focusNode.hasFocus, isTrue);

      // Simulate keyboard opening: viewInsets change
      tester.view.viewInsets = const FakeViewPadding(bottom: 800);
      addTearDown(tester.view.resetViewInsets);
      await tester.pump();

      editableText = tester.widget<EditableText>(editableTextFinder);
      expect(editableText.focusNode.hasFocus, isTrue);

      // Wait 1 second
      await tester.pump(const Duration(seconds: 1));
      editableText = tester.widget<EditableText>(editableTextFinder);
      expect(editableText.focusNode.hasFocus, isTrue);
    },
  );
}
