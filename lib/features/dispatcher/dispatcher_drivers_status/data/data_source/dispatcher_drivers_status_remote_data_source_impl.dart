import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_services.dart';
import '../models/request/update_driver_availability_request_dto.dart';
import '../models/response/dispatcher_driver_details_response_dto.dart';
import '../models/response/dispatcher_drivers_status_response_dto.dart';
import '../models/response/update_driver_availability_response_dto.dart';
import 'dispatcher_drivers_status_remote_data_source.dart';

@LazySingleton(as: DispatcherDriversStatusRemoteDataSource)
class DispatcherDriversStatusRemoteDataSourceImpl
    implements DispatcherDriversStatusRemoteDataSource {
  const DispatcherDriversStatusRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<DispatcherDriversStatusResponseDto> getDriversStatus({
    String? search,
    String status = 'All',
    String sortBy = 'Name',
    int pageNumber = 1,
    int pageSize = 15,
  }) {
    return _apiServices.getDispatcherDriversStatus(
      search: search,
      status: status,
      sortBy: sortBy,
      pageNumber: pageNumber,
      pageSize: pageSize,
    );
  }

  @override
  Future<UpdateDriverAvailabilityResponseDto> updateDriverAvailability(
    String driverId,
    UpdateDriverAvailabilityRequestDto request,
  ) {
    return _apiServices.updateDispatcherDriverAvailability(driverId, request);
  }

  @override
  Future<DispatcherDriverDetailsResponseDto> getDriverDetails(String driverId) {
    return _apiServices.getDispatcherDriverStatusDetails(driverId);
  }
}
