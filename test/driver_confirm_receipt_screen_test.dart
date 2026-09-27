import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/services/idempotency_key_factory.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_assigned_box_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_box_delivery_status.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/confirm_driver_pickup_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/driver_barcode_validation_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/driver_condition_photo_upload_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/driver_pickup_confirmation_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/entities/validate_driver_barcode_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/repo/driver_pickup_repository.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/usecase/confirm_driver_box_pickup_usecase.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/usecase/upload_driver_box_condition_photo_usecase.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/domain/usecase/validate_driver_pickup_barcode_usecase.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/manager/driver_pickup_flow_view_model.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/screens/driver_confirm_receipt_screen.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_camera_viewfinder.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_manual_code_button.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_qr_header_section.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_qr_viewfinder.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_receipt_stepper_bar.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_step2_preview_card.dart';

import 'support/fakes/fake_driver_pickup_location_provider.dart';

class _MockImagePickerPlatform extends ImagePickerPlatform {
  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    return XFile('test_photo.jpg');
  }
}

class _FakePickupRepo implements DriverPickupRepository {
  @override
  Future<ApiResult<DriverBarcodeValidationEntity>> validateDriverPickupBarcode(
    ValidateDriverBarcodeRequestEntity request,
  ) async {
    return const ApiSuccessResult(
      data: DriverBarcodeValidationEntity(
        boxId: 'box-1256',
        boxCode: '#BOX-1256',
        customerName: 'Ahmad Ali',
        deliveryZone: 'حي النرجس',
        mealsCount: 3,
        deliveryTimeSlot: '12:00 - 14:00',
        validationToken: 'val-token',
        expiresAtUtc: null,
        status: 'Validated',
        statusText: 'تم التحقق',
        nextAction: 'TakeConditionPhoto',
      ),
    );
  }

  @override
  Future<ApiResult<DriverConditionPhotoUploadEntity>>
  uploadDriverBoxConditionPhoto({
    required String boxId,
    required File file,
    required String validationToken,
  }) async {
    return const ApiSuccessResult(
      data: DriverConditionPhotoUploadEntity(
        boxId: 'box-1256',
        conditionPhotoStorageKey: 'key-1256',
        uploadedAtUtc: null,
        status: 'Uploaded',
        statusText: 'تم الرفع',
        nextAction: 'ConfirmPickup',
      ),
    );
  }

  @override
  Future<ApiResult<DriverPickupConfirmationEntity>> confirmDriverBoxPickup({
    required String boxId,
    required String idempotencyKey,
    required ConfirmDriverPickupRequestEntity request,
  }) async {
    return const ApiSuccessResult(
      data: DriverPickupConfirmationEntity(
        boxId: 'box-1256',
        boxCode: '#BOX-1256',
        tripId: 'trip-1',
        confirmedAtUtc: null,
        status: 'PickedUp',
        statusText: 'تم الاستلام',
        nextAction: DriverPickupNextAction.showBoxSuccess,
        pickedUpBoxesCount: 1,
        totalBoxesCount: 5,
        allBoxesPickedUp: false,
      ),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FixedKeyFactory implements IdempotencyKeyFactory {
  @override
  String create() => 'test-idemp-key';
}

void main() {
  late _FakePickupRepo fakeRepo;
  late DriverPickupFlowViewModel viewModel;
  late MobileScannerController testScannerController;

  setUp(() {
    ImagePickerPlatform.instance = _MockImagePickerPlatform();
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

  tearDown(() {
    viewModel.close();
    testScannerController.dispose();
  });

  Widget buildSubject({
    DriverAssignedBoxEntity? box,
    Locale locale = const Locale('ar'),
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      home: DriverConfirmReceiptScreen(
        box:
            box ??
            const DriverAssignedBoxEntity(
              boxId: '#BOX-1256',
              boxCode: '#BOX-1256',
              customerName: 'Ahmad Ali',
              deliveryZone: 'حي النرجس',
              mealsCount: 3,
              mealsSummary: '3 وجبات',
              deliveryTimeSlot: '12:00 - 14:00',
              status: DriverBoxDeliveryStatus.pendingScan,
              statusText: 'لم يتم التحميل',
            ),
        scannerController: testScannerController,
        viewModel: viewModel,
      ),
    );
  }

  testWidgets('renders Step 1 (QR Scanner) with all components in Arabic', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject());
    await tester.pump(const Duration(milliseconds: 300));

    // Title and Stepper
    expect(find.text('تأكيد استلام الطلب'), findsOneWidget);
    expect(find.byType(DriverReceiptStepperBar), findsOneWidget);
    expect(find.text('مسح QR'), findsOneWidget);
    expect(find.text('تصوير البوكس'), findsWidgets);
    expect(
      find.text('الترتيب إلزامي: مسح QR أولاً ثم تصوير البوكس'),
      findsOneWidget,
    );

    // QR Header and Viewfinder
    expect(find.byType(DriverQrHeaderSection), findsOneWidget);
    expect(find.text('ماسح QR'), findsOneWidget);
    expect(find.text('الفلاش'), findsOneWidget);
    expect(find.byType(DriverQrViewfinder), findsOneWidget);
    expect(
      find.text('وجه الكاميرا نحو رمز QR الظاهر على البوكس'),
      findsOneWidget,
    );

    // Manual code & Step 2 preview
    expect(find.byType(DriverManualCodeButton), findsOneWidget);
    expect(find.text('إدخال الرمز يدوياً'), findsOneWidget);
    expect(find.byType(DriverStep2PreviewCard), findsOneWidget);
    expect(find.text('متابعة إلى تصوير البوكس'), findsOneWidget);
  });

  testWidgets(
    'transitions from Step 1 to Step 2 when QR is scanned and photo is captured',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 300));

      // Before scan, tapping continue does nothing (disabled button)
      final continueBtnBeforeScan = find.text('متابعة إلى تصوير البوكس');
      await tester.tap(continueBtnBeforeScan);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.byType(DriverCameraViewfinder), findsNothing);

      // Tap manual code entry to trigger WoltModalSheet
      final manualCodeBtn = find.text('إدخال الرمز يدوياً');
      await tester.tap(manualCodeBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Enter code in text field
      await tester.enterText(find.byType(TextField), '#BOX-1256');
      await tester.pump(const Duration(milliseconds: 100));

      // Confirm manual code in the modal sheet
      final confirmCodeBtn = find.text('تأكيد');
      expect(confirmCodeBtn, findsOneWidget);
      await tester.tap(confirmCodeBtn);
      await tester.runAsync(() async {
        await pumpEventQueue();
      });
      await tester.pump(const Duration(milliseconds: 300));

      // Tap continue to Step 2 (now active)
      final continueBtn = find.text('متابعة إلى تصوير البوكس');
      await tester.ensureVisible(continueBtn);
      await tester.tap(continueBtn);
      await tester.runAsync(() async {
        await pumpEventQueue();
      });
      await tester.pump(const Duration(milliseconds: 300));

      // Now on Step 2: Camera
      expect(find.byType(DriverCameraViewfinder), findsOneWidget);
      expect(find.text('وجه الكاميرا نحو البوكس بالكامل'), findsWidgets);
      expect(find.text('أخذ صورة'), findsOneWidget);

      // Capture photo
      final takePhotoBtn = find.text('أخذ صورة');
      await tester.tap(takePhotoBtn);
      await tester.runAsync(() async {
        await pumpEventQueue();
      });
      await tester.pump(const Duration(milliseconds: 300));

      // Now button becomes "تأكيد التسليم"
      expect(find.text('تأكيد التسليم'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
    },
  );
}
