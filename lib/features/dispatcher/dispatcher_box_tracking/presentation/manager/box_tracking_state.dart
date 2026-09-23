import '../../../../../core/network/failures.dart';
import '../../domain/entities/box_issue_type.dart';
import '../../domain/entities/box_tracking_entity.dart';

class BoxTrackingState {
  const BoxTrackingState({
    required this.boxId,
    this.tracking,
    this.isInitialLoading = false,
    this.isRefreshing = false,
    this.initialFailure,
    this.nonFatalFailure,
    this.selectedIssueType = BoxIssueType.other,
    this.issueDescription = '',
    this.isSubmittingIssue = false,
    this.reportFailure,
    this.reportSuccessMessage,
    this.noticeId = 0,
    this.reportNoticeId = 0,
  });

  final String boxId;
  final BoxTrackingEntity? tracking;
  final bool isInitialLoading;
  final bool isRefreshing;
  final Failure? initialFailure;
  final Failure? nonFatalFailure;
  final BoxIssueType selectedIssueType;
  final String issueDescription;
  final bool isSubmittingIssue;
  final Failure? reportFailure;
  final String? reportSuccessMessage;
  final int noticeId;
  final int reportNoticeId;

  BoxTrackingState copyWith({
    String? boxId,
    BoxTrackingEntity? tracking,
    bool? isInitialLoading,
    bool? isRefreshing,
    Failure? initialFailure,
    bool clearInitialFailure = false,
    Failure? nonFatalFailure,
    bool clearNonFatalFailure = false,
    BoxIssueType? selectedIssueType,
    String? issueDescription,
    bool? isSubmittingIssue,
    Failure? reportFailure,
    bool clearReportFailure = false,
    String? reportSuccessMessage,
    bool clearReportSuccess = false,
    int? noticeId,
    int? reportNoticeId,
  }) {
    return BoxTrackingState(
      boxId: boxId ?? this.boxId,
      tracking: tracking ?? this.tracking,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      initialFailure: clearInitialFailure
          ? null
          : (initialFailure ?? this.initialFailure),
      nonFatalFailure: clearNonFatalFailure
          ? null
          : (nonFatalFailure ?? this.nonFatalFailure),
      selectedIssueType: selectedIssueType ?? this.selectedIssueType,
      issueDescription: issueDescription ?? this.issueDescription,
      isSubmittingIssue: isSubmittingIssue ?? this.isSubmittingIssue,
      reportFailure: clearReportFailure
          ? null
          : (reportFailure ?? this.reportFailure),
      reportSuccessMessage: clearReportSuccess
          ? null
          : (reportSuccessMessage ?? this.reportSuccessMessage),
      noticeId: noticeId ?? this.noticeId,
      reportNoticeId: reportNoticeId ?? this.reportNoticeId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoxTrackingState &&
          runtimeType == other.runtimeType &&
          boxId == other.boxId &&
          tracking == other.tracking &&
          isInitialLoading == other.isInitialLoading &&
          isRefreshing == other.isRefreshing &&
          initialFailure == other.initialFailure &&
          nonFatalFailure == other.nonFatalFailure &&
          selectedIssueType == other.selectedIssueType &&
          issueDescription == other.issueDescription &&
          isSubmittingIssue == other.isSubmittingIssue &&
          reportFailure == other.reportFailure &&
          reportSuccessMessage == other.reportSuccessMessage &&
          noticeId == other.noticeId &&
          reportNoticeId == other.reportNoticeId;

  @override
  int get hashCode =>
      boxId.hashCode ^
      tracking.hashCode ^
      isInitialLoading.hashCode ^
      isRefreshing.hashCode ^
      initialFailure.hashCode ^
      nonFatalFailure.hashCode ^
      selectedIssueType.hashCode ^
      issueDescription.hashCode ^
      isSubmittingIssue.hashCode ^
      reportFailure.hashCode ^
      reportSuccessMessage.hashCode ^
      noticeId.hashCode ^
      reportNoticeId.hashCode;
}
