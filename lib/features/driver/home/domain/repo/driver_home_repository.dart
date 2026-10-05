import 'package:meal_mate_delivery/core/network/api_results.dart';
import '../entities/driver_home_entity.dart';

abstract interface class DriverHomeRepository {
  Future<ApiResult<DriverHomeEntity>> getDriverHome();
}
