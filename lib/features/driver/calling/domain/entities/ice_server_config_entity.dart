class IceServerConfigEntity {
  const IceServerConfigEntity({
    required this.urls,
    this.username,
    this.credential,
  });

  final List<String> urls;
  final String? username;
  final String? credential;

  Map<String, dynamic> toMap() {
    return {
      'urls': urls,
      if (username != null && username!.isNotEmpty) 'username': username,
      if (credential != null && credential!.isNotEmpty) 'credential': credential,
    };
  }
}
