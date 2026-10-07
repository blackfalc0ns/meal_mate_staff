import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meal_mate_delivery/core/l10n/translations/app_localizations.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/entities/driver_arrival_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/entities/driver_arrival_result_entity.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/entities/driver_deliver_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/entities/driver_deliver_result_entity.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/entities/driver_delivery_proof_upload_entity.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/repo/driver_delivery_repository.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/usecase/arrive_at_driver_customer_usecase.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/usecase/deliver_driver_order_usecase.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/usecase/upload_driver_delivery_proof_usecase.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/manager/active_delivery_view_model.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/screens/driver_delivery_arrival_confirmation_screen.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/services/driver_delivery_proof_camera.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/driver_delivery_arrival_banner.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/driver_delivery_customer_details_card.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/driver_delivery_optional_otp_section.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/widgets/driver_delivery_proof_photo_section.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_route_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_stop_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/repo/driver_map_repository.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/usecase/get_driver_map_route_usecase.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_delivery_status.dart';

class TestDriverMapRepository implements DriverMapRepository {
  TestDriverMapRepository(this.route);
  final DriverMapRouteEntity route;

  @override
  Future<ApiResult<DriverMapRouteEntity>> getDriverMapRoute({String? focusedStopId}) async {
    return ApiSuccessResult(data: route);
  }
}

class TestDriverDeliveryRepository implements DriverDeliveryRepository {
  TestDriverDeliveryRepository({
    this.uploadResult,
    this.deliverResult,
  });

  DriverDeliveryProofUploadEntity? uploadResult;
  DriverDeliverResultEntity? deliverResult;

  int uploadCallCount = 0;
  int deliverCallCount = 0;

  @override
  Future<ApiResult<DriverArrivalResultEntity>> arriveAtCustomer({
    required String boxId,
    required DriverArrivalRequestEntity request,
  }) async {
    return ApiSuccessResult(
      data: DriverArrivalResultEntity(
        boxId: boxId,
        status: 'arrived',
        arrivedAtUtc: DateTime.utc(2026, 10, 6, 12, 0),
      ),
    );
  }

  @override
  Future<ApiResult<DriverDeliveryProofUploadEntity>> uploadProof({
    required String localPath,
  }) async {
    uploadCallCount++;
    return ApiSuccessResult(
      data: uploadResult ??
          DriverDeliveryProofUploadEntity(
            storageKey: 'proofs/test_key.jpg',
            uploadedAtUtc: DateTime.utc(2026, 10, 6, 12, 1),
          ),
    );
  }

  @override
  Future<ApiResult<DriverDeliverResultEntity>> deliverOrder({
    required String boxId,
    required DriverDeliverRequestEntity request,
  }) async {
    deliverCallCount++;
    return ApiSuccessResult(
      data: deliverResult ??
          DriverDeliverResultEntity(
            boxId: boxId,
            deliveredAtUtc: DateTime.utc(2026, 10, 6, 12, 2),
            isTripCompleted: true,
            remainingStopsCount: 0,
          ),
    );
  }
}

class FakeCameraService implements DriverDeliveryProofCameraService {
  FakeCameraService({this.path = 'test_path.jpg'});
  final String? path;

  @override
  Future<String?> captureProofPhoto({ImagePicker? picker}) async {
    return path;
  }
}

Widget _buildTestApp({
  required Widget child,
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
    home: child,
  );
}

DriverMapRouteEntity _createTestRoute({bool arrived = true}) {
  final stop = DriverMapStopEntity(
    id: 'stop-101',
    boxId: 'box-202',
    boxCode: '#BX-202',
    customerName: 'فاطمة الكندري',
    area: 'حولي',
    formattedAddress: 'شارع تونس، مبنى 5، الدور 2',
    mealsCount: 2,
    deliveryTimeSlot: '11:00 - 01:00 م',
    status: DriverDeliveryStatus.inProgress,
    customerNote: 'يرجى وضع الصندوق عند الباب',
    arrivedAtUtc: arrived ? DateTime.utc(2026, 10, 6, 12, 0) : null,
  );

  return DriverMapRouteEntity(
    tripId: 'trip-999',
    tripCode: 'TRIP-999',
    totalStopsCount: 1,
    completedStopsCount: 0,
    focusedStop: stop,
    stops: [stop],
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DriverDeliveryArrivalConfirmationScreen Tests', () {
    testWidgets('renders all screen widgets properly', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      final mapRepo = TestDriverMapRepository(_createTestRoute());
      final deliveryRepo = TestDriverDeliveryRepository();
      final viewModel = ActiveDeliveryViewModel(
        getDriverMapRouteUseCase: GetDriverMapRouteUseCase(mapRepo),
        arriveAtDriverCustomerUseCase: ArriveAtDriverCustomerUseCase(deliveryRepo),
        uploadDriverDeliveryProofUseCase: UploadDriverDeliveryProofUseCase(deliveryRepo),
        deliverDriverOrderUseCase: DeliverDriverOrderUseCase(deliveryRepo),
      );
      addTearDown(viewModel.close);

      await tester.pumpWidget(
        _buildTestApp(
          child: DriverDeliveryArrivalConfirmationScreen(
            viewModel: viewModel,
            cameraService: FakeCameraService(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DriverDeliveryArrivalBanner), findsOneWidget);
      expect(find.byType(DriverDeliveryCustomerDetailsCard), findsOneWidget);
      expect(find.text('فاطمة الكندري'), findsOneWidget);
      expect(find.text('#BX-202'), findsOneWidget);
      expect(find.byType(DriverDeliveryProofPhotoSection), findsOneWidget);
      expect(find.byType(DriverDeliveryOptionalOtpSection), findsOneWidget);

      final submitButton = find.byKey(const ValueKey('confirm_delivery_submit_button'));
      expect(submitButton, findsOneWidget);
      final elevatedButton = tester.widget<ElevatedButton>(submitButton);
      expect(elevatedButton.onPressed, isNull); // disabled until photo uploaded
    });

    testWidgets('picking proof photo uploads and enables delivery confirmation button', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      final mapRepo = TestDriverMapRepository(_createTestRoute());
      final deliveryRepo = TestDriverDeliveryRepository();
      final viewModel = ActiveDeliveryViewModel(
        getDriverMapRouteUseCase: GetDriverMapRouteUseCase(mapRepo),
        arriveAtDriverCustomerUseCase: ArriveAtDriverCustomerUseCase(deliveryRepo),
        uploadDriverDeliveryProofUseCase: UploadDriverDeliveryProofUseCase(deliveryRepo),
        deliverDriverOrderUseCase: DeliverDriverOrderUseCase(deliveryRepo),
      );
      addTearDown(viewModel.close);

      bool deliveryConfirmedCalled = false;

      await tester.pumpWidget(
        _buildTestApp(
          child: DriverDeliveryArrivalConfirmationScreen(
            viewModel: viewModel,
            cameraService: FakeCameraService(path: 'dummy_photo.jpg'),
            onDeliveryConfirmed: () => deliveryConfirmedCalled = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byType(DriverDeliveryProofPhotoSection));
      await tester.tap(find.text('اضغط لالتقاط صورة'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(deliveryRepo.uploadCallCount, equals(1));
      expect(viewModel.state.isProofUploaded, isTrue);

      final submitButton = find.byKey(const ValueKey('confirm_delivery_submit_button'));
      final elevatedButton = tester.widget<ElevatedButton>(submitButton);
      expect(elevatedButton.onPressed, isNotNull);

      await tester.tap(submitButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(deliveryRepo.deliverCallCount, equals(1));
      expect(deliveryConfirmedCalled, isTrue);
    });

    testWidgets('renders in English LTR locale without issues', (tester) async {
      tester.view.physicalSize = const Size(390 * 2, 844 * 2);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.resetPhysicalSize);

      final mapRepo = TestDriverMapRepository(_createTestRoute());
      final deliveryRepo = TestDriverDeliveryRepository();
      final viewModel = ActiveDeliveryViewModel(
        getDriverMapRouteUseCase: GetDriverMapRouteUseCase(mapRepo),
        arriveAtDriverCustomerUseCase: ArriveAtDriverCustomerUseCase(deliveryRepo),
        uploadDriverDeliveryProofUseCase: UploadDriverDeliveryProofUseCase(deliveryRepo),
        deliverDriverOrderUseCase: DeliverDriverOrderUseCase(deliveryRepo),
      );
      addTearDown(viewModel.close);

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('en'),
          child: DriverDeliveryArrivalConfirmationScreen(
            viewModel: viewModel,
            cameraService: FakeCameraService(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Delivery Confirmation'), findsOneWidget);
      expect(find.text('Delivery Proof Photo'), findsOneWidget);
      expect(find.text('Confirm Delivery'), findsOneWidget);
    });
  });
}
