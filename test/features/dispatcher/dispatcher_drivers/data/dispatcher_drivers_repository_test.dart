import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/core/network/failures.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/data/data_source/dispatcher_drivers_remote_data_source.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/data/models/request/assign_driver_request_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/data/models/response/dispatcher_drivers_roster_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/data/models/response/driver_assignment_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/data/repo/dispatcher_drivers_repository_impl.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/assign_driver_request_entity.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_driver_view_mode.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_drivers/domain/entities/dispatcher_drivers_query_entity.dart';

class FakeDispatcherDriversRemoteDataSource
    implements DispatcherDriversRemoteDataSource {
  DispatcherDriversRosterResponseDto? rosterResponse;
  DriverAssignmentResponseDto? assignResponse;
  Object? errorToThrow;
  String? lastView;
  String? lastArea;
  String? lastBoxId;
  String? lastAssignBoxId;
  AssignDriverRequestDto? lastAssignRequest;

  @override
  Future<DispatcherDriversRosterResponseDto> getRoster({
    required String view,
    String? area,
    String? boxId,
  }) async {
    lastView = view;
    lastArea = area;
    lastBoxId = boxId;
    if (errorToThrow != null) throw errorToThrow!;
    return rosterResponse ?? const DispatcherDriversRosterResponseDto();
  }

  @override
  Future<DriverAssignmentResponseDto> assignDriver({
    required String boxId,
    required AssignDriverRequestDto request,
  }) async {
    lastAssignBoxId = boxId;
    lastAssignRequest = request;
    if (errorToThrow != null) throw errorToThrow!;
    return assignResponse ?? const DriverAssignmentResponseDto();
  }
}

void main() {
  late FakeDispatcherDriversRemoteDataSource fakeDataSource;
  late DispatcherDriversRepositoryImpl repository;

  setUp(() {
    fakeDataSource = FakeDispatcherDriversRemoteDataSource();
    repository = DispatcherDriversRepositoryImpl(fakeDataSource);
  });

  group('DispatcherDriversRepository.getRoster', () {
    const query = DispatcherDriversQueryEntity(
      view: DispatcherDriverViewMode.byArea,
      areaKey: 'salmiya',
    );

    test('returns ApiSuccessResult when remote data source succeeds', () async {
      fakeDataSource.rosterResponse = const DispatcherDriversRosterResponseDto(
        counts: DispatcherDriversCountsDto(
          totalCount: 10,
          availableCount: 6,
          busyCount: 4,
        ),
        selectedView: 'ByArea',
        selectedArea: 'السالمية',
        selectedAreaKey: 'salmiya',
        sectionTitle: 'سائقو السالمية (6)',
        areas: [],
        drivers: [],
      );

      final result = await repository.getRoster(query);

      expect(result, isA<ApiSuccessResult>());
      final data = (result as ApiSuccessResult).data;
      expect(data.counts.totalCount, 10);
      expect(data.selectedAreaKey, 'salmiya');
      expect(fakeDataSource.lastView, 'ByArea');
      expect(fakeDataSource.lastArea, 'salmiya');
    });

    test('returns ApiErrorResult with ServerFailure on DioException', () async {
      fakeDataSource.errorToThrow = DioException(
        requestOptions: RequestOptions(
          path: '/api/v1/dispatcher/drivers/roster',
        ),
        response: Response(
          requestOptions: RequestOptions(
            path: '/api/v1/dispatcher/drivers/roster',
          ),
          statusCode: 500,
          data: {'message': 'Server error'},
        ),
        type: DioExceptionType.badResponse,
      );

      final result = await repository.getRoster(query);

      expect(result, isA<ApiErrorResult>());
      final failure = (result as ApiErrorResult).failure;
      expect(failure, isA<ServerFailure>());
    });
  });

  group('DispatcherDriversRepository.assignDriver', () {
    const request = AssignDriverRequestEntity(
      boxId: 'a1111111-1111-1111-1111-111111111111',
      driverId: '11111111-1111-1111-1111-111111111111',
      notes: 'إسناد مباشر من قائمة السائقين',
    );

    test('returns ApiSuccessResult when assignment succeeds', () async {
      fakeDataSource.assignResponse = const DriverAssignmentResponseDto(
        success: true,
        message: 'تم الإسناد بنجاح',
        boxId: 'a1111111-1111-1111-1111-111111111111',
        driverId: '11111111-1111-1111-1111-111111111111',
      );

      final result = await repository.assignDriver(request);

      expect(result, isA<ApiSuccessResult>());
      final data = (result as ApiSuccessResult).data;
      expect(data.success, isTrue);
      expect(data.message, 'تم الإسناد بنجاح');
      expect(fakeDataSource.lastAssignBoxId, request.boxId);
      expect(fakeDataSource.lastAssignRequest?.driverId, request.driverId);
    });

    test('returns ApiErrorResult when assignment hits 409 conflict', () async {
      fakeDataSource.errorToThrow = DioException(
        requestOptions: RequestOptions(path: '/assign'),
        response: Response(
          requestOptions: RequestOptions(path: '/assign'),
          statusCode: 409,
          data: {'message': 'البوكس مسند مسبقاً'},
        ),
        type: DioExceptionType.badResponse,
      );

      final result = await repository.assignDriver(request);

      expect(result, isA<ApiErrorResult>());
      final failure = (result as ApiErrorResult).failure;
      expect(failure, isA<ServerFailure>());
    });
  });
}
