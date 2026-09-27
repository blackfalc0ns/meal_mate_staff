import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';
import 'package:meal_mate_delivery/core/errors/error_widgets/api_error_widget.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_details_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_document_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_location_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_performance_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_status_type.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_driver_vehicle_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/dispatcher_drivers_status_summary_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/update_driver_availability_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/entities/update_driver_availability_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/repo/dispatcher_drivers_status_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/usecase/get_dispatcher_driver_details_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/domain/usecase/toggle_driver_availability_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/manager/dispatcher_driver_details_view_model.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/screens/dispatcher_driver_status_details_screen.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/services/driver_contact_launcher.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_driver_details_app_bar.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_driver_details_contact_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_driver_details_documents_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_driver_details_location_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_driver_details_metrics_row.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_driver_details_performance_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_driver_details_profile_card.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_driver_details_shimmer.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers_status/presentation/widgets/dispatcher_driver_details_vehicle_card.dart';

class _FakeContactLauncher implements DriverContactLauncher {
  bool calledPhone = false;
  bool calledWhatsApp = false;

  @override
  Uri? phoneUri(String? phone) =>
      phone != null ? Uri.parse('tel:$phone') : null;

  @override
  Uri? smsUri(String? phone) => phone != null ? Uri.parse('sms:$phone') : null;

  @override
  Uri? whatsAppUri(String? phone) =>
      phone != null ? Uri.parse('https://wa.me/$phone') : null;

  @override
  Future<bool> launchPhone(String? phoneNumber) async {
    calledPhone = true;
    return true;
  }

  @override
  Future<bool> launchSms(String? phoneNumber) async => true;

  @override
  Future<bool> launchWhatsApp(String? phoneNumber) async {
    calledWhatsApp = true;
    return true;
  }
}

class _FakeDriversRepo implements DispatcherDriversStatusRepository {
  ApiResult<DispatcherDriverDetailsEntity>? detailsResult;
  ApiResult<UpdateDriverAvailabilityResultEntity>? toggleResult;
  Completer<ApiResult<DispatcherDriverDetailsEntity>>? delayCompleter;

  static const defaultDetails = DispatcherDriverDetailsEntity(
    driverId: '4a6f235e-c04d-45db-9c3f-c39775c96da1',
    name: 'أحمد محمد',
    code: '#KD-4582',
    phoneNumber: '+965 5012 3456',
    rating: 4.8,
    reviewCount: 128,
    isOnline: true,
    isAvailable: true,
    operationalStatus: DispatcherDriverStatusType.available,
    totalOrdersToday: 12,
    workTimeMinutesToday: 345,
    distanceKmToday: 68.5,
    activeOrdersToday: 2,
    vehicle: DispatcherDriverVehicleEntity(
      model: 'تويوتا كورولا',
      colorName: 'أبيض',
      plateNumber: '#KU-7319',
      vehicleType: 'Car',
    ),
    location: DispatcherDriverLocationEntity(
      areaName: 'المنطقة السالمية',
      latitude: 29.3375,
      longitude: 48.0233,
      updatedMinutesAgo: 2,
    ),
    performance: DispatcherDriverPerformanceEntity(
      totalOrders: 450,
      averageRating: 4.8,
      commitmentRatePercent: 98,
      violationsCount: 0,
    ),
    documents: [
      DispatcherDriverDocumentEntity(
        type: DispatcherDriverDocumentType.drivingLicense,
        status: DispatcherDriverDocumentStatus.valid,
        validUntil: '2027/12/31',
      ),
      DispatcherDriverDocumentEntity(
        type: DispatcherDriverDocumentType.vehicleRegistration,
        status: DispatcherDriverDocumentStatus.valid,
        validUntil: '2026/06/30',
      ),
      DispatcherDriverDocumentEntity(
        type: DispatcherDriverDocumentType.insurance,
        status: DispatcherDriverDocumentStatus.valid,
        validUntil: '2025/11/15',
      ),
    ],
  );

  @override
  Future<ApiResult<DispatcherDriverDetailsEntity>> getDriverDetails(
    String driverId,
  ) async {
    if (delayCompleter != null) return delayCompleter!.future;
    return detailsResult ?? const ApiSuccessResult(data: defaultDetails);
  }

  @override
  Future<ApiResult<UpdateDriverAvailabilityResultEntity>>
  toggleDriverAvailability(
    UpdateDriverAvailabilityRequestEntity request,
  ) async {
    return toggleResult ??
        ApiSuccessResult(
          data: UpdateDriverAvailabilityResultEntity(
            driverId: request.driverId,
            isAvailable: request.isAvailable,
            operationalStatus: request.isAvailable
                ? DispatcherDriverStatusType.available
                : DispatcherDriverStatusType.unavailable,
            updatedAtUtc: DateTime.now().toUtc(),
          ),
        );
  }

  @override
  Stream<UpdateDriverAvailabilityResultEntity> get driverAvailabilityUpdates =>
      const Stream.empty();

  @override
  Future<void> acquireRealtime(String ownerId) async {}

  @override
  Future<void> releaseRealtime(String ownerId) async {}

  @override
  Future<ApiResult<DispatcherDriversStatusSummaryEntity>> getDriversStatus([
    DispatcherDriversStatusQueryEntity query =
        const DispatcherDriversStatusQueryEntity(),
  ]) async => throw UnimplementedError();
}

void main() {
  late _FakeDriversRepo repo;
  late DispatcherDriverDetailsViewModel viewModel;

  setUp(() {
    repo = _FakeDriversRepo();
    viewModel = DispatcherDriverDetailsViewModel(
      driverId: '4a6f235e-c04d-45db-9c3f-c39775c96da1',
      getDriverDetailsUseCase: GetDispatcherDriverDetailsUseCase(repo),
      toggleDriverAvailabilityUseCase: ToggleDriverAvailabilityUseCase(repo),
    );
  });

  tearDown(() async {
    await viewModel.close();
  });

  Widget buildWidget({
    Locale locale = const Locale('ar'),
    DriverContactLauncher? contactLauncher,
    VoidCallback? onBack,
    VoidCallback? onOpenMap,
  }) {
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      home: DispatcherDriverStatusDetailsScreen(
        driverId: '4a6f235e-c04d-45db-9c3f-c39775c96da1',
        viewModel: viewModel,
        contactLauncher: contactLauncher ?? _FakeContactLauncher(),
        onBack: onBack,
        onOpenMap: onOpenMap,
      ),
    );
  }

  testWidgets('renders shimmer during initial load', (tester) async {
    repo.delayCompleter = Completer();
    viewModel = DispatcherDriverDetailsViewModel(
      driverId: '4a6f235e-c04d-45db-9c3f-c39775c96da1',
      getDriverDetailsUseCase: GetDispatcherDriverDetailsUseCase(repo),
      toggleDriverAvailabilityUseCase: ToggleDriverAvailabilityUseCase(repo),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pump();

    expect(find.byType(DispatcherDriverDetailsShimmer), findsOneWidget);

    repo.delayCompleter!.complete(
      const ApiSuccessResult(data: _FakeDriversRepo.defaultDetails),
    );
    await tester.pumpAndSettle();
  });

  testWidgets('renders ApiErrorWidget on load failure with retry', (
    tester,
  ) async {
    repo.detailsResult = ApiErrorResult(
      failure: Failure(errorMessage: 'Not Found'),
    );
    viewModel = DispatcherDriverDetailsViewModel(
      driverId: '4a6f235e-c04d-45db-9c3f-c39775c96da1',
      getDriverDetailsUseCase: GetDispatcherDriverDetailsUseCase(repo),
      toggleDriverAvailabilityUseCase: ToggleDriverAvailabilityUseCase(repo),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.byType(ApiErrorWidget), findsOneWidget);

    repo.detailsResult = null; // succeeds on retry
    await tester.tap(find.text('إعادة المحاولة'));
    await tester.pumpAndSettle();

    expect(find.byType(ApiErrorWidget), findsNothing);
    expect(find.byType(DispatcherDriverDetailsProfileCard), findsOneWidget);
  });

  testWidgets('renders all details cards with authentic domain content', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    // Verify AppBar
    expect(find.byType(DispatcherDriverDetailsAppBar), findsOneWidget);
    expect(find.text('تفاصيل السائق'), findsOneWidget);

    // Verify Profile Card
    expect(find.byType(DispatcherDriverDetailsProfileCard), findsOneWidget);
    expect(find.text('أحمد محمد'), findsOneWidget);
    expect(find.text('#KD-4582'), findsOneWidget);
    expect(find.text('4.8'), findsWidgets);
    expect(find.text('(128 تقييم)'), findsOneWidget);
    expect(find.text('متصل الآن'), findsOneWidget);
    expect(find.text('السائق متاح لإستقبال الطلبات'), findsOneWidget);

    // Verify Metrics Row
    expect(find.byType(DispatcherDriverDetailsMetricsRow), findsOneWidget);
    expect(find.text('إجمالي الطلبات'), findsWidgets);
    expect(find.text('وقت العمل اليوم'), findsOneWidget);
    expect(find.text('المسافة اليوم'), findsOneWidget);
    expect(find.text('الطلبات النشطة'), findsOneWidget);

    // Verify Contact Card
    expect(find.byType(DispatcherDriverDetailsContactCard), findsOneWidget);
    expect(find.text('+965 5012 3456'), findsOneWidget);
    expect(find.text('اتصال عبر الواتساب أو الجوال'), findsOneWidget);

    // Verify Vehicle Card
    expect(find.byType(DispatcherDriverDetailsVehicleCard), findsOneWidget);
    expect(find.text('تويوتا كورولا'), findsOneWidget);
    expect(find.text('أبيض'), findsOneWidget);
    expect(find.text('#KU-7319'), findsOneWidget);

    // Verify Location Card
    expect(find.byType(DispatcherDriverDetailsLocationCard), findsOneWidget);
    expect(find.text('المنطقة السالمية'), findsOneWidget);
    expect(find.text('عرض على الخريطة'), findsOneWidget);

    // Verify Performance Card
    expect(find.byType(DispatcherDriverDetailsPerformanceCard), findsOneWidget);
    expect(find.text('الأداء والتقييم'), findsOneWidget);
    expect(find.text('98%'), findsOneWidget);
    expect(find.text('معدل الالتزام'), findsOneWidget);
    expect(find.text('مخالفات'), findsOneWidget);

    // Verify Documents Card
    expect(find.byType(DispatcherDriverDetailsDocumentsCard), findsOneWidget);
    expect(find.text('المستندات'), findsOneWidget);
    expect(find.text('رخصة القيادة'), findsOneWidget);
    expect(find.text('استمارة المركبة'), findsOneWidget);
    expect(find.text('التأمين'), findsOneWidget);
  });

  testWidgets('toggle switch changes availability optimistically', (
    tester,
  ) async {
    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('السائق متاح لإستقبال الطلبات'), findsOneWidget);

    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(find.text('السائق غير متاح حالياً'), findsOneWidget);
  });

  testWidgets('calls contact launcher on phone and chat buttons tap', (
    tester,
  ) async {
    final launcher = _FakeContactLauncher();
    await tester.pumpWidget(buildWidget(contactLauncher: launcher));
    await tester.pumpAndSettle();

    // Tap call button
    final callButton = find.byIcon(Icons.phone_rounded);
    expect(callButton, findsOneWidget);
    await tester.tap(callButton);
    await tester.pumpAndSettle();
    expect(launcher.calledPhone, isTrue);

    // Tap chat button
    final chatButton = find.byIcon(Icons.chat_bubble_outline_rounded);
    expect(chatButton, findsOneWidget);
    await tester.tap(chatButton);
    await tester.pumpAndSettle();
    expect(launcher.calledWhatsApp, isTrue);
  });

  testWidgets('missing location shows no-location label and hides map', (
    tester,
  ) async {
    repo.detailsResult = const ApiSuccessResult(
      data: DispatcherDriverDetailsEntity(
        driverId: '4a6f235e-c04d-45db-9c3f-c39775c96da1',
        name: 'أحمد محمد',
        code: '#KD-4582',
        location: DispatcherDriverLocationEntity(
          areaName: '',
          latitude: null,
          longitude: null,
        ),
      ),
    );
    viewModel = DispatcherDriverDetailsViewModel(
      driverId: '4a6f235e-c04d-45db-9c3f-c39775c96da1',
      getDriverDetailsUseCase: GetDispatcherDriverDetailsUseCase(repo),
      toggleDriverAvailabilityUseCase: ToggleDriverAvailabilityUseCase(repo),
    );

    await tester.pumpWidget(buildWidget());
    await tester.pumpAndSettle();

    expect(find.text('لا تتوفر بيانات الموقع'), findsOneWidget);
    expect(find.text('عرض على الخريطة'), findsNothing);
  });
}
