class ReportBoxIssueResultEntity {
  const ReportBoxIssueResultEntity({
    required this.issueId,
    required this.boxId,
    required this.reportedAtUtc,
    required this.message,
  });

  final String issueId;
  final String boxId;
  final DateTime? reportedAtUtc;
  final String message;
}
