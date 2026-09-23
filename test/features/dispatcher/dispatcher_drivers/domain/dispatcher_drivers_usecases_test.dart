import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/errors/api_error_type.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/assign_driver_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_view_mode.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_kpi_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_query_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_roster_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/driver_assignment_result_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/repo/dispatcher_drivers_repository.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/usecase/assign_driver_to_box_usecase.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/usecase/get_dispatcher_drivers_roster_usecase.dart';

class FakeDispatcherDriversRepository implements DispatcherDriversRepository {
  ApiResult<DispatcherDriversRosterEntity>? rosterResult;
  ApiResult<DriverAssignmentResultEntity>? assignResult;
  DispatcherDriversQueryEntity? lastQuery;
  AssignDriverRequestEntity? lastRequest;

  @override
  Future<ApiResult<DispatcherDriversRosterEntity>> getRoster(
    DispatcherDriversQueryEntity query,
  ) async {
    lastQuery = query;
    return rosterResult ??
        const ApiSuccessResult(
          data: DispatcherDriversRosterEntity(
            counts: DispatcherDriversKpiEntity(
              totalCount: 0,
              availableCount: 0,
              busyCount: 0,
            ),
            selectedView: DispatcherDriverViewMode.byArea,
            selectedAreaKey: null,
            selectedAreaName: '',
            sectionTitle: '',
            areas: [],
            drivers: [],
          ),
        );
  }

  @override
  Future<ApiResult<DriverAssignmentResultEntity>> assignDriver(
    AssignDriverRequestEntity request,
  ) async {
    lastRequest = request;
    return assignResult ??
        ApiSuccessResult(
          data: DriverAssignmentResultEntity(
            success: true,
            message: 'OK',
            boxId: request.boxId,
            driverId: request.driverId,
          ),
        );
  }
}

void main() {
  late FakeDispatcherDriversRepository fakeRepository;
  late GetDispatcherDriversRosterUseCase getRosterUseCase;
  late AssignDriverToBoxUseCase assignDriverUseCase;

  setUp(() {
    fakeRepository = FakeDispatcherDriversRepository();
    getRosterUseCase = GetDispatcherDriversRosterUseCase(fakeRepository);
    assignDriverUseCase = AssignDriverToBoxUseCase(fakeRepository);
  });

  group('GetDispatcherDriversRosterUseCase', () {
    test('delegates valid query to repository', () async {
      const query = DispatcherDriversQueryEntity(
        view: DispatcherDriverViewMode.byArea,
        areaKey: 'salmiya',
      );
      const expectedRoster = DispatcherDriversRosterEntity(
        counts: DispatcherDriversKpiEntity(
          totalCount: 1,
          availableCount: 1,
          busyCount: 0,
        ),
        selectedView: DispatcherDriverViewMode.byArea,
        selectedAreaKey: 'salmiya',
        selectedAreaName: 'السالمية',
        sectionTitle: 'سائقو السالمية (1)',
        areas: [],
        drivers: [],
      );

      fakeRepository.rosterResult = const ApiSuccessResult(
        data: expectedRoster,
      );

      final result = await getRosterUseCase(query);

      expect(result, isA<ApiSuccessResult<DispatcherDriversRosterEntity>>());
      expect(fakeRepository.lastQuery, query);
    });

    test('rejects empty areaKey with validation error', () async {
      const query = DispatcherDriversQueryEntity(
        view: DispatcherDriverViewMode.byArea,
        areaKey: '   ',
      );

      final result = await getRosterUseCase(query);

      expect(result, isA<ApiErrorResult<DispatcherDriversRosterEntity>>());
      final failure = (result as ApiErrorResult).failure;
      expect(failure.exception.errorType, ApiErrorType.validationError);
      expect(fakeRepository.lastQuery, isNull);
    });
  });

  group('AssignDriverToBoxUseCase', () {
    const validRequest = AssignDriverRequestEntity(
      boxId: 'a1111111-1111-1111-1111-111111111111',
      driverId: '11111111-1111-1111-1111-111111111111',
      notes: 'إسناد مباشر من قائمة السائقين',
    );

    test('delegates valid request to repository', () async {
      final expectedResult = DriverAssignmentResultEntity(
        success: true,
        message: 'تم الإسناد بنجاح',
        boxId: validRequest.boxId,
        driverId: validRequest.driverId,
      );

      fakeRepository.assignResult = ApiSuccessResult(data: expectedResult);

      final result = await assignDriverUseCase(validRequest);

      expect(result, isA<ApiSuccessResult<DriverAssignmentResultEntity>>());
      expect(fakeRepository.lastRequest, validRequest);
    });

    test('rejects blank boxId without calling repository', () async {
      const invalidReq = AssignDriverRequestEntity(
        boxId: '',
        driverId: '11111111-1111-1111-1111-111111111111',
        notes: 'ملاحظة',
      );

      final result = await assignDriverUseCase(invalidReq);

      expect(result, isA<ApiErrorResult<DriverAssignmentResultEntity>>());
      final failure = (result as ApiErrorResult).failure;
      expect(failure.exception.errorType, ApiErrorType.validationError);
      expect(fakeRepository.lastRequest, isNull);
    });

    test('rejects non-GUID boxId without calling repository', () async {
      const invalidReq = AssignDriverRequestEntity(
        boxId: 'not-a-guid',
        driverId: '11111111-1111-1111-1111-111111111111',
        notes: 'ملاحظة',
      );

      final result = await assignDriverUseCase(invalidReq);

      expect(result, isA<ApiErrorResult<DriverAssignmentResultEntity>>());
      final failure = (result as ApiErrorResult).failure;
      expect(failure.exception.errorType, ApiErrorType.validationError);
      expect(fakeRepository.lastRequest, isNull);
    });

    test('rejects non-GUID driverId without calling repository', () async {
      const invalidReq = AssignDriverRequestEntity(
        boxId: 'a1111111-1111-1111-1111-111111111111',
        driverId: 'invalid-driver',
        notes: 'ملاحظة',
      );

      final result = await assignDriverUseCase(invalidReq);

      expect(result, isA<ApiErrorResult<DriverAssignmentResultEntity>>());
      final failure = (result as ApiErrorResult).failure;
      expect(failure.exception.errorType, ApiErrorType.validationError);
      expect(fakeRepository.lastRequest, isNull);
    });

    test('rejects notes exceeding 500 characters', () async {
      final invalidReq = AssignDriverRequestEntity(
        boxId: 'a1111111-1111-1111-1111-111111111111',
        driverId: '11111111-1111-1111-1111-111111111111',
        notes: 'a' * 501,
      );

      final result = await assignDriverUseCase(invalidReq);

      expect(result, isA<ApiErrorResult<DriverAssignmentResultEntity>>());
      final failure = (result as ApiErrorResult).failure;
      expect(failure.exception.errorType, ApiErrorType.validationError);
      expect(fakeRepository.lastRequest, isNull);
    });
  });
}
