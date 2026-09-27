class ConfirmDriverPickupRequestEntity {
  const ConfirmDriverPickupRequestEntity({
    required this.validationToken,
    required this.conditionPhotoStorageKey,
    required this.latitude,
    required this.longitude,
  });

  final String validationToken;
  final String conditionPhotoStorageKey;
  final double latitude;
  final double longitude;
}
