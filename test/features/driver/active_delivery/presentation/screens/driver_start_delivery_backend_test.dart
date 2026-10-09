import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/routing/arguments/driver_active_delivery_route_arguments.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/inline_api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/entities/driver_start_delivery_result_entity.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/usecase/arrive_at_driver_customer_usecase.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/usecase/deliver_driver_order_usecase.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/usecase/start_driver_delivery_usecase.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/usecase/upload_driver_delivery_proof_usecase.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/manager/active_delivery_view_model.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/screens/driver_start_delivery_route_screen.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/start_route_action_button.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_route_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_stop_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/usecase/get_driver_map_route_usecase.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_delivery_status.dart';

import '../manager/active_delivery_view_model_test.dart'
    show MockDriverMapRepository, MockDriverDeliveryRepository;

void main() {
  for (final locale in [const Locale('ar'), const Locale('en')]) {
    testWidgets(
      'start waits, shows failure and then hands backend data to tracking (${locale.languageCode})',
      (tester) async {
        tester.view.physicalSize = const Size(780, 1688);
        tester.view.devicePixelRatio = 2;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        const stop = DriverMapStopEntity(
          id: 'stop-1',
          boxId: 'box-1',
          boxCode: 'BX-001',
          customerName: 'Current customer',
          area: 'Area',
          formattedAddress: 'Current address',
          mealsCount: 2,
          deliveryTimeSlot: '09:00–12:00',
          status: DriverDeliveryStatus.inProgress,
        );
        final map = MockDriverMapRepository()
          ..routeResult = const DriverMapRouteEntity(
            tripId: 'trip-1',
            tripCode: 'TRP-1',
            focusedStop: stop,
            stops: [stop],
          );
        final delivery = MockDriverDeliveryRepository()
          ..startCompleter = Completer();
        final vm = ActiveDeliveryViewModel(
          getDriverMapRouteUseCase: GetDriverMapRouteUseCase(map),
          startDriverDeliveryUseCase: StartDriverDeliveryUseCase(delivery),
          arriveAtDriverCustomerUseCase: ArriveAtDriverCustomerUseCase(
            delivery,
          ),
          uploadDriverDeliveryProofUseCase: UploadDriverDeliveryProofUseCase(
            delivery,
          ),
          deliverDriverOrderUseCase: DeliverDriverOrderUseCase(delivery),
        );
        addTearDown(vm.close);
        DriverActiveDeliveryRouteArguments? trackingArguments;
        await tester.pumpWidget(
          MaterialApp(
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ar'), Locale('en')],
            onGenerateRoute: (settings) {
              trackingArguments =
                  settings.arguments as DriverActiveDeliveryRouteArguments;
              return MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: Text('Tracking opened')),
              );
            },
            home: DriverStartDeliveryRouteScreen(viewModel: vm),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byType(StartRouteActionButton));
        await tester.pump();
        expect(
          tester
              .widget<StartRouteActionButton>(
                find.byType(StartRouteActionButton),
              )
              .isLoading,
          isTrue,
        );
        expect(trackingArguments, isNull);
        delivery.startCompleter!.complete(
          ApiErrorResult(failure: Failure(errorMessage: 'Cannot start')),
        );
        await tester.pumpAndSettle();
        expect(find.byType(InlineApiErrorWidget), findsOneWidget);
        expect(find.text('Current customer'), findsOneWidget);
        expect(trackingArguments, isNull);
        delivery.startCompleter = Completer();
        await tester.tap(find.byType(StartRouteActionButton));
        await tester.pump();
        delivery.startCompleter!.complete(
          const ApiSuccessResult(
            data: DriverStartDeliveryResultEntity(
              boxId: 'box-1',
              tripId: 'trip-1',
              status: 'InTransit',
              customerName: 'Backend customer',
              orderCode: 'MM-987654',
              boxCount: 3,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Tracking opened'), findsOneWidget);
        expect(trackingArguments?.stopId, 'stop-1');
        expect(trackingArguments?.startResult?.orderCode, 'MM-987654');
        expect(
          trackingArguments?.startedRoute?.focusedStop.customerName,
          'Backend customer',
        );
        expect(delivery.startCallCount, 2);
      },
    );
  }
}
