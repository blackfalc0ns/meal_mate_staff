import 'assign_box_driver_status_type.dart';

class AssignBoxCandidateDriverEntity {
  const AssignBoxCandidateDriverEntity({
    required this.id,
    required this.name,
    required this.statusText,
    required this.statusType,
    required this.tagText,
    required this.distanceText,
    this.badgeNumber,
    this.currentLoadText,
    this.expectedCompletionText,
    this.isRecommended = false,
  });

  final String id;
  final String name;
  final String? badgeNumber;
  final String statusText;
  final AssignBoxDriverStatusType statusType;
  final String tagText;
  final String distanceText;
  final String? currentLoadText;
  final String? expectedCompletionText;
  final bool isRecommended;
}
