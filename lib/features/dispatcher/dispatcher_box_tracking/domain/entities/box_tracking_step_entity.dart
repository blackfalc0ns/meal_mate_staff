import 'box_tracking_step_icon_kind.dart';
import 'box_tracking_step_state.dart';

class BoxTrackingStepEntity {
  const BoxTrackingStepEntity({
    this.step = 0,
    required this.title,
    this.description,
    this.time,
    this.state = BoxTrackingStepState.pending,
    this.iconKind = BoxTrackingStepIconKind.unknown,
  });

  final int step;
  final String title;
  final String? description;
  final String? time;
  final BoxTrackingStepState state;
  final BoxTrackingStepIconKind iconKind;

  bool get isCompleted => state == BoxTrackingStepState.completed;
  bool get isActive => state == BoxTrackingStepState.active;
}
