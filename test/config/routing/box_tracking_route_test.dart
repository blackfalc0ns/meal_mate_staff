import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/arguments/box_tracking_route_arguments.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_box_tracking/presentation/screens/dispatcher_box_tracking_screen.dart';

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

  group('BoxTracking Route Generation', () {
    test('generates DispatcherBoxTrackingScreen when given valid BoxTrackingRouteArguments', () {
      final route = RouteGenerator.getRoute(
        const RouteSettings(
          name: AppRoutes.boxTracking,
          arguments: BoxTrackingRouteArguments(boxId: validGuid),
        ),
      );

      final widget = extractPage(route);
      expect(widget, isA<DispatcherBoxTrackingScreen>());
      final screen = widget as DispatcherBoxTrackingScreen;
      expect(screen.boxId, validGuid);
    });

    test('generates DispatcherBoxTrackingScreen when given valid GUID String directly', () {
      final route = RouteGenerator.getRoute(
        const RouteSettings(
          name: AppRoutes.boxTracking,
          arguments: validGuid,
        ),
      );

      final widget = extractPage(route);
      expect(widget, isA<DispatcherBoxTrackingScreen>());
      final screen = widget as DispatcherBoxTrackingScreen;
      expect(screen.boxId, validGuid);
    });

    test('returns invalid route error scaffold when arguments are null', () {
      final route = RouteGenerator.getRoute(
        const RouteSettings(
          name: AppRoutes.boxTracking,
          arguments: null,
        ),
      );

      final widget = extractPage(route);
      expect(widget, isNot(isA<DispatcherBoxTrackingScreen>()));
      expect(widget, isA<Scaffold>());
    });

    test('returns invalid route error scaffold when arguments have invalid GUID', () {
      final route = RouteGenerator.getRoute(
        const RouteSettings(
          name: AppRoutes.boxTracking,
          arguments: BoxTrackingRouteArguments(boxId: 'invalid-not-guid'),
        ),
      );

      final widget = extractPage(route);
      expect(widget, isNot(isA<DispatcherBoxTrackingScreen>()));
      expect(widget, isA<Scaffold>());
    });
  });
}

class MockBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
