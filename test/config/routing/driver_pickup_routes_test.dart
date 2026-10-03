import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/arguments/driver_confirm_receipt_route_arguments.dart';
import 'package:meal_mate_delivery/config/routing/arguments/driver_pickup_summary_route_arguments.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/driver_box_received_success_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/screens/driver_box_received_success_screen.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/screens/driver_boxes_received_screen.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/screens/driver_confirm_receipt_screen.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_assigned_box_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_box_delivery_status.dart';

void main() {
  group('Driver Pickup Routes', () {
    test(
      'AppRoutes.driverConfirmReceipt routes with DriverConfirmReceiptRouteArguments',
      () {
        const box = DriverAssignedBoxEntity(
          boxId: 'box-101',
          boxCode: 'BOX-101',
          customerName: 'Ahmad',
          deliveryZone: 'Hawalli',
          mealsCount: 2,
          mealsSummary: '2 Meals',
          deliveryTimeSlot: '12:00 - 14:00',
          status: DriverBoxDeliveryStatus.pendingScan,
          statusText: 'Pending Scan',
          isPickedUp: false,
        );
        const args = DriverConfirmReceiptRouteArguments(
          box: box,
          tripId: 'trip-101',
        );
        final route = RouteGenerator.getRoute(
          const RouteSettings(
            name: AppRoutes.driverConfirmReceipt,
            arguments: args,
          ),
        );

        expect(route, isA<PageRouteBuilder>());
        final pageRoute = route as PageRouteBuilder;
        final screen = pageRoute.pageBuilder(
          _MockBuildContext(),
          const AlwaysStoppedAnimation(1),
          const AlwaysStoppedAnimation(1),
        );
        expect(screen, isA<DriverConfirmReceiptScreen>());
        final confirmScreen = screen as DriverConfirmReceiptScreen;
        expect(confirmScreen.box?.boxId, 'box-101');
      },
    );

    test(
      'AppRoutes.driverConfirmReceipt routes directly with DriverAssignedBoxEntity',
      () {
        const box = DriverAssignedBoxEntity(
          boxId: 'box-102',
          boxCode: 'BOX-102',
          customerName: 'Fatima',
          deliveryZone: 'Capital',
          mealsCount: 3,
          mealsSummary: '3 Meals',
          deliveryTimeSlot: '12:00 - 14:00',
          status: DriverBoxDeliveryStatus.pendingScan,
          statusText: 'Pending Scan',
          isPickedUp: false,
        );
        final route = RouteGenerator.getRoute(
          const RouteSettings(
            name: AppRoutes.driverConfirmReceipt,
            arguments: box,
          ),
        );

        final pageRoute = route as PageRouteBuilder;
        final screen =
            pageRoute.pageBuilder(
                  _MockBuildContext(),
                  const AlwaysStoppedAnimation(1),
                  const AlwaysStoppedAnimation(1),
                )
                as DriverConfirmReceiptScreen;
        expect(screen.box?.boxId, 'box-102');
      },
    );

    test(
      'AppRoutes.driverBoxesReceived routes with DriverPickupSummaryRouteArguments',
      () {
        const args = DriverPickupSummaryRouteArguments(tripId: 'trip-999');
        final route = RouteGenerator.getRoute(
          const RouteSettings(
            name: AppRoutes.driverBoxesReceived,
            arguments: args,
          ),
        );

        expect(route, isA<PageRouteBuilder>());
        final pageRoute = route as PageRouteBuilder;
        final screen = pageRoute.pageBuilder(
          _MockBuildContext(),
          const AlwaysStoppedAnimation(1),
          const AlwaysStoppedAnimation(1),
        );
        expect(screen, isA<DriverBoxesReceivedScreen>());
      },
    );

    test(
      'AppRoutes.driverBoxReceivedSuccess routes with DriverBoxReceivedSuccessEntity',
      () {
        const successEntity = DriverBoxReceivedSuccessEntity(
          boxCode: 'BOX-101',
          restaurantName: 'Ahmad Restaurant',
          itemsCount: 2,
          expectedReceiptTime: '12:30',
        );
        final route = RouteGenerator.getRoute(
          const RouteSettings(
            name: AppRoutes.driverBoxReceivedSuccess,
            arguments: successEntity,
          ),
        );

        expect(route, isA<PageRouteBuilder>());
        final pageRoute = route as PageRouteBuilder;
        final screen =
            pageRoute.pageBuilder(
                  _MockBuildContext(),
                  const AlwaysStoppedAnimation(1),
                  const AlwaysStoppedAnimation(1),
                )
                as DriverBoxReceivedSuccessScreen;
        expect(screen.box?.boxCode, 'BOX-101');
      },
    );
  });
}

class _MockBuildContext extends Fake implements BuildContext {}
