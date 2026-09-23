class BoxTrackingDriverEntity {
  const BoxTrackingDriverEntity({
    required this.driverId,
    required this.driverCode,
    required this.fullName,
    required this.phoneNumber,
    this.avatarUrl,
  });

  final String driverId;
  final String driverCode;
  final String fullName;
  final String phoneNumber;
  final String? avatarUrl;

  // Compatibility getters for legacy references
  String get id => driverId;
  String get name => fullName;
  String get phone => phoneNumber;
}
