import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';
import 'package:meal_mate_delivery/features/auth/presentation/screens/login_screen.dart';
import 'package:meal_mate_delivery/features/register/presentation/screens/register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
  });
  testWidgets('opens first registration step when create account is tapped', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.lightTheme,
        onGenerateRoute: RouteGenerator.getRoute,
        home: const LoginScreen(role: UserRole.driver),
      ),
    );

    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Personal data'), findsWidgets);
  });
}
