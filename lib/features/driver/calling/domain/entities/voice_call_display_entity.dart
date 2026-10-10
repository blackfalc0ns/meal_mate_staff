class VoiceCallDisplayEntity {
  const VoiceCallDisplayEntity({
    required this.callId,
    this.tripStopId,
    this.driverName,
    this.driverImageUrl,
    this.driverRole,
    this.vehicleType,
    this.plateNumber,
    this.deliveryAddress,
    this.deliveryZone,
    this.orderCode,
    this.mealSummary,
    this.slotLabel,
    this.boxCount,
    this.stopStatus,
  });

  final String callId;
  final String? tripStopId;
  final String? driverName;
  final String? driverImageUrl;
  final String? driverRole;
  final String? vehicleType;
  final String? plateNumber;
  final String? deliveryAddress;
  final String? deliveryZone;
  final String? orderCode;
  final String? mealSummary;
  final String? slotLabel;
  final int? boxCount;
  final String? stopStatus;

  /// Resolves relative driverImageUrl against the provided baseUrl
  String? resolvedDriverImageUrl(String baseUrl) {
    if (driverImageUrl == null || driverImageUrl!.trim().isEmpty) return null;
    final url = driverImageUrl!.trim();
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final cleanBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final cleanPath = url.startsWith('/') ? url : '/$url';
    return '$cleanBase$cleanPath';
  }
}
