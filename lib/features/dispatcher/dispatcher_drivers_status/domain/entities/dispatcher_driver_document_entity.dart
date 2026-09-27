enum DispatcherDriverDocumentType {
  drivingLicense,
  vehicleRegistration,
  insurance,
}

class DispatcherDriverDocumentEntity {
  const DispatcherDriverDocumentEntity({
    required this.type,
    required this.isValid,
    this.validUntil,
  });

  final DispatcherDriverDocumentType type;
  final bool isValid;
  final String? validUntil;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriverDocumentEntity &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          isValid == other.isValid &&
          validUntil == other.validUntil;

  @override
  int get hashCode => Object.hash(type, isValid, validUntil);
}
