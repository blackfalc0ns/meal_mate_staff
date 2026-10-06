import 'package:meal_mate_delivery/core/constants/assets.dart';
import '../../../orders/domain/entities/driver_delivery_status.dart';

class DriverMapStopEntity {
  const DriverMapStopEntity({
    required this.id,
    required this.boxCode,
    this.sequenceNumber = 1,
    this.totalStops = 1,
    this.sequenceBadge,
    required this.customerName,
    this.customerPhone = '',
    required this.area,
    required this.formattedAddress,
    required this.mealsCount,
    this.mealsSummary,
    required this.deliveryTimeSlot,
    required this.status,
    this.statusText,
    this.statusColor,
    this.isCurrent = false,
    this.latitude,
    this.longitude,
    this.imageAsset = AppAssets.driverKpiBox,
  });

  final String id;
  final String boxCode;
  final int sequenceNumber;
  final int totalStops;
  final String? sequenceBadge;
  final String customerName;
  final String customerPhone;
  final String area;
  final String formattedAddress;
  final int mealsCount;
  final String? mealsSummary;
  final String deliveryTimeSlot;
  final DriverDeliveryStatus status;
  final String? statusText;
  final String? statusColor;
  final bool isCurrent;
  final double? latitude;
  final double? longitude;
  final String imageAsset;

  String get addressShort => area;

  String get badgeText => sequenceBadge ?? '$sequenceNumber/$totalStops';

  bool get isDelivered => status == DriverDeliveryStatus.delivered;

  DriverMapStopEntity copyWith({
    String? id,
    String? boxCode,
    int? sequenceNumber,
    int? totalStops,
    String? sequenceBadge,
    String? customerName,
    String? customerPhone,
    String? area,
    String? addressShort,
    String? formattedAddress,
    int? mealsCount,
    String? mealsSummary,
    String? deliveryTimeSlot,
    DriverDeliveryStatus? status,
    String? statusText,
    String? statusColor,
    bool? isCurrent,
    double? latitude,
    double? longitude,
    String? imageAsset,
  }) {
    return DriverMapStopEntity(
      id: id ?? this.id,
      boxCode: boxCode ?? this.boxCode,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      totalStops: totalStops ?? this.totalStops,
      sequenceBadge: sequenceBadge ?? this.sequenceBadge,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      area: addressShort ?? area ?? this.area,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      mealsCount: mealsCount ?? this.mealsCount,
      mealsSummary: mealsSummary ?? this.mealsSummary,
      deliveryTimeSlot: deliveryTimeSlot ?? this.deliveryTimeSlot,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      statusColor: statusColor ?? this.statusColor,
      isCurrent: isCurrent ?? this.isCurrent,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageAsset: imageAsset ?? this.imageAsset,
    );
  }
}
