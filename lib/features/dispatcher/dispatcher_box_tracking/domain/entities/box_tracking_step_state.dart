enum BoxTrackingStepState { completed, active, pending, unknown }

extension BoxTrackingStepStateX on BoxTrackingStepState {
  static BoxTrackingStepState fromApi(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'completed' => BoxTrackingStepState.completed,
      'active' => BoxTrackingStepState.active,
      'pending' => BoxTrackingStepState.pending,
      _ => BoxTrackingStepState.pending,
    };
  }
}
