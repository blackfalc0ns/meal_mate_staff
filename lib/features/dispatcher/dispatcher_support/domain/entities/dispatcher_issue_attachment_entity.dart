class DispatcherIssueAttachmentEntity {
  const DispatcherIssueAttachmentEntity({
    required this.id,
    String? url,
    this.thumbnailUrl,
    this.uploadedAtUtc,
    this.orderNumber = 1,
    this.imageAsset = '',
  }) : url = url ?? imageAsset;

  final String id;
  final String url;
  final String? thumbnailUrl;
  final DateTime? uploadedAtUtc;
  final int orderNumber;
  final String imageAsset;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherIssueAttachmentEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
