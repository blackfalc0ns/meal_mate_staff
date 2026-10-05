import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_services.dart';
import '../models/response/driver_home_response_dto.dart';
import 'driver_home_remote_data_source.dart';

@Injectable(as: DriverHomeRemoteDataSource)
class DriverHomeRemoteDataSourceImpl implements DriverHomeRemoteDataSource {
  DriverHomeRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<DriverHomeResponseDto> getDriverHome() {
    return _apiServices.getDriverHome();
  }
}
