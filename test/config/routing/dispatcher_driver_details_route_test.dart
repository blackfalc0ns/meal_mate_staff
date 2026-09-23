import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/arguments/dispatcher_driver_details_route_arguments.dart';
import 'package:meal_mate_delivery/config/routing/arguments/dispatcher_map_route_arguments.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_driver_details/presentation/screens/dispatcher_driver_details_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_map/presentation/screens/dispatcher_map_screen.dart';

void main() {
  const validGuid = '4f8a3c21-9b12-42e7-90c1-872f2316e110';

  Widget extractPage(Route<dynamic> route) {
    expect(route, isA<PageRouteBuilder<dynamic>>());
    final pageRoute = route as PageRouteBuilder<dynamic>;
    return pageRoute.pageBuilder(
      MockBuildContext(),
      const AlwaysStoppedAnimation(0.0),
      const AlwaysStoppedAnimation(0.0),
    );
  }

  group('DispatcherDriverDetails Route Generation', () {
    test('generates DispatcherDriverDetailsScreen when given valid DispatcherDriverDetailsRouteArgs', () {
      final route = RouteGenerator.getRoute(
        const RouteSettings(
          name: AppRoutes.dispatcherDriverDetails,
          arguments: DispatcherDriverDetailsRouteArgs(driverId: validGuid),
        ),
      );

      final widget = extractPage(route);
      expect(widget, isA<DispatcherDriverDetailsScreen>());
      final screen = widget as DispatcherDriverDetailsScreen;
      expect(screen.driverId, validGuid);
    });

    test('generates DispatcherDriverDetailsScreen when given valid GUID String directly', () {
      final route = RouteGenerator.getRoute(
        const RouteSettings(
          name: AppRoutes.dispatcherDriverDetails,
          arguments: validGuid,
        ),
      );

      final widget = extractPage(route);
      expect(widget, isA<DispatcherDriverDetailsScreen>());
      final screen = widget as DispatcherDriverDetailsScreen;
      expect(screen.driverId, validGuid);
    });

    test('returns invalid route error scaffold when arguments are null', () {
      final route = RouteGenerator.getRoute(
        const RouteSettings(
          name: AppRoutes.dispatcherDriverDetails,
          arguments: null,
        ),
      );

      final widget = extractPage(route);
      expect(widget, isNot(isA<DispatcherDriverDetailsScreen>()));
      expect(widget, isA<Scaffold>());
    });

    test('returns invalid route error scaffold when arguments have invalid GUID', () {
      final route = RouteGenerator.getRoute(
        const RouteSettings(
          name: AppRoutes.dispatcherDriverDetails,
          arguments: DispatcherDriverDetailsRouteArgs(driverId: 'not-a-guid'),
        ),
      );

      final widget = extractPage(route);
      expect(widget, isNot(isA<DispatcherDriverDetailsScreen>()));
      expect(widget, isA<Scaffold>());
    });
  });

  group('DispatcherMap Route Generation with Focus Driver', () {
    test('generates DispatcherMapScreen with focusDriverId', () {
      final route = RouteGenerator.getRoute(
        const RouteSettings(
          name: AppRoutes.dispatcherMap,
          arguments: DispatcherMapRouteArgs(focusDriverId: validGuid),
        ),
      );

      final widget = extractPage(route);
      expect(widget, isA<DispatcherMapScreen>());
      final screen = widget as DispatcherMapScreen;
      expect(screen.focusDriverId, validGuid);
    });
  });
}

class MockBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
