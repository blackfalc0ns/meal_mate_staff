import 'assign_box_candidate_driver_entity.dart';

class AssignBoxOrderEntity {
  const AssignBoxOrderEntity({
    required this.boxCode,
    required this.statusText,
    required this.areaText,
    required this.distanceText,
    required this.deliveryTimeWindow,
    required this.priorityText,
    required this.mealsCountText,
    required this.recommendedDriver,
    required this.candidates,
  });

  final String boxCode;
  final String statusText;
  final String areaText;
  final String distanceText;
  final String deliveryTimeWindow;
  final String priorityText;
  final String mealsCountText;
  final AssignBoxCandidateDriverEntity recommendedDriver;
  final List<AssignBoxCandidateDriverEntity> candidates;
}
