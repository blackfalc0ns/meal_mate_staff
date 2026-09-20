import '../../../../core/network/api_results.dart';
import '../entities/driver_registration_status_entity.dart';

abstract class AccountStatusRepository {
  Future<ApiResult<DriverRegistrationStatusEntity>> getRegistrationStatus({
    String? phone,
    String? registrationId,
  });
}
