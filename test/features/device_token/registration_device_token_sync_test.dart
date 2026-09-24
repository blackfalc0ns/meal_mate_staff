import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/core/services/push_notification_coordinator.dart';
import 'package:meal_mate_delivery/features/device_token/domain/entities/device_token_sync_context.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_file_upload_result_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_nationality_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_registration_draft_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_registration_result_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_resubmit_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_restaurant_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_vehicle_color_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_vehicle_model_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/entities/driver_vehicle_type_entity.dart';
import 'package:meal_mate_delivery/features/register/domain/repo/driver_registration_repository.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/get_driver_nationalities_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/get_driver_restaurants_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/get_driver_vehicle_colors_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/get_driver_vehicle_types_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/resubmit_driver_registration_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/search_driver_vehicle_models_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/submit_driver_registration_usecase.dart';
import 'package:meal_mate_delivery/features/register/domain/usecase/upload_driver_document_usecase.dart';
import 'package:meal_mate_delivery/features/register/presentation/manager/driver_registration_event.dart';
import 'package:meal_mate_delivery/features/register/presentation/manager/driver_registration_state.dart';
import 'package:meal_mate_delivery/features/register/presentation/manager/driver_registration_view_model.dart';

class _FakeRegistrationRepository implements DriverRegistrationRepository {
  ApiResult<DriverRegistrationResultEntity>? submitResult;
  ApiResult<DriverRegistrationResultEntity>? resubmitResult;

  @override
  Future<ApiResult<DriverRegistrationResultEntity>> submitRegistration(
    DriverRegistrationDraftEntity draft,
  ) async {
    return submitResult!;
  }

  @override
  Future<ApiResult<DriverRegistrationResultEntity>> resubmitRegistration({
    required String registrationId,
    required DriverResubmitEntity resubmitData,
  }) async {
    return resubmitResult!;
  }

  @override
  Future<ApiResult<List<DriverRestaurantEntity>>> getRestaurants() async =>
      const ApiSuccessResult(data: []);
  @override
  Future<ApiResult<List<DriverNationalityEntity>>> getNationalities() async =>
      const ApiSuccessResult(data: []);
  @override
  Future<ApiResult<List<DriverVehicleTypeEntity>>> getVehicleTypes() async =>
      const ApiSuccessResult(data: []);
  @override
  Future<ApiResult<List<DriverVehicleColorEntity>>> getVehicleColors() async =>
      const ApiSuccessResult(data: []);
  @override
  Future<ApiResult<List<DriverVehicleModelEntity>>> searchVehicleModels({
    String? search,
    String? vehicleType,
    int limit = 40,
  }) async => const ApiSuccessResult(data: []);
  @override
  Future<ApiResult<DriverFileUploadResultEntity>> uploadDocument(
    File file,
  ) async => throw UnimplementedError();
}

class _FakePushNotificationCoordinator implements PushNotificationCoordinator {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;

  final List<DeviceTokenSyncContext> syncedContexts = [];
  bool shouldThrow = false;

  @override
  Future<void> updateSyncContext(DeviceTokenSyncContext context) async {
    if (shouldThrow) {
      throw Exception('FCM synchronization failed');
    }
    syncedContexts.add(context);
  }

  @override
  Future<void> clearSyncContextAndDeactivate() async {}
  @override
  DeviceTokenSyncContext? get currentContext =>
      syncedContexts.isNotEmpty ? syncedContexts.last : null;
  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
  @override
  Future<void> handleLocalNotificationTap(String? rawJson) async {}
}

void main() {
  late _FakeRegistrationRepository repository;
  late _FakePushNotificationCoordinator coordinator;
  late DriverRegistrationViewModel viewModel;

  setUp(() {
    repository = _FakeRegistrationRepository();
    coordinator = _FakePushNotificationCoordinator();
    viewModel = DriverRegistrationViewModel(
      getRestaurantsUseCase: GetDriverRestaurantsUseCase(repository),
      getNationalitiesUseCase: GetDriverNationalitiesUseCase(repository),
      getVehicleTypesUseCase: GetDriverVehicleTypesUseCase(repository),
      getVehicleColorsUseCase: GetDriverVehicleColorsUseCase(repository),
      searchVehicleModelsUseCase: SearchDriverVehicleModelsUseCase(repository),
      uploadDocumentUseCase: UploadDriverDocumentUseCase(repository),
      submitRegistrationUseCase: SubmitDriverRegistrationUseCase(repository),
      resubmitRegistrationUseCase: ResubmitDriverRegistrationUseCase(
        repository,
      ),
      pushNotificationCoordinator: coordinator,
    );
  });

  group('DriverRegistrationViewModel device token sync', () {
    test(
      'successful submission syncs pre-login context with registrationId',
      () async {
        repository.submitResult = const ApiSuccessResult(
          data: DriverRegistrationResultEntity(
            registrationId: 'reg-new-123',
            restaurantId: 'rest-1',
            restaurantName: 'Test Restaurant',
            phone: '+96512345678',
            status: 'under_review',
            message: 'Submitted successfully',
          ),
        );

        viewModel.doIntent(const DriverRegistrationSubmitEvent());

        await Future<void>.delayed(Duration.zero);

        expect(
          viewModel.state.status,
          DriverRegistrationStatus.submissionSuccess,
        );
        expect(coordinator.syncedContexts.length, 1);
        final ctx = coordinator.syncedContexts.first;
        expect(ctx, isA<DriverPreLoginSyncContext>());
        expect(
          (ctx as DriverPreLoginSyncContext).registrationId,
          'reg-new-123',
        );
      },
    );

    test(
      'successful resubmission syncs pre-login context with registrationId',
      () async {
        repository.resubmitResult = const ApiSuccessResult(
          data: DriverRegistrationResultEntity(
            registrationId: 'reg-resubmit-456',
            restaurantId: 'rest-1',
            restaurantName: 'Test Restaurant',
            phone: '+96512345678',
            status: 'under_review',
            message: 'Resubmitted successfully',
          ),
        );

        viewModel.doIntent(
          const DriverRegistrationResubmitEvent(
            registrationId: 'reg-resubmit-456',
            resubmitData: DriverResubmitEntity(),
          ),
        );

        await Future<void>.delayed(Duration.zero);

        expect(
          viewModel.state.status,
          DriverRegistrationStatus.resubmissionSuccess,
        );
        expect(coordinator.syncedContexts.length, 1);
        final ctx = coordinator.syncedContexts.first;
        expect(ctx, isA<DriverPreLoginSyncContext>());
        expect(
          (ctx as DriverPreLoginSyncContext).registrationId,
          'reg-resubmit-456',
        );
      },
    );

    test('failed submission does not sync device token', () async {
      repository.submitResult = ApiErrorResult(
        failure: Failure(errorMessage: 'Validation failed'),
      );

      viewModel.doIntent(const DriverRegistrationSubmitEvent());

      await Future<void>.delayed(Duration.zero);

      expect(viewModel.state.status, DriverRegistrationStatus.error);
      expect(coordinator.syncedContexts, isEmpty);
    });

    test('submission state succeeds even if coordinator sync throws', () async {
      coordinator.shouldThrow = true;
      repository.submitResult = const ApiSuccessResult(
        data: DriverRegistrationResultEntity(
          registrationId: 'reg-robust-789',
          restaurantId: 'rest-1',
          restaurantName: 'Test Restaurant',
          phone: '+96512345678',
          status: 'under_review',
          message: 'Submitted successfully',
        ),
      );

      viewModel.doIntent(const DriverRegistrationSubmitEvent());

      await Future<void>.delayed(Duration.zero);

      expect(
        viewModel.state.status,
        DriverRegistrationStatus.submissionSuccess,
      );
    });
  });
}
