class ReassignDriverCandidateEntity {
  const ReassignDriverCandidateEntity({
    required this.id,
    required this.name,
    required this.code,
    this.isAvailable = true,
    required this.rating,
    required this.ordersCount,
    required this.distanceKm,
    this.avatarAsset,
  });

  final String id;
  final String name;
  final String code;
  final bool isAvailable;
  final double rating;
  final int ordersCount;
  final double distanceKm;
  final String? avatarAsset;
}
