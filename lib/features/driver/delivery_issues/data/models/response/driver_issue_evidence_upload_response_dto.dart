/// Issue evidence must use the storage key, never a read URL fallback.
class DriverIssueEvidenceUploadResponseDto {
  const DriverIssueEvidenceUploadResponseDto({this.storageKey});

  factory DriverIssueEvidenceUploadResponseDto.fromJson(
    Map<String, dynamic> json,
  ) {
    dynamic rawKey = json['storageKey'];
    if (rawKey == null && json['data'] is Map<String, dynamic>) {
      final dataMap = json['data'] as Map<String, dynamic>;
      rawKey = dataMap['storageKey'] ?? dataMap['key'] ?? dataMap['path'];
    } else if (rawKey == null && json['data'] is String) {
      rawKey = json['data'];
    }
    rawKey ??= json['key'] ?? json['path'];

    final keyStr = rawKey?.toString().trim();

    return DriverIssueEvidenceUploadResponseDto(
      storageKey: (keyStr != null && keyStr.isNotEmpty) ? keyStr : null,
    );
  }

  final String? storageKey;
}
