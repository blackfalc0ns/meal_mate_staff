import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/features/driver/calling/domain/entities/driver_active_call_entity.dart';
import 'package:meal_mate_delivery/features/driver/calling/presentation/screens/driver_active_call_screen.dart';

class _MockBuildContext extends Fake implements BuildContext {}

void main() {
  group('Driver Active Call Route', () {
    test('AppRoutes.driverActiveCall routes to DriverActiveCallScreen with default fake data when no args passed', () {
      final route = RouteGenerator.getRoute(
        const RouteSettings(name: AppRoutes.driverActiveCall),
      );

      expect(route, isA<PageRouteBuilder>());
      final pageRoute = route as PageRouteBuilder;
      final screen = pageRoute.pageBuilder(
        _MockBuildContext(),
        const AlwaysStoppedAnimation(1),
        const AlwaysStoppedAnimation(1),
      );
      expect(screen, isA<DriverActiveCallScreen>());
      final callScreen = screen as DriverActiveCallScreen;
      expect(callScreen.callData, isNull);
    });

    test('AppRoutes.driverActiveCall routes with custom DriverActiveCallEntity argument', () {
      const customEntity = DriverActiveCallEntity(
        customerName: 'أحمد محمود',
        addressLine: 'شارع الملك فهد',
        area: 'الرياض',
        initialDurationSeconds: 45,
      );

      final route = RouteGenerator.getRoute(
        const RouteSettings(
          name: AppRoutes.driverActiveCall,
          arguments: customEntity,
        ),
      );

      expect(route, isA<PageRouteBuilder>());
      final pageRoute = route as PageRouteBuilder;
      final screen = pageRoute.pageBuilder(
        _MockBuildContext(),
        const AlwaysStoppedAnimation(1),
        const AlwaysStoppedAnimation(1),
      );
      expect(screen, isA<DriverActiveCallScreen>());
      final callScreen = screen as DriverActiveCallScreen;
      expect(callScreen.callData, customEntity);
    });
  });
}
