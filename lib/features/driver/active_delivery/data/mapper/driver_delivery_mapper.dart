import '../../domain/entities/driver_arrival_request_entity.dart';
import '../../domain/entities/driver_arrival_result_entity.dart';
import '../../domain/entities/driver_deliver_request_entity.dart';
import '../../domain/entities/driver_deliver_result_entity.dart';
import '../../domain/entities/driver_delivery_proof_upload_entity.dart';
import '../models/request/driver_arrival_request_dto.dart';
import '../models/request/driver_deliver_request_dto.dart';
import '../models/response/driver_arrival_response_dto.dart';
import '../models/response/driver_deliver_response_dto.dart';
import '../models/response/driver_delivery_proof_upload_response_dto.dart';

extension DriverArrivalRequestEntityMapper on DriverArrivalRequestEntity {
  DriverArrivalRequestDto toDto() {
    final lat = latitude;
    final lng = longitude;
    final isValidPair =
        lat != null &&
        lng != null &&
        lat.isFinite &&
        lng.isFinite &&
        lat >= -90.0 &&
        lat <= 90.0 &&
        lng >= -180.0 &&
        lng <= 180.0;

    return DriverArrivalRequestDto(
      latitude: isValidPair ? lat : null,
      longitude: isValidPair ? lng : null,
    );
  }
}

extension DriverDeliverRequestEntityMapper on DriverDeliverRequestEntity {
  DriverDeliverRequestDto toDto() {
    final lat = latitude;
    final lng = longitude;
    final isValidPair =
        lat != null &&
        lng != null &&
        lat.isFinite &&
        lng.isFinite &&
        lat >= -90.0 &&
        lat <= 90.0 &&
        lng >= -180.0 &&
        lng <= 180.0;

    final trimmedOtp = deliveryOtp?.trim();
    final validOtp = (trimmedOtp != null && trimmedOtp.length == 4)
        ? trimmedOtp
        : null;

    return DriverDeliverRequestDto(
      proofPhotoStorageKey: proofPhotoStorageKey.trim(),
      latitude: isValidPair ? lat : null,
      longitude: isValidPair ? lng : null,
      deliveryOtp: validOtp,
    );
  }
}

extension DriverArrivalResponseDtoMapper on DriverArrivalResponseDto {
  DriverArrivalResultEntity toEntity({String fallbackBoxId = ''}) {
    final cleanBoxId = boxId?.trim();
    final resolvedBoxId = (cleanBoxId != null && cleanBoxId.isNotEmpty)
        ? cleanBoxId
        : fallbackBoxId;

    final parsedTime = arrivedAtUtc != null
        ? DateTime.tryParse(arrivedAtUtc!.trim())?.toUtc()
        : null;

    return DriverArrivalResultEntity(
      boxId: resolvedBoxId,
      arrivedAtUtc: parsedTime ?? DateTime.now().toUtc(),
      isFirstArrival: isFirstArrival,
      status: status,
      message: message,
    );
  }
}

extension DriverDeliverResponseDtoMapper on DriverDeliverResponseDto {
  DriverDeliverResultEntity toEntity({String fallbackBoxId = ''}) {
    final cleanBoxId = boxId?.trim();
    final resolvedBoxId = (cleanBoxId != null && cleanBoxId.isNotEmpty)
        ? cleanBoxId
        : fallbackBoxId;

    final parsedTime = deliveredAtUtc != null
        ? DateTime.tryParse(deliveredAtUtc!.trim())?.toUtc()
        : null;

    return DriverDeliverResultEntity(
      boxId: resolvedBoxId,
      deliveredAtUtc: parsedTime ?? DateTime.now().toUtc(),
      tripId: tripId?.trim(),
      isTripCompleted: isTripCompleted,
      remainingStopsCount: remainingStopsCount,
      driverId: driverId?.trim(),
      isFirstDelivery: isFirstDelivery,
    );
  }
}

extension DriverDeliveryProofUploadResponseDtoMapper
    on DriverDeliveryProofUploadResponseDto {
  DriverDeliveryProofUploadEntity toEntity() {
    final parsedTime = uploadedAtUtc != null
        ? DateTime.tryParse(uploadedAtUtc!.trim())?.toUtc()
        : null;

    return DriverDeliveryProofUploadEntity(
      storageKey: storageKey?.trim() ?? '',
      uploadedAtUtc: parsedTime,
    );
  }
}
