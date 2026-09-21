import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/core/network/api_results.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/data/data_source/dispatcher_home_remote_data_source.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/data/models/response/dispatcher_dashboard_overview_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/data/models/response/dispatcher_live_driver_response_dto.dart';
import 'package:meal_mate_delivery/features/dispatcher/dispatcher_home/data/repo/dispatcher_home_repository_impl.dart';

void main() {
  test('maps both dispatcher home resources on success', () async {
    final repository = DispatcherHomeRepositoryImpl(_SuccessDataSource());

    final overview = await repository.getOverview();
    final drivers = await repository.getLiveDrivers();

    expect(overview, isA<ApiSuccessResult>());
    expect((overview as ApiSuccessResult).data.kpis.totalOrdersToday, 12);
    expect(drivers, isA<ApiSuccessResult>());
    expect((drivers as ApiSuccessResult).data.single.plateNumber, 'KWT-1');
  });

  test('converts transport failures into ApiErrorResult', () async {
    final repository = DispatcherHomeRepositoryImpl(_FailingDataSource());

    expect(await repository.getOverview(), isA<ApiErrorResult>());
    expect(await repository.getLiveDrivers(), isA<ApiErrorResult>());
  });
}

class _SuccessDataSource implements DispatcherHomeRemoteDataSource {
  @override
  Future<DispatcherDashboardOverviewResponseDto> getOverview() async {
    return DispatcherDashboardOverviewResponseDto.fromJson(const {
      'kpis': {'totalOrdersToday': 12},
    });
  }

  @override
  Future<List<DispatcherLiveDriverResponseDto>> getLiveDrivers() async {
    return [
      DispatcherLiveDriverResponseDto.fromJson(const {
        'driverId': 'driver-1',
        'plateNumber': 'KWT-1',
      }),
    ];
  }
}

class _FailingDataSource implements DispatcherHomeRemoteDataSource {
  DioException get _error => DioException(
    requestOptions: RequestOptions(path: '/dispatcher'),
    type: DioExceptionType.connectionError,
  );

  @override
  Future<DispatcherDashboardOverviewResponseDto> getOverview() =>
      Future.error(_error);

  @override
  Future<List<DispatcherLiveDriverResponseDto>> getLiveDrivers() =>
      Future.error(_error);
}
