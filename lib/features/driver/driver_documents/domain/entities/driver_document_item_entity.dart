enum DriverDocumentItemStatus {
  approved,
  expiringSoon,
  underReview,
  expired;

  bool get isApproved => this == DriverDocumentItemStatus.approved;
  bool get isExpiringSoon => this == DriverDocumentItemStatus.expiringSoon;
  bool get isUnderReview => this == DriverDocumentItemStatus.underReview;
  bool get isExpired => this == DriverDocumentItemStatus.expired;
}

class DriverDocumentItemEntity {
  const DriverDocumentItemEntity({
    required this.id,
    required this.documentType,
    required this.imageAsset,
    required this.status,
    this.expiryDate,
    this.uploadedAt,
  });

  final String id;
  final String documentType;
  final String imageAsset;
  final DriverDocumentItemStatus status;
  final String? expiryDate;
  final DateTime? uploadedAt;

  DriverDocumentItemEntity copyWith({
    String? id,
    String? documentType,
    String? imageAsset,
    DriverDocumentItemStatus? status,
    String? expiryDate,
    DateTime? uploadedAt,
  }) {
    return DriverDocumentItemEntity(
      id: id ?? this.id,
      documentType: documentType ?? this.documentType,
      imageAsset: imageAsset ?? this.imageAsset,
      status: status ?? this.status,
      expiryDate: expiryDate ?? this.expiryDate,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DriverDocumentItemEntity &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          documentType == other.documentType &&
          imageAsset == other.imageAsset &&
          status == other.status &&
          expiryDate == other.expiryDate &&
          uploadedAt == other.uploadedAt;

  @override
  int get hashCode => Object.hash(
        id,
        documentType,
        imageAsset,
        status,
        expiryDate,
        uploadedAt,
      );
}
