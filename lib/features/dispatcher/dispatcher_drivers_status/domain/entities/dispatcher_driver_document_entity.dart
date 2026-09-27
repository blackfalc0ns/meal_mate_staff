enum DispatcherDriverDocumentType {
  drivingLicense,
  vehicleRegistration,
  insurance,
}

enum DispatcherDriverDocumentStatus {
  valid,
  expiringSoon,
  expired,
  missing,
  unknown;

  static DispatcherDriverDocumentStatus fromApi(String? value) {
    if (value == null || value.trim().isEmpty) {
      return DispatcherDriverDocumentStatus.missing;
    }
    switch (value.trim().toLowerCase()) {
      case 'valid':
        return DispatcherDriverDocumentStatus.valid;
      case 'expiringsoon':
      case 'expiring_soon':
      case 'expiring-soon':
        return DispatcherDriverDocumentStatus.expiringSoon;
      case 'expired':
        return DispatcherDriverDocumentStatus.expired;
      case 'missing':
        return DispatcherDriverDocumentStatus.missing;
      default:
        return DispatcherDriverDocumentStatus.unknown;
    }
  }
}

class DispatcherDriverDocumentEntity {
  const DispatcherDriverDocumentEntity({
    this.type = DispatcherDriverDocumentType.drivingLicense,
    this.isValid = true,
    this.validUntil,
    this.documentType,
    this.documentName,
    this.status = DispatcherDriverDocumentStatus.unknown,
    this.documentUrl,
  });

  final DispatcherDriverDocumentType type;
  final bool isValid;
  final String? validUntil;
  final String? documentType;
  final String? documentName;
  final DispatcherDriverDocumentStatus status;
  final String? documentUrl;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherDriverDocumentEntity &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          isValid == other.isValid &&
          validUntil == other.validUntil &&
          documentType == other.documentType &&
          documentName == other.documentName &&
          status == other.status &&
          documentUrl == other.documentUrl;

  @override
  int get hashCode => Object.hash(
    type,
    isValid,
    validUntil,
    documentType,
    documentName,
    status,
    documentUrl,
  );
}
