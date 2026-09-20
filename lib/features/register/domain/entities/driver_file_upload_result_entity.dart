class DriverFileUploadResultEntity {
  const DriverFileUploadResultEntity({
    required this.storageKey,
    this.readUrl,
    this.fileName,
    this.contentType,
    this.sizeBytes,
  });

  final String storageKey;
  final String? readUrl;
  final String? fileName;
  final String? contentType;
  final int? sizeBytes;
}
