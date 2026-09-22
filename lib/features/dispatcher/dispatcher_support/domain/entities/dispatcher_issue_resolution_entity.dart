class DispatcherIssueResolutionEntity {
  const DispatcherIssueResolutionEntity({
    required this.resolutionNotes,
    this.resolvedBy,
    this.resolvedAtUtc,
    this.resolvedAtText,
    this.resolvedAction,
    this.resolvedActionLabel,
  });

  final String resolutionNotes;
  final String? resolvedBy;
  final DateTime? resolvedAtUtc;
  final String? resolvedAtText;
  final String? resolvedAction;
  final String? resolvedActionLabel;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DispatcherIssueResolutionEntity &&
          runtimeType == other.runtimeType &&
          resolutionNotes == other.resolutionNotes &&
          resolvedBy == other.resolvedBy &&
          resolvedAtUtc == other.resolvedAtUtc &&
          resolvedAction == other.resolvedAction;

  @override
  int get hashCode => Object.hash(
        resolutionNotes,
        resolvedBy,
        resolvedAtUtc,
        resolvedAction,
      );
}
