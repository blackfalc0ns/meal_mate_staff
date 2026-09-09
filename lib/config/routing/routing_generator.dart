import 'package:flutter/material.dart';

import '../../core/app_shell/screens/app_shell_screen.dart';
import '../../features/account_status/domain/account_status_kind.dart';
import '../../features/account_status/presentation/screens/account_status_preview_screen.dart';
import '../../features/account_status/presentation/screens/account_status_screen.dart';
import '../../features/auth/data/auth_fake_data.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/dispatcher/assign_box/domain/entities/assign_box_order_entity.dart';
import '../../features/dispatcher/assign_box/presentation/screens/assign_box_screen.dart';
import '../../features/dispatcher/drivers/presentation/screens/dispatcher_drivers_screen.dart';
import '../../features/dispatcher/map/presentation/screens/dispatcher_map_screen.dart';
import '../../features/dispatcher/orders/presentation/screens/dispatcher_orders_screen.dart';
import '../../features/register/presentation/screens/register_screen.dart';
import 'app_routes.dart';

class RouteGenerator {
  const RouteGenerator._();

  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _buildRoute(settings: settings, page: const SplashScreen());

      case AppRoutes.appShell || AppRoutes.home:
        final initialIndex = settings.arguments is int
            ? settings.arguments! as int
            : 0;
        return _buildRoute(
          settings: settings,
          page: AppShellScreen(initialIndex: initialIndex),
        );

      case AppRoutes.login:
        return _buildRoute(settings: settings, page: const LoginScreen());

      case AppRoutes.verifyPhoneOtp:
        return _buildRoute(
          settings: settings,
          page: const OtpVerificationScreen.phone(
            target: AuthFakeData.phoneVerificationTarget,
          ),
        );

      case AppRoutes.verifyEmailOtp:
        return _buildRoute(
          settings: settings,
          page: const OtpVerificationScreen.email(
            target: AuthFakeData.emailVerificationTarget,
          ),
        );

      case AppRoutes.register:
        return _buildRoute(settings: settings, page: const RegisterScreen());

      case AppRoutes.accountStatus:
        final kind = settings.arguments is AccountStatusKind
            ? settings.arguments! as AccountStatusKind
            : AccountStatusKind.underReview;
        return _buildRoute(
          settings: settings,
          page: AccountStatusScreen(kind: kind),
        );

      case AppRoutes.accountStatusPreview:
        return _buildRoute(
          settings: settings,
          page: const AccountStatusPreviewScreen(),
        );

      case AppRoutes.dispatcherOrders:
        return _buildRoute(
          settings: settings,
          page: const DispatcherOrdersScreen(),
        );

      case AppRoutes.dispatcherDrivers:
        return _buildRoute(
          settings: settings,
          page: const DispatcherDriversScreen(),
        );

      case AppRoutes.dispatcherMap:
        return _buildRoute(
          settings: settings,
          page: const DispatcherMapScreen(),
        );

      case AppRoutes.assignBox:
        final order = settings.arguments is AssignBoxOrderEntity
            ? settings.arguments! as AssignBoxOrderEntity
            : null;
        return _buildRoute(
          settings: settings,
          page: AssignBoxScreen(order: order),
        );

      default:
        return _buildRoute(settings: settings, page: const SplashScreen());
    }
  }

  static PageRouteBuilder<dynamic> _buildRoute({
    required RouteSettings settings,
    required Widget page,
  }) {
    return PageRouteBuilder(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 360),
      reverseTransitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, _, _) => page,
      transitionsBuilder: (_, animation, _, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(curvedAnimation),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.08, 0),
              end: Offset.zero,
            ).animate(curvedAnimation),
            child: child,
          ),
        );
      },
    );
  }
}
