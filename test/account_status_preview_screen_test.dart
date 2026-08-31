import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';

void main() {
  testWidgets('account status preview route renders all four status screens', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        onGenerateRoute: RouteGenerator.getRoute,
        initialRoute: AppRoutes.accountStatusPreview,
      ),
    );

    expect(find.text('Account status'), findsOneWidget);
    expect(find.text('Data changes required'), findsOneWidget);
    expect(find.text('Application rejected'), findsOneWidget);
    expect(find.text('Your account has been accepted!'), findsOneWidget);
  });
}
