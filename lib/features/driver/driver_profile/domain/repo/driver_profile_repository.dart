import '../../../../../core/network/api_results.dart';
import '../entities/driver_profile_entity.dart';

abstract interface class DriverProfileRepository {
  Future<ApiResult<DriverProfileEntity>> getProfile();
}
