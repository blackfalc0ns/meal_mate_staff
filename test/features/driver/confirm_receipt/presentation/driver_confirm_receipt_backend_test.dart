import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:meal_mate_delivery/config/routing/app_routes.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/inline_api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/core/services/idempotency_key_factory.dart';
import 'package:meal_mate_delivery/core/widget/app_button.dart';
import 'package:meal_mate_delivery/core/widget/custom_progress_indecator.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/confirm_driver_pickup_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/driver_barcode_validation_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/driver_condition_photo_upload_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/driver_pickup_confirmation_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/validate_driver_barcode_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/repo/driver_pickup_repository.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/usecase/confirm_driver_box_pickup_usecase.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/usecase/upload_driver_box_condition_photo_usecase.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/usecase/validate_driver_pickup_barcode_usecase.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/manager/driver_pickup_flow_event.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/manager/driver_pickup_flow_view_model.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/screens/driver_confirm_receipt_screen.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_camera_viewfinder.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_qr_viewfinder.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_assigned_box_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_box_delivery_status.dart';

import '../../../../support/fakes/fake_driver_pickup_location_provider.dart';

class _FakePickupRepo implements DriverPickupRepository {
  ApiResult<DriverBarcodeValidationEntity>? validateResult;
  Future<ApiResult<DriverBarcodeValidationEntity>> Function()?
  onValidateBarcode;
  ApiResult<DriverConditionPhotoUploadEntity>? uploadResult;
  ApiResult<DriverPickupConfirmationEntity>? confirmResult;

  int confirmCalls = 0;

  @override
  Future<ApiResult<DriverBarcodeValidationEntity>> validateDriverPickupBarcode(
    ValidateDriverBarcodeRequestEntity request,
  ) async {
    if (onValidateBarcode != null) {
      return onValidateBarcode!();
    }
    return validateResult!;
  }

  @override
  Future<ApiResult<DriverConditionPhotoUploadEntity>>
  uploadDriverBoxConditionPhoto({
    required String boxId,
    required File file,
    required String validationToken,
  }) async {
    return uploadResult!;
  }

  @override
  Future<ApiResult<DriverPickupConfirmationEntity>> confirmDriverBoxPickup({
    required String boxId,
    required String idempotencyKey,
    required ConfirmDriverPickupRequestEntity request,
  }) async {
    confirmCalls++;
    return confirmResult!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FixedKeyFactory implements IdempotencyKeyFactory {
  @override
  String create() => 'test-idempotency-key';
}

void main() {
  late _FakePickupRepo fakeRepo;
  late DriverPickupFlowViewModel viewModel;
  late MobileScannerController testScannerController;

  const testBox = DriverAssignedBoxEntity(
    boxId: 'box-101',
    boxCode: 'BOX-101',
    customerName: 'Ahmad Ali',
    deliveryZone: 'Hawalli',
    mealsCount: 2,
    mealsSummary: '2 Meals',
    deliveryTimeSlot: '12:00 - 14:00',
    status: DriverBoxDeliveryStatus.pendingScan,
    statusText: 'Pending Scan',
    isPickedUp: false,
  );

  setUp(() {
    fakeRepo = _FakePickupRepo();
    viewModel = DriverPickupFlowViewModel(
      validateBarcodeUseCase: ValidateDriverPickupBarcodeUseCase(fakeRepo),
      uploadPhotoUseCase: UploadDriverBoxConditionPhotoUseCase(fakeRepo),
      confirmPickupUseCase: ConfirmDriverBoxPickupUseCase(fakeRepo),
      locationProvider: FakeDriverPickupLocationProvider(),
      idempotencyKeyFactory: _FixedKeyFactory(),
    );
    testScannerController = MobileScannerController(autoStart: false);
  });

  tearDown(() async {
    await viewModel.close();
    await testScannerController.dispose();
  });

  Widget buildScreen({NavigatorObserver? observer}) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ar')],
      navigatorObservers: observer != null ? [observer] : [],
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.driverBoxReceivedSuccess) {
          return MaterialPageRoute(
            builder: (_) =>
                const Scaffold(body: Text('Box Received Success Screen')),
          );
        }
        if (settings.name == AppRoutes.driverBoxesReceived) {
          return MaterialPageRoute(
            builder: (_) =>
                const Scaffold(body: Text('Boxes Received Summary Screen')),
          );
        }
        return MaterialPageRoute(
          builder: (_) => DriverConfirmReceiptScreen(
            box: testBox,
            scannerController: testScannerController,
            viewModel: viewModel,
          ),
        );
      },
    );
  }

  Future<void> pumpScreen(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> sendIntent(
    WidgetTester tester,
    DriverPickupFlowEvent event,
  ) async {
    await tester.runAsync(() async {
      viewModel.doIntent(event);
      await pumpEventQueue();
    });
    await tester.pump(const Duration(milliseconds: 100));
  }

  group('DriverConfirmReceiptScreen Backend Integration', () {
    testWidgets(
      'renders Step 1 initially without full-screen loading spinner',
      (tester) async {
        await tester.pumpWidget(buildScreen());
        await pumpScreen(tester);

        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.byType(DriverQrViewfinder), findsOneWidget);
      },
    );

    testWidgets('shows InlineApiErrorWidget when barcode validation fails', (
      tester,
    ) async {
      fakeRepo.validateResult = ApiErrorResult(
        failure: Failure(
          errorMessage: 'Invalid barcode from server',
          code: 'invalid_code',
        ),
      );

      await tester.pumpWidget(buildScreen());
      await pumpScreen(tester);

      await sendIntent(tester, const ValidateBarcodeEvent('INVALID-CODE'));

      expect(find.byType(InlineApiErrorWidget), findsOneWidget);
      expect(find.text('Invalid barcode from server'), findsOneWidget);
    });

    testWidgets(
      'transitions to Step 2 when barcode is validated and user continues',
      (tester) async {
        fakeRepo.validateResult = const ApiSuccessResult(
          data: DriverBarcodeValidationEntity(
            boxId: 'box-101',
            boxCode: 'BOX-101',
            customerName: 'Ahmad Ali',
            deliveryZone: 'Hawalli',
            mealsCount: 2,
            deliveryTimeSlot: '12:00 - 14:00',
            validationToken: 'valid-token-123',
            expiresAtUtc: null,
            status: 'Validated',
            statusText: 'Validated',
            nextAction: 'TakeConditionPhoto',
          ),
        );

        await tester.pumpWidget(buildScreen());
        await pumpScreen(tester);

        await sendIntent(tester, const ValidateBarcodeEvent('BOX-101'));

        // Tap continue to photograph box button
        final continueButton = find.widgetWithText(
          AppButton,
          'Continue to Photograph Box',
        );
        expect(continueButton, findsOneWidget);
        await tester.ensureVisible(continueButton);
        await tester.tap(continueButton);
        await tester.runAsync(() async {
          await pumpEventQueue();
        });
        await tester.pump(const Duration(milliseconds: 100));

        // Now at Step 2
        expect(find.byType(DriverCameraViewfinder), findsOneWidget);
      },
    );

    testWidgets(
      'shows InlineApiErrorWidget and retains image when photo upload fails',
      (tester) async {
        fakeRepo.validateResult = const ApiSuccessResult(
          data: DriverBarcodeValidationEntity(
            boxId: 'box-101',
            boxCode: 'BOX-101',
            customerName: 'Ahmad Ali',
            deliveryZone: 'Hawalli',
            mealsCount: 2,
            deliveryTimeSlot: '12:00 - 14:00',
            validationToken: 'valid-token-123',
            expiresAtUtc: null,
            status: 'Validated',
            statusText: 'Validated',
            nextAction: 'TakeConditionPhoto',
          ),
        );

        await tester.pumpWidget(buildScreen());
        await pumpScreen(tester);

        await sendIntent(tester, const ValidateBarcodeEvent('BOX-101'));
        await sendIntent(tester, const StepChangedEvent(2));
        await sendIntent(tester, const PhotoSelectedEvent('dummy_photo.jpg'));

        fakeRepo.uploadResult = ApiErrorResult(
          failure: Failure(
            errorMessage: 'Photo upload failed',
            code: 'upload_error',
          ),
        );

        await sendIntent(tester, const ConfirmPickupEvent());

        expect(find.byType(InlineApiErrorWidget), findsOneWidget);
        expect(find.text('Photo upload failed'), findsOneWidget);
        expect(viewModel.state.localPhotoPath, 'dummy_photo.jpg');
      },
    );

    testWidgets(
      'navigates to driverBoxReceivedSuccess when nextAction is ShowBoxSuccess',
      (tester) async {
        fakeRepo.validateResult = const ApiSuccessResult(
          data: DriverBarcodeValidationEntity(
            boxId: 'box-101',
            boxCode: 'BOX-101',
            customerName: 'Ahmad Ali',
            deliveryZone: 'Hawalli',
            mealsCount: 2,
            deliveryTimeSlot: '12:00 - 14:00',
            validationToken: 'valid-token-123',
            expiresAtUtc: null,
            status: 'Validated',
            statusText: 'Validated',
            nextAction: 'TakeConditionPhoto',
          ),
        );

        fakeRepo.uploadResult = const ApiSuccessResult(
          data: DriverConditionPhotoUploadEntity(
            boxId: 'box-101',
            conditionPhotoStorageKey: 'uploaded-key-1',
            uploadedAtUtc: null,
            status: 'Uploaded',
            statusText: 'Uploaded',
            nextAction: 'ConfirmPickup',
          ),
        );

        fakeRepo.confirmResult = const ApiSuccessResult(
          data: DriverPickupConfirmationEntity(
            boxId: 'box-101',
            boxCode: 'BOX-101',
            tripId: 'trip-101',
            confirmedAtUtc: null,
            status: 'PickedUp',
            statusText: 'PickedUp',
            nextAction: DriverPickupNextAction.showBoxSuccess,
            pickedUpBoxesCount: 1,
            totalBoxesCount: 5,
            allBoxesPickedUp: false,
          ),
        );

        await tester.pumpWidget(buildScreen());
        await pumpScreen(tester);

        await sendIntent(tester, const ValidateBarcodeEvent('BOX-101'));
        await sendIntent(tester, const StepChangedEvent(2));
        await sendIntent(tester, const PhotoSelectedEvent('photo.jpg'));
        await sendIntent(tester, const ConfirmPickupEvent());
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('Box Received Success Screen'), findsOneWidget);
      },
    );

    testWidgets(
      'navigates to driverBoxReceivedSuccess as default when nextAction is unknown',
      (tester) async {
        fakeRepo.validateResult = const ApiSuccessResult(
          data: DriverBarcodeValidationEntity(
            boxId: 'box-101',
            boxCode: 'BOX-101',
            customerName: 'Ahmad Ali',
            deliveryZone: 'Hawalli',
            mealsCount: 2,
            deliveryTimeSlot: '12:00 - 14:00',
            validationToken: 'valid-token-123',
            expiresAtUtc: null,
            status: 'Validated',
            statusText: 'Validated',
            nextAction: 'TakeConditionPhoto',
          ),
        );

        fakeRepo.uploadResult = const ApiSuccessResult(
          data: DriverConditionPhotoUploadEntity(
            boxId: 'box-101',
            conditionPhotoStorageKey: 'uploaded-key-1',
            uploadedAtUtc: null,
            status: 'Uploaded',
            statusText: 'Uploaded',
            nextAction: 'ConfirmPickup',
          ),
        );

        fakeRepo.confirmResult = const ApiSuccessResult(
          data: DriverPickupConfirmationEntity(
            boxId: 'box-101',
            boxCode: 'BOX-101',
            tripId: 'trip-101',
            confirmedAtUtc: null,
            status: 'PickedUp',
            statusText: 'PickedUp',
            nextAction: DriverPickupNextAction.unknown,
            pickedUpBoxesCount: 1,
            totalBoxesCount: 5,
            allBoxesPickedUp: false,
          ),
        );

        await tester.pumpWidget(buildScreen());
        await pumpScreen(tester);

        await sendIntent(tester, const ValidateBarcodeEvent('BOX-101'));
        await sendIntent(tester, const StepChangedEvent(2));
        await sendIntent(tester, const PhotoSelectedEvent('photo.jpg'));
        await sendIntent(tester, const ConfirmPickupEvent());
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('Box Received Success Screen'), findsOneWidget);
      },
    );

    testWidgets(
      'shows CustomProgressIndicator overlay while request is loading',
      (tester) async {
        final completer = Completer<ApiResult<DriverBarcodeValidationEntity>>();
        fakeRepo.onValidateBarcode = () => completer.future;

        await tester.pumpWidget(buildScreen());
        await pumpScreen(tester);

        expect(find.byType(CustomProgressIndicator), findsNothing);

        await tester.runAsync(() async {
          viewModel.doIntent(const ValidateBarcodeEvent('BOX-101'));
          await pumpEventQueue();
        });
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(CustomProgressIndicator), findsOneWidget);

        completer.complete(
          const ApiSuccessResult(
            data: DriverBarcodeValidationEntity(
              boxId: 'box-101',
              boxCode: 'BOX-101',
              customerName: 'Ahmad Ali',
              deliveryZone: 'Hawalli',
              mealsCount: 2,
              deliveryTimeSlot: '12:00 - 14:00',
              validationToken: 'valid-token-123',
              expiresAtUtc: null,
              status: 'Validated',
              statusText: 'Validated',
              nextAction: 'TakeConditionPhoto',
            ),
          ),
        );

        await tester.runAsync(() async {
          await pumpEventQueue();
        });
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(CustomProgressIndicator), findsNothing);
      },
    );

    testWidgets(
      'navigates to driverBoxesReceived when nextAction is ShowPickupSummary',
      (tester) async {
        fakeRepo.validateResult = const ApiSuccessResult(
          data: DriverBarcodeValidationEntity(
            boxId: 'box-105',
            boxCode: 'BOX-105',
            customerName: 'Sara Ali',
            deliveryZone: 'Salmiya',
            mealsCount: 1,
            deliveryTimeSlot: '12:00 - 14:00',
            validationToken: 'valid-token-105',
            expiresAtUtc: null,
            status: 'Validated',
            statusText: 'Validated',
            nextAction: 'TakeConditionPhoto',
          ),
        );

        fakeRepo.uploadResult = const ApiSuccessResult(
          data: DriverConditionPhotoUploadEntity(
            boxId: 'box-105',
            conditionPhotoStorageKey: 'uploaded-key-5',
            uploadedAtUtc: null,
            status: 'Uploaded',
            statusText: 'Uploaded',
            nextAction: 'ConfirmPickup',
          ),
        );

        fakeRepo.confirmResult = const ApiSuccessResult(
          data: DriverPickupConfirmationEntity(
            boxId: 'box-105',
            boxCode: 'BOX-105',
            tripId: 'trip-101',
            confirmedAtUtc: null,
            status: 'PickedUp',
            statusText: 'PickedUp',
            nextAction: DriverPickupNextAction.showPickupSummary,
            pickedUpBoxesCount: 5,
            totalBoxesCount: 5,
            allBoxesPickedUp: true,
          ),
        );

        await tester.pumpWidget(buildScreen());
        await pumpScreen(tester);

        await sendIntent(tester, const ValidateBarcodeEvent('BOX-105'));
        await sendIntent(tester, const StepChangedEvent(2));
        await sendIntent(tester, const PhotoSelectedEvent('photo5.jpg'));
        await sendIntent(tester, const ConfirmPickupEvent());
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('Boxes Received Summary Screen'), findsOneWidget);
      },
    );

    testWidgets('returns to Step 1 when token expires', (tester) async {
      final expiredDate = DateTime.now().toUtc().subtract(
        const Duration(minutes: 5),
      );
      fakeRepo.validateResult = ApiSuccessResult(
        data: DriverBarcodeValidationEntity(
          boxId: 'box-101',
          boxCode: 'BOX-101',
          customerName: 'Ahmad Ali',
          deliveryZone: 'Hawalli',
          mealsCount: 2,
          deliveryTimeSlot: '12:00 - 14:00',
          validationToken: 'expired-token',
          expiresAtUtc: expiredDate,
          status: 'Validated',
          statusText: 'Validated',
          nextAction: 'TakeConditionPhoto',
        ),
      );

      await tester.pumpWidget(buildScreen());
      await pumpScreen(tester);

      await sendIntent(tester, const ValidateBarcodeEvent('BOX-101'));

      // Since token is expired, requiresRescan is true
      expect(viewModel.state.requiresRescan, isTrue);
    });
  });
}
