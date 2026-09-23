import 'active_delivery_location_entity.dart';

class ReturnBoxEntity {
  const ReturnBoxEntity({
    required this.boxCode,
    required this.restaurantName,
    required this.restaurantAddress,
    required this.restaurantLocation,
    required this.failureReason,
    this.note,
    this.attachmentPath,
  });

  final String boxCode;
  final String restaurantName;
  final String restaurantAddress;
  final ActiveDeliveryLocationEntity restaurantLocation;
  final String failureReason;
  final String? note;
  final String? attachmentPath;
}
