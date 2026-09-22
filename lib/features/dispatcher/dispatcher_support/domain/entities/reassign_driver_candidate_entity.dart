class ReassignDriverCandidateEntity {
  const ReassignDriverCandidateEntity({
    required this.id,
    required this.name,
    required this.code,
    this.avatarUrl,
    this.avatarAsset,
    this.isAvailable = true,
    this.status = 'AVAILABLE',
    this.statusText = '',
    this.statusColorHex = '#10B981',
    required this.rating,
    this.activeOrdersCount = 0,
    int? ordersCount,
    this.area = '',
    this.isSameArea = false,
    required this.distanceKm,
    this.distanceText = '',
    this.estimatedArrivalMinutes = 0,
    this.estimatedArrivalText = '',
    this.vehicleInfo = '',
    this.lastLocationUpdateUtc,
    this.lastLocationUpdateText = '',
    this.recommendationRank = 1,
  }) : ordersCount = ordersCount ?? activeOrdersCount;

  final String id;
  final String name;
  final String code;
  final String? avatarUrl;
  final String? avatarAsset;
  final bool isAvailable;
  final String status;
  final String statusText;
  final String statusColorHex;
  final double rating;
  final int activeOrdersCount;
  final int ordersCount;
  final String area;
  final bool isSameArea;
  final double distanceKm;
  final String distanceText;
  final int estimatedArrivalMinutes;
  final String estimatedArrivalText;
  final String vehicleInfo;
  final DateTime? lastLocationUpdateUtc;
  final String lastLocationUpdateText;
  final int recommendationRank;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReassignDriverCandidateEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
