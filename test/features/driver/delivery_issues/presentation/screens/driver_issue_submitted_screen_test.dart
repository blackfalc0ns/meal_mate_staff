import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/presentation/screens/driver_issue_submitted_screen.dart';

Widget _buildTestWidget({VoidCallback? onReturnHome}) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('ar'), Locale('en')],
    locale: const Locale('ar'),
    home: DriverIssueSubmittedScreen(
      onReturnHome: onReturnHome,
    ),
  );
}

void main() {
  group('DriverIssueSubmittedScreen', () {
    testWidgets('renders success card and triggers onReturnHome',
        (tester) async {
      bool returnedHome = false;

      await tester.pumpWidget(
        _buildTestWidget(
          onReturnHome: () => returnedHome = true,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تم إرسال البلاغ بنجاح'), findsOneWidget);
      expect(
        find.text(
          'شكراً لتعاونك معنا\nسنقوم بمراجعة البلاغ\nواتخاذ الإجراء اللازم',
        ),
        findsOneWidget,
      );
      expect(find.text('العودة للرئيسية'), findsOneWidget);

      await tester.tap(find.text('العودة للرئيسية'));
      expect(returnedHome, isTrue);
    });
  });
}
