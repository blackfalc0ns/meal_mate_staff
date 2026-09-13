class BoxTrackingStepEntity {
  const BoxTrackingStepEntity({
    required this.title,
    this.time,
    this.isCompleted = false,
    this.isActive = false,
  });

  final String title;
  final String? time;
  final bool isCompleted;
  final bool isActive;
}
