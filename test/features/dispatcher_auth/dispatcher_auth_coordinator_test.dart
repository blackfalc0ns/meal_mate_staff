import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/arguments/auth_route_arguments.dart';
import 'package:meal_mate_delivery/features/auth/domain/user_role.dart';
import 'package:meal_mate_delivery/features/dispatcher_auth/domain/dispatcher_auth_destination.dart';
import 'package:meal_mate_delivery/features/dispatcher_auth/presentation/manager/dispatcher_auth_coordinator.dart';

void main() {
  group('DispatcherAuthCoordinator.navigate', () {
    testWidgets(
      'DispatcherFirstTimeOtpDestination pushes verifyPhoneOtp with OtpVerificationRouteArgs and UserRole.operations',
      (tester) async {
        String? pushedRoute;
        Object? pushedArgs;

        await tester.pumpWidget(
          MaterialApp(
            onGenerateRoute: (settings) {
              pushedRoute = settings.name;
              pushedArgs = settings.arguments;
              return MaterialPageRoute(
                builder: (_) => const SizedBox(),
                settings: settings,
              );
            },
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    const coordinator = DispatcherAuthCoordinator();
                    coordinator.navigate(
                      context,
                      const DispatcherFirstTimeOtpDestination(
                        phone: '+96599777222',
                        fullName: 'Operations Manager',
                        restaurantName: 'Protein Lab',
                      ),
                    );
                  },
                  child: const Text('Navigate'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();

        expect(pushedRoute, AppRoutes.verifyPhoneOtp);
        expect(pushedArgs, isA<OtpVerificationRouteArgs>());
        final args = pushedArgs as OtpVerificationRouteArgs;
        expect(args.target.value, '+96599777222');
        expect(args.role, UserRole.operations);
      },
    );

    testWidgets(
      'DispatcherHomeDestination replaces with appShell and UserRole.operations',
      (tester) async {
        String? pushedRoute;
        Object? pushedArgs;

        await tester.pumpWidget(
          MaterialApp(
            onGenerateRoute: (settings) {
              pushedRoute = settings.name;
              pushedArgs = settings.arguments;
              return MaterialPageRoute(
                builder: (_) => const SizedBox(),
                settings: settings,
              );
            },
            home: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    const coordinator = DispatcherAuthCoordinator();
                    coordinator.navigate(
                      context,
                      const DispatcherHomeDestination(),
                    );
                  },
                  child: const Text('Navigate'),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Navigate'));
        await tester.pumpAndSettle();

        expect(pushedRoute, AppRoutes.appShell);
        expect(pushedArgs, UserRole.operations);
      },
    );
  });
}
