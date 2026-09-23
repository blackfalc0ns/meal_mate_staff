import 'assign_box_driver_status_type.dart';

class AssignBoxCandidateDriverEntity {
  const AssignBoxCandidateDriverEntity({
    required this.driverId,
    required this.fullName,
    this.avatarUrl,
    this.plateNumber,
    this.phone,
    this.distanceKm,
    required this.distanceText,
    required this.activeOrdersCount,
    required this.currentLoadBoxes,
    required this.currentLoadLabel,
    this.rating,
    required this.status,
    required this.driverStatusText,
    required this.statusTag,
    required this.estimatedFinishTimeText,
    required this.rank,
    this.isRecommended = false,
    this.recommendationReason,
  });

  final String driverId;
  final String fullName;
  final String? avatarUrl;
  final String? plateNumber;
  final String? phone;
  final double? distanceKm;
  final String distanceText;
  final int activeOrdersCount;
  final int currentLoadBoxes;
  final String currentLoadLabel;
  final double? rating;
  final AssignBoxDriverStatusType status;
  final String driverStatusText;
  final String statusTag;
  final String estimatedFinishTimeText;
  final int rank;
  final bool isRecommended;
  final String? recommendationReason;

  // Compatibility getters for staged widget migration
  String get id => driverId;
  String get name => fullName;
  String get statusText => driverStatusText;
  AssignBoxDriverStatusType get statusType => status;
  String get tagText => statusTag;
  String? get badgeNumber => plateNumber;
  String get currentLoadText => currentLoadLabel;
  String get expectedCompletionText => estimatedFinishTimeText;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignBoxCandidateDriverEntity &&
          runtimeType == other.runtimeType &&
          driverId == other.driverId &&
          fullName == other.fullName &&
          avatarUrl == other.avatarUrl &&
          plateNumber == other.plateNumber &&
          phone == other.phone &&
          distanceKm == other.distanceKm &&
          distanceText == other.distanceText &&
          activeOrdersCount == other.activeOrdersCount &&
          currentLoadBoxes == other.currentLoadBoxes &&
          currentLoadLabel == other.currentLoadLabel &&
          rating == other.rating &&
          status == other.status &&
          driverStatusText == other.driverStatusText &&
          statusTag == other.statusTag &&
          estimatedFinishTimeText == other.estimatedFinishTimeText &&
          rank == other.rank &&
          isRecommended == other.isRecommended &&
          recommendationReason == other.recommendationReason;

  @override
  int get hashCode =>
      driverId.hashCode ^
      fullName.hashCode ^
      avatarUrl.hashCode ^
      plateNumber.hashCode ^
      phone.hashCode ^
      distanceKm.hashCode ^
      distanceText.hashCode ^
      activeOrdersCount.hashCode ^
      currentLoadBoxes.hashCode ^
      currentLoadLabel.hashCode ^
      rating.hashCode ^
      status.hashCode ^
      driverStatusText.hashCode ^
      statusTag.hashCode ^
      estimatedFinishTimeText.hashCode ^
      rank.hashCode ^
      isRecommended.hashCode ^
      recommendationReason.hashCode;
}
