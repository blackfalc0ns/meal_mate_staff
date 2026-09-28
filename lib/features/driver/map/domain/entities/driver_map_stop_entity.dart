import '../../../orders/domain/entities/driver_delivery_status.dart';

class DriverMapStopEntity {
  const DriverMapStopEntity({
    required this.id,
    required this.boxCode,
    required this.sequenceNumber,
    required this.totalStops,
    required this.customerName,
    required this.customerPhone,
    required this.area,
    required this.formattedAddress,
    required this.mealsCount,
    required this.deliveryTimeSlot,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.imageAsset,
  });

  final String id;
  final String boxCode;
  final int sequenceNumber;
  final int totalStops;
  final String customerName;
  final String customerPhone;
  final String area;
  final String formattedAddress;
  final int mealsCount;
  final String deliveryTimeSlot;
  final DriverDeliveryStatus status;
  final double latitude;
  final double longitude;
  final String imageAsset;

  String get badgeText => '$sequenceNumber/$totalStops';

  bool get isDelivered => status == DriverDeliveryStatus.delivered;

  DriverMapStopEntity copyWith({
    String? id,
    String? boxCode,
    int? sequenceNumber,
    int? totalStops,
    String? customerName,
    String? customerPhone,
    String? area,
    String? formattedAddress,
    int? mealsCount,
    String? deliveryTimeSlot,
    DriverDeliveryStatus? status,
    double? latitude,
    double? longitude,
    String? imageAsset,
  }) {
    return DriverMapStopEntity(
      id: id ?? this.id,
      boxCode: boxCode ?? this.boxCode,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      totalStops: totalStops ?? this.totalStops,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      area: area ?? this.area,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      mealsCount: mealsCount ?? this.mealsCount,
      deliveryTimeSlot: deliveryTimeSlot ?? this.deliveryTimeSlot,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }
}
