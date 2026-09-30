import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/call_attempt_actions.dart';

Widget _buildTestWidget({
  VoidCallback? onCallNow,
  VoidCallback? onCancel,
}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ar'), Locale('en')],
    locale: const Locale('ar'),
    home: Scaffold(
      body: CallAttemptActions(
        onCallNowPressed: onCallNow,
        onCancelPressed: onCancel,
      ),
    ),
  );
}

void main() {
  group('CallAttemptActions', () {
    testWidgets('renders Cancel and Call Now buttons and handles taps',
        (tester) async {
      var callNowTapped = false;
      var cancelTapped = false;

      await tester.pumpWidget(_buildTestWidget(
        onCallNow: () => callNowTapped = true,
        onCancel: () => cancelTapped = true,
      ));
      await tester.pumpAndSettle();

      expect(find.text('اتصل الآن'), findsOneWidget);
      expect(find.text('إلغاء'), findsOneWidget);

      await tester.tap(find.text('اتصل الآن'));
      await tester.pump();
      expect(callNowTapped, isTrue);

      await tester.tap(find.text('إلغاء'));
      await tester.pump();
      expect(cancelTapped, isTrue);
    });
  });
}
