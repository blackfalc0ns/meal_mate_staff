import 'package:flutter/material.dart';

import '../../core/app_shell/screens/app_shell_screen.dart';
import '../../features/account_status/domain/account_status_kind.dart';
import '../../features/account_status/presentation/screens/account_status_preview_screen.dart';
import '../../features/account_status/presentation/screens/account_status_screen.dart';
import '../../features/auth/data/auth_fake_data.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dispatcher/orders/presentation/screens/dispatcher_orders_screen.dart';
import '../../features/register/presentation/screens/register_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  const RouteGenerator._();

  static Route<dynamic> getRoute(RouteSettings settings) {
    final builder = switch (settings.name) {
      AppRoutes.splash => (_) => const SplashScreen(),
      AppRoutes.appShell || AppRoutes.home => (_) => const AppShellScreen(),
      AppRoutes.login => (_) => const LoginScreen(),
      AppRoutes.verifyPhoneOtp => (_) => const OtpVerificationScreen.phone(
        target: AuthFakeData.phoneVerificationTarget,
      ),
      AppRoutes.verifyEmailOtp => (_) => const OtpVerificationScreen.email(
        target: AuthFakeData.emailVerificationTarget,
      ),
      AppRoutes.register => (_) => const RegisterScreen(),
      AppRoutes.accountStatus => (_) => AccountStatusScreen(
        kind: settings.arguments is AccountStatusKind
            ? settings.arguments! as AccountStatusKind
            : AccountStatusKind.underReview,
      ),
      AppRoutes.accountStatusPreview =>
        (_) => const AccountStatusPreviewScreen(),
      AppRoutes.dispatcherOrders => (_) => const DispatcherOrdersScreen(),
      _ => (_) => const SplashScreen(),
    };

    return MaterialPageRoute<void>(settings: settings, builder: builder);
  }
}
