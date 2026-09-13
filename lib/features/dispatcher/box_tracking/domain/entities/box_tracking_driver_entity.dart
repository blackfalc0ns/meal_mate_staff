class BoxTrackingDriverEntity {
  const BoxTrackingDriverEntity({
    required this.id,
    required this.name,
    required this.phone,
    required this.isOnline,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String phone;
  final bool isOnline;
  final String? avatarUrl;
}
