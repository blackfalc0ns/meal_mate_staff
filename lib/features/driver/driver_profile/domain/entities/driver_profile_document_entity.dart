class DriverProfileDocumentEntity {
  const DriverProfileDocumentEntity({
    required this.documentId,
    required this.documentType,
    required this.documentTitle,
    required this.status,
    required this.statusText,
    this.expiryDate,
    this.daysUntilExpiry,
    this.uploadedAtUtc,
  });

  final String documentId;
  final String documentType;
  final String documentTitle;
  final String status;
  final String statusText;
  final String? expiryDate;
  final int? daysUntilExpiry;
  final DateTime? uploadedAtUtc;

  DriverProfileDocumentEntity copyWith({
    String? documentId,
    String? documentType,
    String? documentTitle,
    String? status,
    String? statusText,
    String? expiryDate,
    int? daysUntilExpiry,
    DateTime? uploadedAtUtc,
  }) {
    return DriverProfileDocumentEntity(
      documentId: documentId ?? this.documentId,
      documentType: documentType ?? this.documentType,
      documentTitle: documentTitle ?? this.documentTitle,
      status: status ?? this.status,
      statusText: statusText ?? this.statusText,
      expiryDate: expiryDate ?? this.expiryDate,
      daysUntilExpiry: daysUntilExpiry ?? this.daysUntilExpiry,
      uploadedAtUtc: uploadedAtUtc ?? this.uploadedAtUtc,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverProfileDocumentEntity &&
          runtimeType == other.runtimeType &&
          documentId == other.documentId &&
          documentType == other.documentType &&
          documentTitle == other.documentTitle &&
          status == other.status &&
          statusText == other.statusText &&
          expiryDate == other.expiryDate &&
          daysUntilExpiry == other.daysUntilExpiry &&
          uploadedAtUtc == other.uploadedAtUtc;

  @override
  int get hashCode => Object.hash(
        documentId,
        documentType,
        documentTitle,
        status,
        statusText,
        expiryDate,
        daysUntilExpiry,
        uploadedAtUtc,
      );
}
