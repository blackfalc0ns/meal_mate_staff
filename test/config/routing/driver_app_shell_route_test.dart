import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/arguments/auth_route_arguments.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/core/app_shell/screens/app_shell_screen.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';

class _MockBuildContext extends Fake implements BuildContext {}

void main() {
  group('Driver App Shell Route', () {
    test('AppRoutes.driverAppShell routes to AppShellScreen with UserRole.driver by default', () {
      final route = RouteGenerator.getRoute(
        const RouteSettings(name: AppRoutes.driverAppShell),
      );

      expect(route, isA<PageRouteBuilder>());
      final pageRoute = route as PageRouteBuilder;
      final screen = pageRoute.pageBuilder(
        _MockBuildContext(),
        const AlwaysStoppedAnimation(1),
        const AlwaysStoppedAnimation(1),
      );
      expect(screen, isA<AppShellScreen>());
      final shellScreen = screen as AppShellScreen;
      expect(shellScreen.role, UserRole.driver);
      expect(shellScreen.initialIndex, 0);
    });

    test('AppRoutes.driverAppShell routes with initialIndex or AppShellRouteArgs', () {
      final routeWithInt = RouteGenerator.getRoute(
        const RouteSettings(
          name: AppRoutes.driverAppShell,
          arguments: 2,
        ),
      );
      final screen1 = (routeWithInt as PageRouteBuilder).pageBuilder(
        _MockBuildContext(),
        const AlwaysStoppedAnimation(1),
        const AlwaysStoppedAnimation(1),
      ) as AppShellScreen;
      expect(screen1.role, UserRole.driver);
      expect(screen1.initialIndex, 2);

      final routeWithArgs = RouteGenerator.getRoute(
        const RouteSettings(
          name: AppRoutes.driverAppShell,
          arguments: AppShellRouteArgs(initialIndex: 3, role: UserRole.driver),
        ),
      );
      final screen2 = (routeWithArgs as PageRouteBuilder).pageBuilder(
        _MockBuildContext(),
        const AlwaysStoppedAnimation(1),
        const AlwaysStoppedAnimation(1),
      ) as AppShellScreen;
      expect(screen2.role, UserRole.driver);
      expect(screen2.initialIndex, 3);
    });
  });
}
