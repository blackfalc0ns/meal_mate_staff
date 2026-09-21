import 'dart:io';

import '../../../../core/network/api_results.dart';
import '../entities/driver_file_upload_result_entity.dart';
import '../entities/driver_registration_draft_entity.dart';
import '../entities/driver_registration_result_entity.dart';
import '../entities/driver_restaurant_entity.dart';
import '../entities/driver_nationality_entity.dart';
import '../entities/driver_resubmit_entity.dart';
import '../entities/driver_vehicle_color_entity.dart';
import '../entities/driver_vehicle_model_entity.dart';
import '../entities/driver_vehicle_type_entity.dart';

abstract class DriverRegistrationRepository {
  Future<ApiResult<List<DriverRestaurantEntity>>> getRestaurants();

  Future<ApiResult<List<DriverNationalityEntity>>> getNationalities();

  Future<ApiResult<List<DriverVehicleTypeEntity>>> getVehicleTypes();

  Future<ApiResult<List<DriverVehicleColorEntity>>> getVehicleColors();

  Future<ApiResult<List<DriverVehicleModelEntity>>> searchVehicleModels({
    String? search,
    String? vehicleType,
    int limit = 40,
  });

  Future<ApiResult<DriverFileUploadResultEntity>> uploadDocument(File file);

  Future<ApiResult<DriverRegistrationResultEntity>> submitRegistration(
    DriverRegistrationDraftEntity draft,
  );

  Future<ApiResult<DriverRegistrationResultEntity>> resubmitRegistration({
    required String registrationId,
    required DriverResubmitEntity resubmitData,
  });
}
