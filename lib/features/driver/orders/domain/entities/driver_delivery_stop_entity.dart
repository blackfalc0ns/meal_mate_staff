import 'driver_delivery_status.dart';

class DriverDeliveryStopEntity {
  const DriverDeliveryStopEntity({
    required this.tripStopId,
    required this.boxId,
    required this.boxCode,
    required this.sequenceNumber,
    required this.customerName,
    required this.deliveryZone,
    required this.formattedAddress,
    this.latitude,
    this.longitude,
    required this.mealsCount,
    required this.mealsSummary,
    required this.deliveryTimeSlot,
    required this.status,
    required this.statusText,
    this.deliveredAtUtc,
    this.failureReasonCategory,
    this.failureReasonText,
    required this.isCurrentStop,
    required this.canCompleteDelivery,
    required this.canNavigate,
    required this.canCallCustomer,
    this.maskedPhoneNumber,
  });

  final String tripStopId;
  final String boxId;
  final String boxCode;
  final int sequenceNumber;
  final String customerName;
  final String deliveryZone;
  final String formattedAddress;
  final double? latitude;
  final double? longitude;
  final int mealsCount;
  final String mealsSummary;
  final String deliveryTimeSlot;
  final DriverDeliveryStatus status;
  final String statusText;
  final DateTime? deliveredAtUtc;
  final String? failureReasonCategory;
  final String? failureReasonText;
  final bool isCurrentStop;
  final bool canCompleteDelivery;
  final bool canNavigate;
  final bool canCallCustomer;
  final String? maskedPhoneNumber;

  bool get hasCoordinates => latitude != null && longitude != null;
  bool get isProblem => status.isProblem;
  bool get isCompleted => status.isCompleted;
  bool get canShowPrimaryActions =>
      isCurrentStop &&
      (status == DriverDeliveryStatus.inProgress ||
          status == DriverDeliveryStatus.arrivedAtCustomer);

  DriverDeliveryStopEntity copyWith({
    String? tripStopId,
    String? boxId,
    String? boxCode,
    int? sequenceNumber,
    String? customerName,
    String? deliveryZone,
    String? formattedAddress,
    double? latitude,
    double? longitude,
    int? mealsCount,
    String? mealsSummary,
    String? deliveryTimeSlot,
    DriverDeliveryStatus? status,
    String? statusText,
    DateTime? deliveredAtUtc,
    String? failureReasonCategory,
    String? failureReasonText,
    bool? isCurrentStop,
    bool? canCompleteDelivery,
    bool? canNavigate,
    bool? canCallCustomer,
    String? maskedPhoneNumber,
  }) {
    return DriverDeliveryStopEntity(
      tripStopId: tripStopId ?? this.tripStopId,
      boxId: boxId ?? this.boxId,
      boxCode: boxCode ?? this.boxCode,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      customerName: customerName ?? this.customerName,
      deliveryZone: deliveryZone ?? this.deliveryZone,
      formattedAddress: formattedAddress ?? this.formattedAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mealsCount: mealsCount ?? this.mealsCount,
      mealsSummary: mealsSummary ?? this.mealsSummary,
      deliveryTimeSlot: deliveryTimeSlot ?? this.deliveryTimeSlot,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      deliveredAtUtc: deliveredAtUtc ?? this.deliveredAtUtc,
      failureReasonCategory:
          failureReasonCategory ?? this.failureReasonCategory,
      failureReasonText: failureReasonText ?? this.failureReasonText,
      isCurrentStop: isCurrentStop ?? this.isCurrentStop,
      canCompleteDelivery: canCompleteDelivery ?? this.canCompleteDelivery,
      canNavigate: canNavigate ?? this.canNavigate,
      canCallCustomer: canCallCustomer ?? this.canCallCustomer,
      maskedPhoneNumber: maskedPhoneNumber ?? this.maskedPhoneNumber,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverDeliveryStopEntity &&
          runtimeType == other.runtimeType &&
          tripStopId == other.tripStopId &&
          boxId == other.boxId &&
          boxCode == other.boxCode &&
          sequenceNumber == other.sequenceNumber &&
          customerName == other.customerName &&
          deliveryZone == other.deliveryZone &&
          formattedAddress == other.formattedAddress &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          mealsCount == other.mealsCount &&
          mealsSummary == other.mealsSummary &&
          deliveryTimeSlot == other.deliveryTimeSlot &&
          status == other.status &&
          statusText == other.statusText &&
          deliveredAtUtc == other.deliveredAtUtc &&
          failureReasonCategory == other.failureReasonCategory &&
          failureReasonText == other.failureReasonText &&
          isCurrentStop == other.isCurrentStop &&
          canCompleteDelivery == other.canCompleteDelivery &&
          canNavigate == other.canNavigate &&
          canCallCustomer == other.canCallCustomer &&
          maskedPhoneNumber == other.maskedPhoneNumber;

  @override
  int get hashCode => Object.hashAll([
    tripStopId,
    boxId,
    boxCode,
    sequenceNumber,
    customerName,
    deliveryZone,
    formattedAddress,
    latitude,
    longitude,
    mealsCount,
    mealsSummary,
    deliveryTimeSlot,
    status,
    statusText,
    deliveredAtUtc,
    failureReasonCategory,
    failureReasonText,
    isCurrentStop,
    canCompleteDelivery,
    canNavigate,
    canCallCustomer,
    maskedPhoneNumber,
  ]);
}
