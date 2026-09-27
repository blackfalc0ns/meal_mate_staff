class DriverBarcodeValidationEntity {
  const DriverBarcodeValidationEntity({
    required this.boxId,
    required this.boxCode,
    required this.customerName,
    required this.deliveryZone,
    required this.mealsCount,
    required this.deliveryTimeSlot,
    required this.validationToken,
    this.expiresAtUtc,
    required this.status,
    required this.statusText,
    required this.nextAction,
    this.message,
  });

  final String boxId;
  final String boxCode;
  final String customerName;
  final String deliveryZone;
  final int mealsCount;
  final String deliveryTimeSlot;
  final String validationToken;
  final DateTime? expiresAtUtc;
  final String status;
  final String statusText;
  final String nextAction;
  final String? message;
}
