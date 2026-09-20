import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/arguments/auth_route_arguments.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/app_shell/screens/app_shell_screen.dart';
import 'package:meal_mate_delivery/core/constants/assets.dart';
import 'package:meal_mate_delivery/core/di/di.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/account_status/domain/account_status_kind.dart';
import 'package:meal_mate_delivery/features/account_status/presentation/screens/account_status_screen.dart';
import 'package:meal_mate_delivery/features/auth/domain/auth_verification_target.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';
import 'package:meal_mate_delivery/features/auth/presentation/screens/login_screen.dart';
import 'package:meal_mate_delivery/features/auth/presentation/screens/otp_verification_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/presentation/screens/dispatcher_home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await configureDependencies();
  });

  Widget buildRouteApp(String route, {Object? arguments}) {
    return MaterialApp(
      locale: const Locale('ar'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      initialRoute: route,
      onGenerateRoute: (settings) {
        if (settings.name == route && arguments != null) {
          return RouteGenerator.getRoute(
            RouteSettings(name: route, arguments: arguments),
          );
        }
        return RouteGenerator.getRoute(settings);
      },
    );
  }

  group('Typed Auth Route Tests', () {
    testWidgets('Login route with LoginRouteArgs passes role to LoginScreen', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildRouteApp(
          AppRoutes.login,
          arguments: const LoginRouteArgs(role: UserRole.driver),
        ),
      );
      await tester.pump();

      final loginScreen = tester.widget<LoginScreen>(find.byType(LoginScreen));
      expect(loginScreen.role, UserRole.driver);
    });

    testWidgets(
      'VerifyPhoneOtp route with OtpVerificationRouteArgs sets target and role',
      (tester) async {
        const target = AuthVerificationTarget(
          value: '+96550123456',
          imageAsset: AppAssets.authPhoneOtp,
        );

        await tester.pumpWidget(
          buildRouteApp(
            AppRoutes.verifyPhoneOtp,
            arguments: const OtpVerificationRouteArgs(
              target: target,
              role: UserRole.driver,
            ),
          ),
        );
        await tester.pump();

        final otpScreen = tester.widget<OtpVerificationScreen>(
          find.byType(OtpVerificationScreen),
        );
        expect(otpScreen.target.value, '+96550123456');
        expect(otpScreen.role, UserRole.driver);
      },
    );

    testWidgets('AccountStatus route with AccountStatusRouteArgs passes kind', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildRouteApp(
          AppRoutes.accountStatus,
          arguments: const AccountStatusRouteArgs(
            kind: AccountStatusKind.moreInformationRequired,
            registrationId: 'reg-123',
          ),
        ),
      );
      await tester.pumpAndSettle();

      final statusScreen = tester.widget<AccountStatusScreen>(
        find.byType(AccountStatusScreen),
      );
      expect(statusScreen.kind, AccountStatusKind.moreInformationRequired);
    });

    testWidgets(
      'AppShell route with AppShellRouteArgs routes to driver shell',
      (tester) async {
        await tester.pumpWidget(
          buildRouteApp(
            AppRoutes.appShell,
            arguments: const AppShellRouteArgs(
              role: UserRole.driver,
              initialIndex: 0,
            ),
          ),
        );
        await tester.pump();

        final shell = tester.widget<AppShellScreen>(
          find.byType(AppShellScreen),
        );
        expect(shell.role, UserRole.driver);
      },
    );

    testWidgets(
      'AppShell route with AppShellRouteArgs routes to dispatcher shell',
      (tester) async {
        await tester.pumpWidget(
          buildRouteApp(
            AppRoutes.appShell,
            arguments: const AppShellRouteArgs(
              role: UserRole.operations,
              initialIndex: 0,
            ),
          ),
        );
        await tester.pump();

        final shell = tester.widget<AppShellScreen>(
          find.byType(AppShellScreen),
        );
        expect(shell.role, UserRole.operations);
        expect(find.byType(DispatcherHomeScreen), findsOneWidget);
      },
    );
  });
}
