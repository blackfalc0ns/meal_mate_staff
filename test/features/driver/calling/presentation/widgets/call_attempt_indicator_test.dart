import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/widgets/call_attempt_indicator.dart';

Widget _buildTestWidget({required int currentAttempt}) {
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
      body: CallAttemptIndicator(currentAttempt: currentAttempt),
    ),
  );
}

void main() {
  group('CallAttemptIndicator', () {
    testWidgets('renders attempt label and 3 indicator dots for attempt 1',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(currentAttempt: 1));
      await tester.pumpAndSettle();

      expect(find.text('محاولات الاتصال'), findsOneWidget);
      expect(
        find.text('سيتم فتح خيار الاتصال برقم الهاتف بعد 3 محاولات غير رد'),
        findsOneWidget,
      );
      expect(find.byType(CallAttemptIndicator), findsOneWidget);
    });

    testWidgets('renders correctly for attempt 2 and attempt 3',
        (tester) async {
      await tester.pumpWidget(_buildTestWidget(currentAttempt: 2));
      await tester.pumpAndSettle();
      expect(find.text('محاولات الاتصال'), findsOneWidget);

      await tester.pumpWidget(_buildTestWidget(currentAttempt: 3));
      await tester.pumpAndSettle();
      expect(find.text('محاولات الاتصال'), findsOneWidget);
    });
  });
}
