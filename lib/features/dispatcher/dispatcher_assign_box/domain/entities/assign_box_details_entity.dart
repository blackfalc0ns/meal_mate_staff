import 'assign_box_candidate_driver_entity.dart';
import 'assign_box_order_entity.dart';

class AssignBoxDetailsEntity {
  const AssignBoxDetailsEntity({
    required this.box,
    required this.bestSuggestion,
    required this.candidates,
  });

  final AssignBoxOrderEntity box;
  final AssignBoxCandidateDriverEntity? bestSuggestion;
  final List<AssignBoxCandidateDriverEntity> candidates;

  String? get defaultSelectedDriverId =>
      bestSuggestion?.driverId ??
      (candidates.isNotEmpty ? candidates.first.driverId : null);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignBoxDetailsEntity &&
          runtimeType == other.runtimeType &&
          box == other.box &&
          bestSuggestion == other.bestSuggestion &&
          candidates == other.candidates;

  @override
  int get hashCode =>
      box.hashCode ^ bestSuggestion.hashCode ^ candidates.hashCode;
}
