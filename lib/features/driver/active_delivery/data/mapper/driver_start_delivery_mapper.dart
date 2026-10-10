import '../../../../../core/errors/api_error_type.dart';
import '../../../../../core/errors/api_exception.dart';
import '../../domain/entities/driver_start_delivery_result_entity.dart';
import '../models/response/driver_start_delivery_response_dto.dart';

extension DriverStartDeliveryResponseMapper on DriverStartDeliveryResponseDto {
  DriverStartDeliveryResultEntity toEntity({
    required String expectedBoxId,
    required String expectedTripId,
  }) {
    final returnedBoxId = boxId?.trim();
    final returnedStatus = status?.trim();
    final returnedTripId = tripId?.trim();
    if ((returnedBoxId != null &&
            returnedBoxId.toLowerCase() != expectedBoxId.toLowerCase()) ||
        returnedTripId == null ||
        returnedTripId.toLowerCase() != expectedTripId.toLowerCase() ||
        returnedStatus != 'InTransit' &&
        returnedStatus != 'InProgress') {
      throw const ApiException(
        errorType: ApiErrorType.other,
        message: 'Something went wrong',
      );
    }
    final latitude = customer?.latitude;
    final longitude = customer?.longitude;
    final validCoordinates =
        latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
    final rawUrl = navigation?.url?.trim();
    final uri = rawUrl == null ? null : Uri.tryParse(rawUrl);
    final validUrl =
        uri != null &&
        uri.scheme == 'https' &&
        uri.host == 'www.google.com' &&
        uri.path.startsWith('/maps/');

    return DriverStartDeliveryResultEntity(
      boxId: expectedBoxId,
      status: returnedStatus!,
      tripId: returnedTripId,
      startedAtUtc: startedAtUtc == null
          ? null
          : DateTime.tryParse(startedAtUtc!)?.toUtc(),
      customerName: customer?.name,
      customerAddress: customer?.address,
      customerLatitude: validCoordinates ? latitude : null,
      customerLongitude: validCoordinates ? longitude : null,
      customerNotes: customer?.notes,
      orderCode: order?.code,
      boxCount: order?.boxCount,
      deliveryTimeSlot: order?.deliveryTimeSlot,
      navigationUrl: validUrl ? rawUrl : null,
    );
  }
}
