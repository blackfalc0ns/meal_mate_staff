import 'dart:io';
import '../models/response/driver_start_delivery_response_dto.dart';

import '../models/request/driver_arrival_request_dto.dart';
import '../models/request/driver_deliver_request_dto.dart';
import '../models/response/driver_arrival_response_dto.dart';
import '../models/response/driver_deliver_response_dto.dart';
import '../models/response/driver_delivery_proof_upload_response_dto.dart';

abstract interface class DriverDeliveryRemoteDataSource {
  Future<DriverStartDeliveryResponseDto> startDelivery({required String boxId});

  Future<DriverArrivalResponseDto> arriveAtCustomer({
    required String boxId,
    required DriverArrivalRequestDto request,
  });

  Future<DriverDeliveryProofUploadResponseDto> uploadProof({
    required File file,
  });

  Future<DriverDeliverResponseDto> deliverOrder({
    required String boxId,
    required DriverDeliverRequestDto request,
  });
}
