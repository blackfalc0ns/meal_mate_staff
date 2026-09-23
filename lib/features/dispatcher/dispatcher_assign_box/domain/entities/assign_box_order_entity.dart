import 'assign_box_candidate_driver_entity.dart';
import 'assign_box_priority.dart';
import 'assign_box_status.dart';

class AssignBoxOrderEntity {
  const AssignBoxOrderEntity({
    required this.boxId,
    required this.boxCode,
    String? zoneName,
    String? areaText,
    required this.deliveryTimeWindow,
    int? mealsCount,
    required this.mealsCountText,
    this.distanceKm,
    required this.distanceText,
    AssignBoxPriority? priority,
    required this.priorityText,
    AssignBoxStatus? status,
    required this.statusText,
    AssignBoxCandidateDriverEntity? recommendedDriver,
    List<AssignBoxCandidateDriverEntity>? candidates,
  })  : zoneName = zoneName ?? areaText ?? '',
        mealsCount = mealsCount ?? 0,
        priority = priority ?? AssignBoxPriority.unknown,
        status = status ?? AssignBoxStatus.unknown,
        _recommendedDriver = recommendedDriver,
        _candidates = candidates;

  final String boxId;
  final String boxCode;
  final String zoneName;
  final String deliveryTimeWindow;
  final int mealsCount;
  final String mealsCountText;
  final double? distanceKm;
  final String distanceText;
  final AssignBoxPriority priority;
  final String priorityText;
  final AssignBoxStatus status;
  final String statusText;
  final AssignBoxCandidateDriverEntity? _recommendedDriver;
  final List<AssignBoxCandidateDriverEntity>? _candidates;

  /// Compatibility getters for staged widget migration.
  String get areaText => zoneName;
  AssignBoxCandidateDriverEntity? get recommendedDriver => _recommendedDriver;
  List<AssignBoxCandidateDriverEntity> get candidates => _candidates ?? const [];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignBoxOrderEntity &&
          runtimeType == other.runtimeType &&
          boxId == other.boxId &&
          boxCode == other.boxCode &&
          zoneName == other.zoneName &&
          deliveryTimeWindow == other.deliveryTimeWindow &&
          mealsCount == other.mealsCount &&
          mealsCountText == other.mealsCountText &&
          distanceKm == other.distanceKm &&
          distanceText == other.distanceText &&
          priority == other.priority &&
          priorityText == other.priorityText &&
          status == other.status &&
          statusText == other.statusText;

  @override
  int get hashCode =>
      boxId.hashCode ^
      boxCode.hashCode ^
      zoneName.hashCode ^
      deliveryTimeWindow.hashCode ^
      mealsCount.hashCode ^
      mealsCountText.hashCode ^
      distanceKm.hashCode ^
      distanceText.hashCode ^
      priority.hashCode ^
      priorityText.hashCode ^
      status.hashCode ^
      statusText.hashCode;
}
