import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:meal_mate_delivery/config/routing/routing_generator.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_assigned_box_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_box_delivery_status.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_boxes_filter_type.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_pickup_manifest_entity.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/repo/driver_pickup_manifest_repository.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/usecase/get_driver_pickup_manifest_usecase.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/manager/driver_pickup_manifest_view_model.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/screens/driver_assigned_boxes_screen.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_assigned_box_card.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_boxes_delivery_mode_chip.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_boxes_filter_bar.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_boxes_header_logo.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_boxes_stats_banner.dart';
import 'package:meal_mate_delivery/features/driver/orders/presentation/widgets/driver_boxes_title_bar.dart';

class _MockImagePickerPlatform extends ImagePickerPlatform {
  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async {
    return XFile('test_photo.jpg');
  }
}

class _FakeManifestRepo implements DriverPickupManifestRepository {
  _FakeManifestRepo(this.manifest);
  final DriverPickupManifestEntity manifest;

  @override
  Future<ApiResult<DriverPickupManifestEntity>> getDriverPickupManifest({
    DriverBoxesFilterType filter = DriverBoxesFilterType.all,
  }) async {
    return ApiSuccessResult(data: manifest);
  }
}

void main() {
  setUp(() {
    ImagePickerPlatform.instance = _MockImagePickerPlatform();
  });

  const sampleBoxes = [
    DriverAssignedBoxEntity(
      boxId: 'box-1',
      boxCode: '#BOX-1256',
      customerName: 'Ahmad Ali',
      deliveryZone: 'حي النرجس',
      mealsCount: 3,
      mealsSummary: '3 وجبات',
      deliveryTimeSlot: '12:00 - 14:00',
      status: DriverBoxDeliveryStatus.pendingScan,
      statusText: 'لم يتم التحميل',
      isPickedUp: false,
    ),
    DriverAssignedBoxEntity(
      boxId: 'box-2',
      boxCode: '#BOX-1257',
      customerName: 'Sara Ali',
      deliveryZone: 'حي الياسمين',
      mealsCount: 4,
      mealsSummary: '4 وجبات',
      deliveryTimeSlot: '14:00 - 16:00',
      status: DriverBoxDeliveryStatus.pickedUp,
      statusText: 'تم الاستلام',
      isPickedUp: true,
    ),
  ];

  const sampleManifest = DriverPickupManifestEntity(
    tripId: 'trip-1',
    tripCode: 'TRIP-1',
    driverId: 'drv-1',
    driverName: 'Driver Name',
    totalBoxesCount: 15,
    totalMealsCount: 53,
    pendingScanBoxesCount: 14,
    pickedUpBoxesCount: 1,
    allBoxesPickedUp: false,
    canStartTrip: false,
    boxes: sampleBoxes,
  );

  Widget buildSubject({
    Locale locale = const Locale('ar'),
    DriverPickupManifestEntity manifest = sampleManifest,
  }) {
    final repo = _FakeManifestRepo(manifest);
    final vm = DriverPickupManifestViewModel(
      getManifestUseCase: GetDriverPickupManifestUseCase(repo),
    );

    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: AppTheme.lightTheme,
      onGenerateRoute: RouteGenerator.getRoute,
      home: DriverAssignedBoxesScreen(viewModel: vm),
    );
  }

  testWidgets(
    'renders driver assigned boxes screen with all sections in Arabic',
    (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildSubject());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Top Header Logo
      expect(find.byType(DriverBoxesHeaderLogo), findsOneWidget);

      // Title Bar and Delivery Mode
      expect(find.byType(DriverBoxesTitleBar), findsOneWidget);
      expect(find.text('قائمة الصناديق'), findsOneWidget);
      expect(find.text('الصناديق المخصصة قبل التوصيل'), findsOneWidget);
      expect(find.byType(DriverBoxesDeliveryModeChip), findsOneWidget);
      expect(find.text('أنت في وضع التوصيل'), findsOneWidget);

      // Stats Banner
      expect(find.byType(DriverBoxesStatsBanner), findsOneWidget);
      expect(find.text('53'), findsOneWidget);
      expect(find.text('إجمالي الوجبات'), findsOneWidget);
      expect(find.text('15'), findsOneWidget);
      expect(find.text('إجمالي الصناديق المخصصة اليوم'), findsOneWidget);

      // Filter Bar
      expect(find.byType(DriverBoxesFilterBar), findsOneWidget);
      expect(find.text('الكل'), findsOneWidget);
      expect(find.text('لم يتم التحميل'), findsWidgets);

      // Cards
      expect(find.byType(DriverAssignedBoxCard), findsWidgets);
      expect(find.text('#BOX-1256'), findsOneWidget);
      expect(find.text('#BOX-1257'), findsOneWidget);
      expect(find.text('استكمال\nالاجراء'), findsOneWidget);
    },
  );

  testWidgets('renders correctly in English', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(buildSubject(locale: const Locale('en')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Boxes List'), findsOneWidget);
    expect(find.text('Assigned boxes before delivery'), findsOneWidget);
    expect(find.text('You are in delivery mode'), findsOneWidget);
    expect(find.text('Total Meals'), findsOneWidget);
    expect(find.text('Total boxes assigned today'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
  });
}
