import 'dart:io';
import '../../../../../features/driver/confirm_receipt/data/models/request/start_driver_trip_request_dto.dart';
import '../models/response/driver_start_delivery_response_dto.dart';

import 'package:injectable/injectable.dart';

import '../../../../../core/network/api_services.dart';
import '../models/request/driver_arrival_request_dto.dart';
import '../models/request/driver_deliver_request_dto.dart';
import '../models/response/driver_arrival_response_dto.dart';
import '../models/response/driver_deliver_response_dto.dart';
import '../models/response/driver_delivery_proof_upload_response_dto.dart';
import 'driver_delivery_remote_data_source.dart';

@Injectable(as: DriverDeliveryRemoteDataSource)
class DriverDeliveryRemoteDataSourceImpl
    implements DriverDeliveryRemoteDataSource {
  const DriverDeliveryRemoteDataSourceImpl(this._apiServices);

  final ApiServices _apiServices;

  @override
  Future<DriverStartDeliveryResponseDto> startDelivery({
    required String tripId,
    required double latitude,
    required double longitude,
    required String idempotencyKey,
  }) async {
    final response = await _apiServices.startDriverTrip(
      tripId,
      idempotencyKey,
      StartDriverTripRequestDto(latitude: latitude, longitude: longitude),
    );
    return DriverStartDeliveryResponseDto(
      tripId: response.tripId,
      status: response.status,
      startedAtUtc: response.startedAtUtc,
    );
  }

  @override
  Future<DriverArrivalResponseDto> arriveAtCustomer({
    required String boxId,
    required DriverArrivalRequestDto request,
  }) {
    return _apiServices.arriveAtDriverCustomer(boxId, request);
  }

  @override
  Future<DriverDeliveryProofUploadResponseDto> uploadProof({
    required File file,
  }) {
    return _apiServices.uploadDriverDeliveryProof(file);
  }

  @override
  Future<DriverDeliverResponseDto> deliverOrder({
    required String boxId,
    required DriverDeliverRequestDto request,
  }) {
    return _apiServices.deliverDriverOrder(boxId, request);
  }
}
