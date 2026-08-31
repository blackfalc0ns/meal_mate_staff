import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/register/presentation/screens/register_screen.dart';

void main() {
  testWidgets(
    'opens under review account status after final registration submit',
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

      await tester.ensureVisible(find.text('Submit acceptance request'));
      await tester.tap(find.text('Submit acceptance request'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Submit acceptance request'));
      await tester.tap(find.text('Submit acceptance request'));
      await tester.pumpAndSettle();

      expect(find.text('Your account is under review'), findsOneWidget);
      expect(find.text('Review order'), findsNothing);
    },
  );
}
