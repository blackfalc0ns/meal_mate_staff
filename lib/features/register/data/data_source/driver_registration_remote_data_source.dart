import 'dart:io';

import '../models/request/driver_registration_request_dto.dart';
import '../models/request/driver_resubmit_request_dto.dart';
import '../models/response/driver_file_upload_response_dto.dart';
import '../models/response/driver_registration_response_dto.dart';
import '../models/response/driver_restaurant_response_dto.dart';
import '../models/response/driver_nationality_response_dto.dart';
import '../models/response/driver_vehicle_color_response_dto.dart';
import '../models/response/driver_vehicle_model_response_dto.dart';
import '../models/response/driver_vehicle_type_response_dto.dart';

abstract class DriverRegistrationRemoteDataSource {
  Future<List<DriverRestaurantResponseDto>> getRestaurants();

  Future<List<DriverNationalityResponseDto>> getNationalities();

  Future<List<DriverVehicleTypeResponseDto>> getVehicleTypes();

  Future<List<DriverVehicleColorResponseDto>> getVehicleColors();

  Future<List<DriverVehicleModelResponseDto>> searchVehicleModels({
    String? search,
    String? vehicleType,
    int limit = 40,
  });

  Future<DriverFileUploadResponseDto> uploadDocument(File file);

  Future<DriverRegistrationResponseDto> submitRegistration(
    DriverRegistrationRequestDto request,
  );

  Future<DriverRegistrationResponseDto> resubmitRegistration(
    String registrationId,
    DriverResubmitRequestDto request,
  );
}
