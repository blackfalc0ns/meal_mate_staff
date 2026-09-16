import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/app_shell/screens/app_shell_screen.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';
import 'package:meal_mate_delivery/features/auth/presentation/screens/login_screen.dart';
import 'package:meal_mate_delivery/features/auth/presentation/screens/splash_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/presentation/screens/dispatcher_home_screen.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/screens/driver_assigned_boxes_screen.dart';
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

  testWidgets(
    'navigates to driver app shell when driver role is selected and logged in',
    (tester) async {
      await tester.pumpWidget(buildSplashRouteApp());
      await tester.pump();

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(SplashScreen));
      final locale = getLocale(context);

      // Confirm driver role (default selected)
      await tester.tap(find.text(locale.registrationConfirm));
      await tester.pumpAndSettle();

      final loginScreen = tester.widget<LoginScreen>(find.byType(LoginScreen));
      expect(loginScreen.role, UserRole.driver);

      // Tap Login button
      await tester.tap(find.text(locale.login));
      await tester.pumpAndSettle();

      expect(find.byType(AppShellScreen), findsOneWidget);
      final shellScreen =
          tester.widget<AppShellScreen>(find.byType(AppShellScreen));
      expect(shellScreen.role, UserRole.driver);
      expect(find.byType(DriverAssignedBoxesScreen), findsOneWidget);
    },
  );

  testWidgets(
    'navigates to dispatcher app shell when operations role is selected and logged in',
    (tester) async {
      await tester.pumpWidget(buildSplashRouteApp());
      await tester.pump();

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(SplashScreen));
      final locale = getLocale(context);

      // Select operations role
      await tester.tap(find.text(locale.registrationOpsRole));
      await tester.pumpAndSettle();

      // Tap Confirm
      await tester.tap(find.text(locale.registrationConfirm));
      await tester.pumpAndSettle();

      final loginScreen = tester.widget<LoginScreen>(find.byType(LoginScreen));
      expect(loginScreen.role, UserRole.operations);

      // Tap Login button
      await tester.tap(find.text(locale.login));
      await tester.pumpAndSettle();

      expect(find.byType(AppShellScreen), findsOneWidget);
      final shellScreen =
          tester.widget<AppShellScreen>(find.byType(AppShellScreen));
      expect(shellScreen.role, UserRole.operations);
      expect(find.byType(DispatcherHomeScreen), findsOneWidget);
    },
  );
}
