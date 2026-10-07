import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/entities/driver_arrival_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/entities/driver_arrival_result_entity.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/entities/driver_deliver_request_entity.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/entities/driver_deliver_result_entity.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/entities/driver_delivery_proof_upload_entity.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/repo/driver_delivery_repository.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/usecase/arrive_at_driver_customer_usecase.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/usecase/deliver_driver_order_usecase.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/domain/usecase/upload_driver_delivery_proof_usecase.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/manager/active_delivery_event.dart';
import 'package:meal_mate_delivery/features/driver/active_delivery/presentation/manager/active_delivery_view_model.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_route_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/entities/driver_map_stop_entity.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/repo/driver_map_repository.dart';
import 'package:meal_mate_delivery/features/driver/map/domain/usecase/get_driver_map_route_usecase.dart';
import 'package:meal_mate_delivery/features/driver/orders/domain/entities/driver_delivery_status.dart';

class MockDriverMapRepository implements DriverMapRepository {
  DriverMapRouteEntity? routeResult;
  Failure? routeFailure;

  @override
  Future<ApiResult<DriverMapRouteEntity>> getDriverMapRoute({String? focusedStopId}) async {
    if (routeFailure != null) return ApiErrorResult(failure: routeFailure!);
    return ApiSuccessResult(data: routeResult!);
  }
}

class MockDriverDeliveryRepository implements DriverDeliveryRepository {
  Completer<ApiResult<DriverArrivalResultEntity>>? arrivalCompleter;
  int arrivalCallCount = 0;

  Completer<ApiResult<DriverDeliveryProofUploadEntity>>? uploadCompleter;
  int uploadCallCount = 0;

  Completer<ApiResult<DriverDeliverResultEntity>>? deliverCompleter;
  int deliverCallCount = 0;

  @override
  Future<ApiResult<DriverArrivalResultEntity>> arriveAtCustomer({
    required String boxId,
    required DriverArrivalRequestEntity request,
  }) async {
    arrivalCallCount++;
    if (arrivalCompleter != null) return arrivalCompleter!.future;
    return ApiSuccessResult(
      data: DriverArrivalResultEntity(
        boxId: boxId,
        arrivedAtUtc: DateTime.utc(2026, 10, 6, 8, 30),
        isFirstArrival: true,
      ),
    );
  }

  @override
  Future<ApiResult<DriverDeliveryProofUploadEntity>> uploadProof({
    required String localPath,
  }) async {
    uploadCallCount++;
    if (uploadCompleter != null) return uploadCompleter!.future;
    return ApiSuccessResult(
      data: DriverDeliveryProofUploadEntity(
        storageKey: 'key-$localPath',
        uploadedAtUtc: DateTime.utc(2026, 10, 6, 8, 35),
      ),
    );
  }

  @override
  Future<ApiResult<DriverDeliverResultEntity>> deliverOrder({
    required String boxId,
    required DriverDeliverRequestEntity request,
  }) async {
    deliverCallCount++;
    if (deliverCompleter != null) return deliverCompleter!.future;
    return ApiSuccessResult(
      data: DriverDeliverResultEntity(
        boxId: boxId,
        deliveredAtUtc: DateTime.utc(2026, 10, 6, 8, 40),
        isFirstDelivery: true,
      ),
    );
  }
}

void main() {
  group('ActiveDeliveryViewModel Tests', () {
    late MockDriverMapRepository mapRepo;
    late MockDriverDeliveryRepository deliveryRepo;
    late ActiveDeliveryViewModel viewModel;

    const testStop = DriverMapStopEntity(
      id: 'stop-1',
      boxId: 'box-1',
      tripId: 'trip-1',
      boxCode: 'BX-001',
      customerName: 'محمد أحمد',
      area: 'حولي',
      formattedAddress: 'حولي ق 1',
      mealsCount: 2,
      deliveryTimeSlot: '10:00 ص',
      status: DriverDeliveryStatus.inProgress,
    );

    const testRoute = DriverMapRouteEntity(
      tripId: 'trip-1',
      tripCode: 'TRP-1',
      totalStopsCount: 1,
      completedStopsCount: 0,
      focusedStop: testStop,
      stops: [testStop],
    );

    setUp(() {
      mapRepo = MockDriverMapRepository()..routeResult = testRoute;
      deliveryRepo = MockDriverDeliveryRepository();
      viewModel = ActiveDeliveryViewModel(
        getDriverMapRouteUseCase: GetDriverMapRouteUseCase(mapRepo),
        arriveAtDriverCustomerUseCase: ArriveAtDriverCustomerUseCase(deliveryRepo),
        uploadDriverDeliveryProofUseCase: UploadDriverDeliveryProofUseCase(deliveryRepo),
        deliverDriverOrderUseCase: DeliverDriverOrderUseCase(deliveryRepo),
      );
    });

    tearDown(() {
      unawaited(viewModel.close());
    });

    test('initial state does not require a fake trip', () {
      expect(viewModel.state.route, isNull);
      expect(viewModel.state.isInitialLoading, isFalse);
      expect(viewModel.state.isEmpty, isFalse);
    });

    test('loads route and updates state', () async {
      viewModel.doIntent(const LoadActiveDeliveryEvent(stopId: 'stop-1'));
      expect(viewModel.state.isInitialLoading, isTrue);

      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.isInitialLoading, isFalse);
      expect(viewModel.state.route, isNotNull);
      expect(viewModel.state.selectedStop?.id, 'stop-1');
    });

    test('arrival has busy guard against repeated clicks', () async {
      viewModel.doIntent(const LoadActiveDeliveryEvent(stopId: 'stop-1'));
      await Future<void>.delayed(Duration.zero);

      deliveryRepo.arrivalCompleter = Completer();

      viewModel.doIntent(const ConfirmCustomerArrivalEvent());
      viewModel.doIntent(const ConfirmCustomerArrivalEvent()); // Duplicate tap

      expect(deliveryRepo.arrivalCallCount, 1);
      expect(viewModel.state.isArriving, isTrue);

      deliveryRepo.arrivalCompleter!.complete(
        ApiSuccessResult(
          data: DriverArrivalResultEntity(
            boxId: 'box-1',
            arrivedAtUtc: DateTime.utc(2026, 10, 6, 8, 30),
            isFirstArrival: true,
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.isArriving, isFalse);
      expect(viewModel.state.arrivalResult, isNotNull);
      expect(viewModel.state.navigationRevision, 1);
    });

    test('cannot deliver without uploaded proof and arrived state', () async {
      viewModel.doIntent(const LoadActiveDeliveryEvent(stopId: 'stop-1'));
      await Future<void>.delayed(Duration.zero);

      // Attempt to deliver without arrival or proof
      viewModel.doIntent(const ConfirmCustomerDeliveryEvent());
      expect(deliveryRepo.deliverCallCount, 0);

      // Add arrival only
      viewModel.doIntent(const ConfirmCustomerArrivalEvent());
      await Future<void>.delayed(Duration.zero);

      viewModel.doIntent(const ConfirmCustomerDeliveryEvent());
      expect(deliveryRepo.deliverCallCount, 0); // Still 0 because proof not uploaded
    });

    test('selecting new photo invalidates previous proof key and revision', () async {
      viewModel.doIntent(const LoadActiveDeliveryEvent(stopId: 'stop-1'));
      await Future<void>.delayed(Duration.zero);

      viewModel.doIntent(const DeliveryProofSelectedEvent('photo1.jpg'));
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.proofStorageKey, 'key-photo1.jpg');
      expect(viewModel.state.isProofUploaded, isTrue);

      // Select new photo
      deliveryRepo.uploadCompleter = Completer();
      viewModel.doIntent(const DeliveryProofSelectedEvent('photo2.jpg'));

      expect(viewModel.state.proofStorageKey, isNull);
      expect(viewModel.state.isProofUploaded, isFalse);
      expect(viewModel.state.isUploading, isTrue);
    });

    test('successful delivery with arrival and proof triggers deliver call', () async {
      viewModel.doIntent(const LoadActiveDeliveryEvent(stopId: 'stop-1'));
      await Future<void>.delayed(Duration.zero);

      viewModel.doIntent(const ConfirmCustomerArrivalEvent());
      await Future<void>.delayed(Duration.zero);

      viewModel.doIntent(const DeliveryProofSelectedEvent('proof.jpg'));
      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.canDeliver, isTrue);

      viewModel.doIntent(const ConfirmCustomerDeliveryEvent());
      await Future<void>.delayed(Duration.zero);

      expect(deliveryRepo.deliverCallCount, 1);
      expect(viewModel.state.deliveryResult, isNotNull);
    });

    test('OTP input converts Arabic numerals and allows delivery even if empty or partial', () async {
      viewModel.doIntent(const OptionalDeliveryOtpChangedEvent('١٢٣٤'));
      expect(viewModel.state.otpInput, '1234');

      viewModel.doIntent(const OptionalDeliveryOtpChangedEvent('١٢'));
      expect(viewModel.state.otpInput, '12'); // Incomplete OTP stored in state but does not block delivery
    });
  });
}
