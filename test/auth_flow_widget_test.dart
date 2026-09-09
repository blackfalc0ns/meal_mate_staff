import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/app_shell/screens/app_shell_screen.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/auth/presentation/screens/login_screen.dart';
import 'package:meal_mate_delivery/features/auth/presentation/screens/splash_screen.dart';
import 'package:meal_mate_delivery/main.dart';

void main() {
  Widget buildSplashRouteApp() {
    return MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: RouteGenerator.getRoute,
    );
  }

  AppLocalizations getLocale(BuildContext context) {
    return AppLocalizations.of(context)!;
  }

  testWidgets('app starts at app shell by default', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(AppShellScreen), findsOneWidget);
  });

  testWidgets('app starts at splash screen when splash route is used', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp(initialRoute: AppRoutes.splash));
    await tester.pump();

    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets(
    'starts at splash screen, shows role selection sheet, and opens login after confirming',
    (tester) async {
      await tester.pumpWidget(buildSplashRouteApp());
      await tester.pump();

      expect(find.byType(SplashScreen), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(SplashScreen));
      final locale = getLocale(context);

      expect(find.text(locale.registrationChooseAccountType), findsOneWidget);
      expect(find.text(locale.registrationDriverRole), findsOneWidget);
      expect(find.text(locale.registrationOpsRole), findsOneWidget);
      expect(find.text(locale.registrationConfirm), findsOneWidget);

      await tester.tap(find.text(locale.registrationConfirm));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    },
  );

  testWidgets(
    'allows switching role to operations representative before confirming',
    (tester) async {
      await tester.pumpWidget(buildSplashRouteApp());
      await tester.pump();

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(SplashScreen));
      final locale = getLocale(context);

      await tester.tap(find.text(locale.registrationOpsRole));
      await tester.pumpAndSettle();

      await tester.tap(find.text(locale.registrationConfirm));
      await tester.pumpAndSettle();

      expect(find.byType(LoginScreen), findsOneWidget);
    },
  );
}
