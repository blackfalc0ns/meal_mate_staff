class DriverBarcodeValidationResponseDto {
  const DriverBarcodeValidationResponseDto({
    this.boxId,
    this.boxCode,
    this.customerName,
    this.deliveryZone,
    this.mealsCount,
    this.deliveryTimeSlot,
    this.validationToken,
    this.expiresAtUtc,
    this.status,
    this.statusText,
    this.nextAction,
    this.message,
    this.isValid,
  });

  factory DriverBarcodeValidationResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    final box = json['box'] as Map<String, dynamic>?;

    return DriverBarcodeValidationResponseDto(
      boxId: (box?['boxId'] ?? json['boxId']) as String?,
      boxCode: (box?['boxCode'] ?? json['boxCode']) as String?,
      customerName: (box?['customerName'] ?? json['customerName']) as String?,
      deliveryZone: (box?['deliveryZone'] ?? json['deliveryZone']) as String?,
      mealsCount:
          ((box?['mealsCount'] ?? json['mealsCount']) as num?)?.toInt(),
      deliveryTimeSlot:
          (box?['deliveryTimeSlot'] ?? json['deliveryTimeSlot']) as String?,
      validationToken: json['validationToken'] as String?,
      expiresAtUtc: json['expiresAtUtc'] as String?,
      status: (json['scanStatus'] ?? json['status']) as String?,
      statusText:
          (json['statusText'] ?? json['scanStatus'] ?? json['status'])
              as String?,
      nextAction: json['nextAction'] as String?,
      message: json['message'] as String?,
      isValid: json['isValid'] as bool?,
    );
  }

  final String? boxId;
  final String? boxCode;
  final String? customerName;
  final String? deliveryZone;
  final int? mealsCount;
  final String? deliveryTimeSlot;
  final String? validationToken;
  final String? expiresAtUtc;
  final String? status;
  final String? statusText;
  final String? nextAction;
  final String? message;
  final bool? isValid;
}
