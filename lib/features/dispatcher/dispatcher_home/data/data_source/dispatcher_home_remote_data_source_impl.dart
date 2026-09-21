import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_services.dart';
import '../models/response/dispatcher_dashboard_overview_response_dto.dart';
import '../models/response/dispatcher_live_driver_response_dto.dart';
import 'dispatcher_home_remote_data_source.dart';

@LazySingleton(as: DispatcherHomeRemoteDataSource)
class DispatcherHomeRemoteDataSourceImpl
    implements DispatcherHomeRemoteDataSource {
  const DispatcherHomeRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<DispatcherDashboardOverviewResponseDto> getOverview() =>
      _apiServices.getDispatcherDashboardOverview();

  @override
  Future<List<DispatcherLiveDriverResponseDto>> getLiveDrivers() =>
      _apiServices.getDispatcherLiveLocations();
}
