import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_assigned_box_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_box_delivery_status.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/screens/driver_confirm_receipt_screen.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_camera_viewfinder.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_manual_code_button.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_qr_header_section.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_qr_viewfinder.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_receipt_stepper_bar.dart';
import 'package:meal_mate_delivery/features/driver/confirm_receipt/presentation/widgets/driver_step2_preview_card.dart';

class _MockImagePickerPlatform extends ImagePickerPlatform {
  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    return XFile('test_photo.jpg');
  }
}

void main() {
  setUp(() {
    ImagePickerPlatform.instance = _MockImagePickerPlatform();
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
      supportedLocales: const [
        Locale('ar'),
        Locale('en'),
      ],
      home: DriverConfirmReceiptScreen(
        box: box ??
            const DriverAssignedBoxEntity(
              boxId: '#BOX-1256',
              orderCode: '#MM-1256',
              mealCount: 3,
              area: 'حي النرجس',
              status: DriverBoxDeliveryStatus.notLoaded,
            ),
      ),
    );
  }

  testWidgets(
    'renders Step 1 (QR Scanner) with all components in Arabic',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 400));

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
    },
  );

  testWidgets(
    'transitions from Step 1 to Step 2 when QR is scanned and photo is captured',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pump(const Duration(milliseconds: 400));

      // Before scan, tapping continue does nothing (disabled button)
      final continueBtnBeforeScan = find.text('متابعة إلى تصوير البوكس');
      await tester.tap(continueBtnBeforeScan);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(DriverCameraViewfinder), findsNothing);

      // Tap manual code entry to trigger scan success
      final manualCodeBtn = find.text('إدخال الرمز يدوياً');
      await tester.tap(manualCodeBtn);
      await tester.pump(const Duration(milliseconds: 300));

      // Tap continue to Step 2 (now active)
      final continueBtn = find.text('متابعة إلى تصوير البوكس');
      await tester.tap(continueBtn);
      await tester.pump(const Duration(milliseconds: 300));

      // Now on Step 2: Camera
      expect(find.byType(DriverCameraViewfinder), findsOneWidget);
      expect(find.text('وجه الكاميرا نحو البوكس بالكامل'), findsWidgets);
      expect(find.text('تأكيد التسليم'), findsOneWidget);

      // Capture photo
      final shutterBtn = find.byIcon(Icons.camera_alt_rounded);
      await tester.tap(shutterBtn);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byIcon(Icons.check_circle_rounded), findsWidgets);
      await tester.pump(const Duration(seconds: 4));
    },
  );
}
