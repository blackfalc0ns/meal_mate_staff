class DriverPodiumEntryEntity {
  const DriverPodiumEntryEntity({
    required this.rank,
    required this.name,
    required this.rating,
    this.driverId,
    this.driverCode,
    this.avatarUrl,
  });

  final int rank;
  final String name;
  final double rating;
  final String? driverId;
  final String? driverCode;
  final String? avatarUrl;
}
