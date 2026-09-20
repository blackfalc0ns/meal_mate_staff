import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../core/network/api_services.dart';
import '../models/request/driver_registration_request_dto.dart';
import '../models/request/driver_resubmit_request_dto.dart';
import '../models/response/driver_file_upload_response_dto.dart';
import '../models/response/driver_registration_response_dto.dart';
import '../models/response/driver_restaurant_response_dto.dart';
import 'driver_registration_remote_data_source.dart';

@LazySingleton(as: DriverRegistrationRemoteDataSource)
class DriverRegistrationRemoteDataSourceImpl
    implements DriverRegistrationRemoteDataSource {
  const DriverRegistrationRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<List<DriverRestaurantResponseDto>> getRestaurants() =>
      _apiServices.getDriverRestaurants();

  @override
  Future<DriverFileUploadResponseDto> uploadDocument(File file) =>
      _apiServices.uploadDriverDocument(file);

  @override
  Future<DriverRegistrationResponseDto> submitRegistration(
    DriverRegistrationRequestDto request,
  ) =>
      _apiServices.submitDriverRegistration(request);

  @override
  Future<DriverRegistrationResponseDto> resubmitRegistration(
    String registrationId,
    DriverResubmitRequestDto request,
  ) =>
      _apiServices.resubmitDriverRegistration(registrationId, request);
}
