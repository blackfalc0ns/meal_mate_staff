import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/features/driver/driver_vehicle/domain/entities/driver_vehicle_entity.dart';
import 'package:meal_mate_delivery/features/driver/driver_vehicle/presentation/screens/driver_edit_vehicle_details_screen.dart';
import 'package:meal_mate_delivery/features/driver/driver_vehicle/presentation/screens/driver_vehicle_details_screen.dart';
import 'package:meal_mate_delivery/features/driver/driver_vehicle/presentation/widgets/driver_edit_vehicle_bottom_actions.dart';
import 'package:meal_mate_delivery/features/driver/driver_vehicle/presentation/widgets/driver_edit_vehicle_photo_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_vehicle/presentation/widgets/driver_vehicle_header.dart';
import 'package:meal_mate_delivery/features/driver/driver_vehicle/presentation/widgets/driver_vehicle_kuwait_plate.dart';
import 'package:meal_mate_delivery/features/driver/driver_vehicle/presentation/widgets/driver_vehicle_license_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_vehicle/presentation/widgets/driver_vehicle_notice_card.dart';
import 'package:meal_mate_delivery/features/driver/driver_vehicle/presentation/widgets/driver_vehicle_overview_card.dart';

void main() {
  Widget buildDetailsSubject({
    DriverVehicleEntity? vehicle,
    Locale locale = const Locale('ar'),
    VoidCallback? onEdit,
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
      home: DriverVehicleDetailsScreen(
        vehicle: vehicle,
        onEdit: onEdit,
      ),
    );
  }

  Widget buildEditSubject({
    DriverVehicleEntity? vehicle,
    Locale locale = const Locale('ar'),
    ValueChanged<DriverVehicleEntity>? onSaveSuccess,
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
      home: DriverEditVehicleDetailsScreen(
        vehicle: vehicle,
        onSaveSuccess: onSaveSuccess,
      ),
    );
  }

  group('DriverVehicleDetailsScreen', () {
    testWidgets('renders all major components and cards in RTL Arabic', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildDetailsSubject());
      await tester.pumpAndSettle();

      expect(find.byType(DriverVehicleHeader), findsOneWidget);
      expect(find.byType(DriverVehicleOverviewCard), findsOneWidget);
      expect(find.byType(DriverVehicleLicenseCard), findsOneWidget);
      expect(find.byType(DriverVehicleKuwaitPlate), findsOneWidget);
      expect(find.byType(DriverVehicleNoticeCard), findsOneWidget);

      expect(find.text('بيانات المركبة'), findsOneWidget);
      expect(find.text('تويوتا كورولا'), findsOneWidget);
      expect(find.text('أبيض'), findsOneWidget);
      expect(find.text('2022'), findsOneWidget);
      expect(find.text('سيدان'), findsOneWidget);
      expect(find.text('رقم اللوحة'), findsOneWidget);
      expect(find.text('12345'), findsOneWidget);
      expect(find.text('KWT-9876543'), findsOneWidget);
      expect(find.text('15 مارس 2026'), findsOneWidget);
      expect(find.text('ملاحظة'), findsOneWidget);
      expect(find.text('تعديل'), findsOneWidget);
    });

    testWidgets('renders all major components in English LTR without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildDetailsSubject(locale: const Locale('en')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Vehicle Details'), findsOneWidget);
      expect(find.text('Plate Number'), findsOneWidget);
      expect(find.text('Note'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
    });

    testWidgets('tapping edit button triggers onEdit callback', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool editCalled = false;
      await tester.pumpWidget(
        buildDetailsSubject(onEdit: () => editCalled = true),
      );
      await tester.pumpAndSettle();

      final editButton = find.text('تعديل');
      await tester.ensureVisible(editButton);
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      expect(editCalled, isTrue);
    });
  });

  group('DriverEditVehicleDetailsScreen', () {
    testWidgets('renders all form fields and action buttons in RTL Arabic', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildEditSubject());
      await tester.pumpAndSettle();

      expect(find.byType(DriverVehicleHeader), findsOneWidget);
      expect(find.byType(DriverEditVehiclePhotoCard), findsOneWidget);
      expect(find.byType(DriverEditVehicleBottomActions), findsOneWidget);

      expect(find.text('تعديل بيانات المركبة'), findsOneWidget);
      expect(find.text('صورة المركبة'), findsOneWidget);
      expect(find.text('نوع المركبة'), findsOneWidget);
      expect(find.text('موديل المركبة'), findsOneWidget);
      expect(find.text('سنة الصنع'), findsOneWidget);
      expect(find.text('لون المركبة'), findsOneWidget);
      expect(find.text('رقم الرخصة'), findsOneWidget);
      expect(find.text('تاريخ انتهاء الرخصة'), findsOneWidget);
      expect(find.text('ملاحظات إضافية ( اختياري )'), findsOneWidget);
      expect(find.text('إلغاء'), findsOneWidget);
      expect(find.text('حفظ التغييرات'), findsOneWidget);
    });

    testWidgets('renders in English LTR without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildEditSubject(locale: const Locale('en')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Vehicle Details'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);
    });

    testWidgets(
        'save button is disabled initially and enabled after editing a field', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      DriverVehicleEntity? savedVehicle;
      await tester.pumpWidget(
        buildEditSubject(
          onSaveSuccess: (vehicle) => savedVehicle = vehicle,
        ),
      );
      await tester.pumpAndSettle();

      final saveButton = find.text('حفظ التغييرات');
      await tester.ensureVisible(saveButton);

      // Initially no changes: tapping should NOT save
      await tester.tap(saveButton);
      await tester.pump();
      expect(savedVehicle, isNull);

      // Edit a field
      final brandField = find.byType(TextFormField).first;
      await tester.enterText(brandField, 'تويوتا كامري');
      await tester.pumpAndSettle();

      // Now save button is enabled
      await tester.tap(saveButton);
      await tester.pump();

      expect(savedVehicle, isNotNull);
      expect(savedVehicle!.brandAndModel, 'تويوتا كامري');
    });
  });
}
