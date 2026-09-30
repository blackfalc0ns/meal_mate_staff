import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_services.dart';
import '../models/response/driver_profile_response_dto.dart';
import 'driver_profile_remote_data_source.dart';

@LazySingleton(as: DriverProfileRemoteDataSource)
class DriverProfileRemoteDataSourceImpl
    implements DriverProfileRemoteDataSource {
  const DriverProfileRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<DriverProfileResponseDto> getProfile() =>
      _apiServices.getDriverProfile();
}
