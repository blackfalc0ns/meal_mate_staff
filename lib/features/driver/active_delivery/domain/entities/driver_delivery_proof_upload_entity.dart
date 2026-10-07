class DriverDeliveryProofUploadEntity {
  const DriverDeliveryProofUploadEntity({
    required this.storageKey,
    this.uploadedAtUtc,
  });

  final String storageKey;
  final DateTime? uploadedAtUtc;
}
