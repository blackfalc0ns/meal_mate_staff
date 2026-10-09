import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/delivery_issue_entity.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/delivery_issue_reason.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/reassignment_delivery_context_entity.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/domain/entities/reassignment_result_entity.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/presentation/screens/driver_reassignment_request_screen.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/presentation/screens/driver_reassignment_submitted_screen.dart';
import 'package:meal_mate_delivery/features/driver/delivery_issues/presentation/screens/driver_report_issue_screen.dart';

void main() {
  Widget buildApp({
    Key? key,
    required String initialRoute,
    Object? initialArguments,
  }) {
    return MaterialApp(
      key: key,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      locale: const Locale('ar'),
      onGenerateRoute: (settings) {
        if (settings.name == initialRoute) {
          return RouteGenerator.getRoute(
            RouteSettings(name: initialRoute, arguments: initialArguments),
          );
        }
        return RouteGenerator.getRoute(settings);
      },
      initialRoute: initialRoute,
    );
  }

  group('Driver Reassignment Route Tests', () {
    const realBoxUuid = 'c2222222-2222-2222-2222-222222222222';
    const displayBoxCode = '#BX-1256';
    const dailyOrderId = 'order-999-distinct';
    const tripId = 'trip-888-distinct';

    testWidgets(
        'real UUID survives tracking -> report-issue -> reassignment route without substituting boxCode or orderId',
        (tester) async {
      const contextEntity = ReassignmentDeliveryContextEntity(
        boxId: realBoxUuid,
        boxCode: displayBoxCode,
        tripId: tripId,
        isPickedUp: true,
        driverLatitude: 29.3,
        driverLongitude: 47.93,
      );

      const issueEntity = DeliveryIssueEntity(
        boxCode: displayBoxCode,
        customerName: 'Customer Real',
        restaurantName: 'Restaurant Real',
        area: 'Hawally',
        status: 'InTransit',
        mealsCountText: '2 meals',
        selectedReason: DeliveryIssueReason.customerNoAnswer,
        deliveryContext: contextEntity,
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: AppRoutes.driverReportIssue,
          initialArguments: issueEntity,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DriverReportIssueScreen), findsOneWidget);

      // Tap reassignment button to navigate to reassignment request screen
      await tester.ensureVisible(find.text('طلب إعادة إسناد'));
      await tester.tap(find.text('طلب إعادة إسناد'));
      await tester.pumpAndSettle();

      expect(find.byType(DriverReassignmentRequestScreen), findsOneWidget);
      final requestScreen = tester.widget<DriverReassignmentRequestScreen>(
        find.byType(DriverReassignmentRequestScreen),
      );

      final resolvedContext = requestScreen.routeArguments?.delivery ??
          requestScreen.deliveryContext;
      expect(resolvedContext, isNotNull);
      expect(resolvedContext!.boxId, equals(realBoxUuid));
      expect(resolvedContext.boxId, isNot(equals(displayBoxCode)));
      expect(resolvedContext.boxId, isNot(equals(dailyOrderId)));
      expect(resolvedContext.boxCode, equals(displayBoxCode));
      expect(resolvedContext.tripId, equals(tripId));
      expect(resolvedContext.isPickedUp, isTrue);
    });

    testWidgets('missing or non-picked-up context disables reassignment in report issue screen',
        (tester) async {
      const issueWithoutContext = DeliveryIssueEntity(
        boxCode: displayBoxCode,
        customerName: 'Customer',
        restaurantName: 'Restaurant',
        area: 'Kuwait',
        status: 'Pending',
        mealsCountText: '1 meal',
        selectedReason: DeliveryIssueReason.customerNoAnswer,
        deliveryContext: null, // No real context!
      );

      await tester.pumpWidget(
        buildApp(
          initialRoute: AppRoutes.driverReportIssue,
          initialArguments: issueWithoutContext,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DriverReportIssueScreen), findsOneWidget);

      // Reassign button should be disabled when context is absent
      final reassignButton = tester.widget<OutlinedButton>(
        find.widgetWithText(OutlinedButton, 'طلب إعادة إسناد'),
      );
      expect(reassignButton.onPressed, isNull);
    });

    testWidgets(
        'missing route arguments on reassignment request renders unavailable-context feedback and blocks submission',
        (tester) async {
      await tester.pumpWidget(
        buildApp(
          initialRoute: AppRoutes.driverReassignmentRequest,
          initialArguments: null, // missing context
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DriverReassignmentRequestScreen), findsOneWidget);
      // Feedback indicating no delivery context is available
      expect(find.textContaining('لا توجد شحنة نشطة متاحة لإعادة الإسناد'),
          findsOneWidget);
    });

    testWidgets(
        'confirmation route requires ReassignmentResultEntity and does not render success without it',
        (tester) async {
      await tester.pumpWidget(
        buildApp(
          key: const ValueKey('missing_result'),
          initialRoute: AppRoutes.driverReassignmentSubmitted,
          initialArguments: null, // Missing result
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DriverReassignmentSubmittedScreen), findsOneWidget);
      // Success card title should NOT be present when result is null
      expect(find.text('تم إرسال طلب\nإعادة الإسناد'), findsNothing);

      // Now pass valid result
      const validResult = ReassignmentResultEntity(
        requestId: 'f4444444-4444-4444-4444-444444444444',
        boxId: realBoxUuid,
        boxCode: displayBoxCode,
        status: 'ReassignmentRequested',
      );

      await tester.pumpWidget(
        buildApp(
          key: const ValueKey('valid_result'),
          initialRoute: AppRoutes.driverReassignmentSubmitted,
          initialArguments: validResult,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('تم إرسال طلب\nإعادة الإسناد'), findsOneWidget);
    });
  });
}
