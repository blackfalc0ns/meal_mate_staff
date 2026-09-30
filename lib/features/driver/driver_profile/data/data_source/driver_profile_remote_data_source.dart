import '../models/response/driver_profile_response_dto.dart';

abstract interface class DriverProfileRemoteDataSource {
  Future<DriverProfileResponseDto> getProfile();
}
