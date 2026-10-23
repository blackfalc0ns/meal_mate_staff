enum IssuePhotoStatus {
  uploading,
  success,
  failed,
}

class IssuePhotoItem {
  const IssuePhotoItem({
    required this.id,
    required this.localPath,
    this.storageKey,
    this.status = IssuePhotoStatus.uploading,
    this.errorMessage,
  });

  final String id;
  final String localPath;
  final String? storageKey;
  final IssuePhotoStatus status;
  final String? errorMessage;

  bool get isUploading => status == IssuePhotoStatus.uploading;
  bool get isSuccess =>
      status == IssuePhotoStatus.success &&
      storageKey != null &&
      storageKey!.trim().isNotEmpty;
  bool get isFailed => status == IssuePhotoStatus.failed;

  IssuePhotoItem copyWith({
    String? id,
    String? localPath,
    String? storageKey,
    IssuePhotoStatus? status,
    String? errorMessage,
    bool clearStorageKey = false,
    bool clearErrorMessage = false,
  }) {
    return IssuePhotoItem(
      id: id ?? this.id,
      localPath: localPath ?? this.localPath,
      storageKey: clearStorageKey ? null : (storageKey ?? this.storageKey),
      status: status ?? this.status,
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
