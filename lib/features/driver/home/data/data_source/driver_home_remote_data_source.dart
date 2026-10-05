import '../models/response/driver_home_response_dto.dart';

abstract interface class DriverHomeRemoteDataSource {
  Future<DriverHomeResponseDto> getDriverHome();
}
