import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/arguments/auth_route_arguments.dart';
import 'package:meal_mate_delivery/core/services/app_navigator_service.dart';
import 'package:meal_mate_delivery/core/services/notification_payload.dart';
import 'package:meal_mate_delivery/core/services/notification_router.dart';
import 'package:meal_mate_delivery/features/account_status/domain/account_status_kind.dart';

void main() {
  late NotificationRouter router;
  String? pushedRoute;
  Object? pushedArguments;

  setUp(() {
    router = NotificationRouter(
      deduplicationWindow: const Duration(seconds: 5),
    );
    pushedRoute = null;
    pushedArguments = null;
  });

  Widget appWithMockNavigation() {
    return MaterialApp(
      navigatorKey: AppNavigatorService.navigatorKey,
      onGenerateRoute: (settings) {
        pushedRoute = settings.name;
        pushedArguments = settings.arguments;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const SizedBox(),
        );
      },
      home: const Scaffold(body: Text('Home')),
    );
  }

  group('NotificationRouter', () {
    testWidgets(
      'routes restaurant_approved to accountStatus with underReview',
      (tester) async {
        await tester.pumpWidget(appWithMockNavigation());

        final routed = await router.route(
          const DriverRegistrationRestaurantApprovedPayload(
            registrationId: 'reg-123',
          ),
          messageId: 'msg-1',
        );

        expect(routed, isTrue);
        expect(pushedRoute, AppRoutes.accountStatus);
        expect(pushedArguments, isA<AccountStatusRouteArgs>());
        final args = pushedArguments as AccountStatusRouteArgs;
        expect(args.kind, AccountStatusKind.underReview);
        expect(args.registrationId, 'reg-123');
      },
    );

    testWidgets(
      'routes changes_requested to accountStatus with moreInformationRequired',
      (tester) async {
        await tester.pumpWidget(appWithMockNavigation());

        final routed = await router.route(
          const DriverRegistrationChangesRequestedPayload(
            registrationId: 'reg-456',
          ),
          messageId: 'msg-2',
        );

        expect(routed, isTrue);
        expect(pushedRoute, AppRoutes.accountStatus);
        expect(pushedArguments, isA<AccountStatusRouteArgs>());
        final args = pushedArguments as AccountStatusRouteArgs;
        expect(args.kind, AccountStatusKind.moreInformationRequired);
        expect(args.registrationId, 'reg-456');
      },
    );

    testWidgets('routes admin_confirmed to accountStatus with accepted', (
      tester,
    ) async {
      await tester.pumpWidget(appWithMockNavigation());

      final routed = await router.route(
        const DriverRegistrationAdminConfirmedPayload(
          registrationId: 'reg-789',
        ),
        messageId: 'msg-3',
      );

      expect(routed, isTrue);
      expect(pushedRoute, AppRoutes.accountStatus);
      final args = pushedArguments as AccountStatusRouteArgs;
      expect(args.kind, AccountStatusKind.accepted);
      expect(args.registrationId, 'reg-789');
    });

    testWidgets('routes admin_rejected to accountStatus with rejected', (
      tester,
    ) async {
      await tester.pumpWidget(appWithMockNavigation());

      final routed = await router.route(
        const DriverRegistrationAdminRejectedPayload(registrationId: 'reg-999'),
        messageId: 'msg-4',
      );

      expect(routed, isTrue);
      expect(pushedRoute, AppRoutes.accountStatus);
      final args = pushedArguments as AccountStatusRouteArgs;
      expect(args.kind, AccountStatusKind.rejected);
      expect(args.registrationId, 'reg-999');
    });

    testWidgets(
      'routes driver box/trip/kitchen payloads to driverAssignedBoxes',
      (tester) async {
        await tester.pumpWidget(appWithMockNavigation());

        await router.route(
          const DriverBoxAssignedPayload(boxId: 'box-1'),
          messageId: 'msg-box',
        );
        expect(pushedRoute, AppRoutes.driverAssignedBoxes);

        await router.route(
          const DriverTripAssignedPayload(tripId: 'trip-1'),
          messageId: 'msg-trip',
        );
        expect(pushedRoute, AppRoutes.driverAssignedBoxes);

        await router.route(
          const DriverTripKitchenReadyPayload(tripId: 'trip-2'),
          messageId: 'msg-kitchen',
        );
        expect(pushedRoute, AppRoutes.driverAssignedBoxes);
      },
    );

    testWidgets('routes dispatcher batch to dispatcherOrders', (tester) async {
      await tester.pumpWidget(appWithMockNavigation());

      await router.route(
        const DispatcherBatchReadyPayload(batchId: 'batch-1'),
        messageId: 'msg-batch',
      );
      expect(pushedRoute, AppRoutes.dispatcherOrders);
    });

    testWidgets('routes driver registration submitted to dispatcherHome', (
      tester,
    ) async {
      await tester.pumpWidget(appWithMockNavigation());

      await router.route(
        const DriverRegistrationSubmittedPayload(registrationId: 'reg-sub'),
        messageId: 'msg-sub',
      );
      expect(pushedRoute, AppRoutes.dispatcherHome);
    });

    testWidgets('does not route incoming_call or unsupported', (tester) async {
      await tester.pumpWidget(appWithMockNavigation());

      final callRouted = await router.route(
        const IncomingCallPayload(rawData: {}),
        messageId: 'msg-call',
      );
      expect(callRouted, isFalse);

      final unsupportedRouted = await router.route(
        const UnsupportedNotificationPayload(rawData: {}, reason: 'unknown'),
        messageId: 'msg-unsupported',
      );
      expect(unsupportedRouted, isFalse);
    });

    testWidgets('deduplicates identical messageId within window', (
      tester,
    ) async {
      await tester.pumpWidget(appWithMockNavigation());

      final first = await router.route(
        const DriverBoxAssignedPayload(boxId: 'box-dup'),
        messageId: 'msg-dup',
      );
      expect(first, isTrue);

      final second = await router.route(
        const DriverBoxAssignedPayload(boxId: 'box-dup'),
        messageId: 'msg-dup',
      );
      expect(second, isFalse);
    });
  });
}
