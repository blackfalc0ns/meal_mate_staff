class DriverDeliverRequestEntity {
  const DriverDeliverRequestEntity({
    required this.proofPhotoStorageKey,
    this.latitude,
    this.longitude,
    this.deliveryOtp,
  });

  final String proofPhotoStorageKey;
  final double? latitude;
  final double? longitude;
  final String? deliveryOtp;
}
