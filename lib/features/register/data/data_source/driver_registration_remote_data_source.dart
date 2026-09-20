import 'dart:io';

import '../models/request/driver_registration_request_dto.dart';
import '../models/request/driver_resubmit_request_dto.dart';
import '../models/response/driver_file_upload_response_dto.dart';
import '../models/response/driver_registration_response_dto.dart';
import '../models/response/driver_restaurant_response_dto.dart';

abstract class DriverRegistrationRemoteDataSource {
  Future<List<DriverRestaurantResponseDto>> getRestaurants();

  Future<DriverFileUploadResponseDto> uploadDocument(File file);

  Future<DriverRegistrationResponseDto> submitRegistration(
    DriverRegistrationRequestDto request,
  );

  Future<DriverRegistrationResponseDto> resubmitRegistration(
    String registrationId,
    DriverResubmitRequestDto request,
  );
}
