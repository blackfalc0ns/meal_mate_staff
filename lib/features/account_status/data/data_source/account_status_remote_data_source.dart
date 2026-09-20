import '../models/response/driver_registration_status_response_dto.dart';

abstract class AccountStatusRemoteDataSource {
  Future<DriverRegistrationStatusResponseDto> getRegistrationStatus({
    String? phone,
    String? registrationId,
  });
}
