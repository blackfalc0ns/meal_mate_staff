import 'dispatcher_issue_driver_entity.dart';
import 'dispatcher_support_response_entity.dart';
import 'reassign_driver_candidate_entity.dart';

class ReassignDriverIssueSummaryEntity {
  const ReassignDriverIssueSummaryEntity({
    required this.issueId,
    required this.title,
    this.category = '',
    this.categoryLabel = '',
    this.categoryColorHex = '#EF4444',
    this.reportedTimeText = '',
    this.minutesAgo = 0,
    this.priority = '',
    this.priorityText = '',
    this.priorityColorHex = '#EF4444',
    this.taskNumber = '',
    this.area = '',
    this.affectedBoxesCount = 0,
    this.affectedBoxesText = '',
    this.description = '',
  });

  final String issueId;
  final String title;
  final String category;
  final String categoryLabel;
  final String categoryColorHex;
  final String reportedTimeText;
  final int minutesAgo;
  final String priority;
  final String priorityText;
  final String priorityColorHex;
  final String taskNumber;
  final String area;
  final int affectedBoxesCount;
  final String affectedBoxesText;
  final String description;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReassignDriverIssueSummaryEntity &&
          runtimeType == other.runtimeType &&
          issueId == other.issueId;

  @override
  int get hashCode => issueId.hashCode;
}

class ReassignDriverCandidatesEntity {
  const ReassignDriverCandidatesEntity({
    required this.summary,
    this.currentDriver,
    this.candidates = const [],
    this.pagination = const DispatcherSupportPaginationEntity(),
  });

  final ReassignDriverIssueSummaryEntity summary;
  final DispatcherIssueDriverEntity? currentDriver;
  final List<ReassignDriverCandidateEntity> candidates;
  final DispatcherSupportPaginationEntity pagination;

  ReassignDriverCandidatesEntity copyWithAppendedCandidates({
    required List<ReassignDriverCandidateEntity> newCandidates,
    required DispatcherSupportPaginationEntity newPagination,
  }) {
    final existingIds = candidates.map((c) => c.id).toSet();
    final deDuped = newCandidates.where((c) => !existingIds.contains(c.id)).toList();
    return ReassignDriverCandidatesEntity(
      summary: summary,
      currentDriver: currentDriver,
      candidates: [...candidates, ...deDuped],
      pagination: newPagination,
    );
  }

  ReassignDriverCandidatesEntity copyWith({
    ReassignDriverIssueSummaryEntity? summary,
    DispatcherIssueDriverEntity? currentDriver,
    List<ReassignDriverCandidateEntity>? candidates,
    DispatcherSupportPaginationEntity? pagination,
  }) {
    return ReassignDriverCandidatesEntity(
      summary: summary ?? this.summary,
      currentDriver: currentDriver ?? this.currentDriver,
      candidates: candidates ?? this.candidates,
      pagination: pagination ?? this.pagination,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReassignDriverCandidatesEntity &&
          runtimeType == other.runtimeType &&
          summary == other.summary &&
          currentDriver == other.currentDriver &&
          pagination == other.pagination;

  @override
  int get hashCode => Object.hash(summary, currentDriver, pagination);
}
