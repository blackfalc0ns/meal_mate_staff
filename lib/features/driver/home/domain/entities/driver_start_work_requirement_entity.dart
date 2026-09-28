enum DriverRequirementType { checklist, pickup, readiness }

class DriverStartWorkRequirementEntity {
  const DriverStartWorkRequirementEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    this.isCompleted = false,
  });

  final String id;
  final String title;
  final String subtitle;
  final DriverRequirementType type;
  final bool isCompleted;
}
