import 'driver_box_delivery_status.dart';

class DriverAssignedBoxEntity {
  const DriverAssignedBoxEntity({
    required this.boxId,
    required this.boxCode,
    required this.customerName,
    required this.deliveryZone,
    required this.mealsCount,
    required this.mealsSummary,
    required this.deliveryTimeSlot,
    this.status = DriverBoxDeliveryStatus.pendingScan,
    this.statusText = '',
    this.isPickedUp = false,
    this.scannedAtUtc,
    this.conditionPhotoStorageKey,
    // Optional legacy compatibility parameters
    String? orderCode,
    int? mealCount,
    String? area,
    bool? isLoaded,
  });

  final String boxId;
  final String boxCode;
  final String customerName;
  final String deliveryZone;
  final int mealsCount;
  final String mealsSummary;
  final String deliveryTimeSlot;
  final DriverBoxDeliveryStatus status;
  final String statusText;
  final bool isPickedUp;
  final DateTime? scannedAtUtc;
  final String? conditionPhotoStorageKey;

  // Presentation compatibility aliases
  String get orderCode => boxCode;
  int get mealCount => mealsCount;
  String get area => deliveryZone;
  bool get isLoaded => isPickedUp;

  DriverAssignedBoxEntity copyWith({
    String? boxId,
    String? boxCode,
    String? customerName,
    String? deliveryZone,
    int? mealsCount,
    String? mealsSummary,
    String? deliveryTimeSlot,
    DriverBoxDeliveryStatus? status,
    String? statusText,
    bool? isPickedUp,
    DateTime? scannedAtUtc,
    String? conditionPhotoStorageKey,
  }) {
    return DriverAssignedBoxEntity(
      boxId: boxId ?? this.boxId,
      boxCode: boxCode ?? this.boxCode,
      customerName: customerName ?? this.customerName,
      deliveryZone: deliveryZone ?? this.deliveryZone,
      mealsCount: mealsCount ?? this.mealsCount,
      mealsSummary: mealsSummary ?? this.mealsSummary,
      deliveryTimeSlot: deliveryTimeSlot ?? this.deliveryTimeSlot,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      isPickedUp: isPickedUp ?? this.isPickedUp,
      scannedAtUtc: scannedAtUtc ?? this.scannedAtUtc,
      conditionPhotoStorageKey:
          conditionPhotoStorageKey ?? this.conditionPhotoStorageKey,
    );
  }
}
