class RegisterDocument {
  const RegisterDocument({
    required this.id,
    required this.imageAsset,
    this.isUploaded = false,
    this.storageKey,
    this.localFilePath,
    this.fileName,
    this.isUploading = false,
    this.errorMessage,
  });

  final String id;
  final String imageAsset;
  final bool isUploaded;
  final String? storageKey;
  final String? localFilePath;
  final String? fileName;
  final bool isUploading;
  final String? errorMessage;

  RegisterDocument copyWith({
    String? id,
    String? imageAsset,
    bool? isUploaded,
    String? storageKey,
    String? localFilePath,
    String? fileName,
    bool? isUploading,
    String? errorMessage,
  }) {
    return RegisterDocument(
      id: id ?? this.id,
      imageAsset: imageAsset ?? this.imageAsset,
      isUploaded: isUploaded ?? this.isUploaded,
      storageKey: storageKey ?? this.storageKey,
      localFilePath: localFilePath ?? this.localFilePath,
      fileName: fileName ?? this.fileName,
      isUploading: isUploading ?? this.isUploading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
