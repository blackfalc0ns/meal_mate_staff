class RegisterDocument {
  const RegisterDocument({
    required this.id,
    required this.imageAsset,
    this.isUploaded = false,
  });

  final String id;
  final String imageAsset;
  final bool isUploaded;
}
