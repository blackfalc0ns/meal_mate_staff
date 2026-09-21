import '../models/response/dispatcher_dashboard_overview_response_dto.dart';
import '../models/response/dispatcher_live_driver_response_dto.dart';

abstract class DispatcherHomeRemoteDataSource {
  Future<DispatcherDashboardOverviewResponseDto> getOverview();
  Future<List<DispatcherLiveDriverResponseDto>> getLiveDrivers();
}
