import 'dart:io';

import '../../../../core/network/api_results.dart';
import '../entities/driver_file_upload_result_entity.dart';
import '../entities/driver_registration_draft_entity.dart';
import '../entities/driver_registration_result_entity.dart';
import '../entities/driver_restaurant_entity.dart';
import '../entities/driver_resubmit_entity.dart';

abstract class DriverRegistrationRepository {
  Future<ApiResult<List<DriverRestaurantEntity>>> getRestaurants();

  Future<ApiResult<DriverFileUploadResultEntity>> uploadDocument(File file);

  Future<ApiResult<DriverRegistrationResultEntity>> submitRegistration(
    DriverRegistrationDraftEntity draft,
  );

  Future<ApiResult<DriverRegistrationResultEntity>> resubmitRegistration({
    required String registrationId,
    required DriverResubmitEntity resubmitData,
  });
}
