import 'box_issue_type.dart';

class ReportBoxIssueRequestEntity {
  const ReportBoxIssueRequestEntity({
    required this.issueType,
    required this.description,
    this.severity = 'Medium',
  });

  final BoxIssueType issueType;
  final String description;
  final String severity;
}
