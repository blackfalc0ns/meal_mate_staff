class DriverConditionPhotoUploadEntity {
  const DriverConditionPhotoUploadEntity({
    required this.boxId,
    required this.conditionPhotoStorageKey,
    this.uploadedAtUtc,
    required this.status,
    required this.statusText,
    required this.nextAction,
    this.message,
  });

  final String boxId;
  final String conditionPhotoStorageKey;
  final DateTime? uploadedAtUtc;
  final String status;
  final String statusText;
  final String nextAction;
  final String? message;
}
