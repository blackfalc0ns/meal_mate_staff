import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/app_shell/screens/app_shell_screen.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/register/presentation/screens/register_screen.dart';

void main() {
  testWidgets(
    'opens accepted account status after registration submit and navigates to app shell on start work',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          theme: AppTheme.lightTheme,
          onGenerateRoute: RouteGenerator.getRoute,
          home: const RegisterScreen(),
        ),
      );

      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Submit acceptance request'));
      await tester.tap(find.text('Submit acceptance request'));
      await tester.pumpAndSettle();

      expect(find.text('Your account has been accepted!'), findsOneWidget);
      expect(find.text('Review order'), findsNothing);

      await tester.ensureVisible(find.text('Start work'));
      await tester.tap(find.text('Start work'));
      await tester.pumpAndSettle();

      expect(find.byType(AppShellScreen), findsOneWidget);
    },
  );
}
